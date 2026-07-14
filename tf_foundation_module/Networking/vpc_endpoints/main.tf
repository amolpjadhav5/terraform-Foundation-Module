########################################
# Data Sources
########################################

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_availability_zones" "available" {}
//data "snowflake_system_get_privatelink_config" "cfg" {}

# Use provided AZs if var.azs is non-empty; else all AZs in the region
locals {
  azs = var.azs != "" ? split(",", var.azs) : data.aws_availability_zones.available.names
}

# Discover private subnets by AZ (tag Name matches 'private*')
data "aws_subnets" "private_by_az" {
  for_each = toset(local.azs)

  filter {
    name   = "availability-zone"
    values = [each.key]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["private*"]
  }
}

# Discover private route tables (tag Name matches 'private*')
data "aws_route_tables" "private_rts" {
  vpc_id = var.vpc_id

  filter {
    name   = "tag:Name"
    values = ["private*"]
  }
}

########################################
# Locals for safe, conditional defaults
########################################

locals {
  # Per-AZ list of subnet IDs
  private_subnet_ids_per_az = {
    for az, s in data.aws_subnets.private_by_az : az => s.ids
  }

  # First private subnet per AZ (or null if none)
  first_private_subnet_ids_per_az = {
    for az, s in data.aws_subnets.private_by_az : az => (length(s.ids) > 0 ? s.ids[0] : null)
  }

  # Flatten list of the first subnet from each AZ, compact to drop nulls
  all_first_private_subnet_ids = compact([
    for az, sid in local.first_private_subnet_ids_per_az : sid
  ])

  private_route_table_ids = data.aws_route_tables.private_rts.ids

  # Effective inputs:
  effective_route_table_ids = length(var.route_table_ids) > 0 ? var.route_table_ids : local.private_route_table_ids
  effective_subnet_ids      = length(var.subnet_ids) > 0 ? var.subnet_ids : local.all_first_private_subnet_ids

  vpc_cidr = data.aws_vpc.selected.cidr_block
}

########################################
# Naming convention locals (NEW)
# Required inputs: var.service, var.client, var.region, var.env
########################################

/* locals {
  name_ifce_endpoint  = "vpce-ifce-${var.service}-${var.client}-${var.region}-${var.env}"
  name_gw_endpoint    = "vpce-gw-${var.service}-${var.client}-${var.region}-${var.env}"
  name_plsvc_provider = "plsvc-${var.service}-${var.client}-${var.region}-${var.env}"
} */


# Optional fast-fail guard if naming inputs are missing.
# (You can also enforce this with `validation` blocks in variables.tf)
resource "null_resource" "naming_mandatory_guard" {
  triggers = {
    service = var.service
    client  = var.client
    env     = var.env
    region  = var.region
  }
  lifecycle {
    precondition {
      condition     = length(var.service) > 0 && length(var.client) > 0 && length(var.env) > 0 && length(var.region) > 0
      error_message = "Naming inputs required: var.service, var.client, var.region, var.env must be non-empty."
    }
  }
}

########################################
# S3 Gateway Endpoint (optional)
########################################

resource "aws_vpc_endpoint" "s3_gateway" {
  count             = var.create_gateway ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = var.gateway_service_name
  vpc_endpoint_type = "Gateway"

  # For S3 Gateway endpoint, route table associations are required
  route_table_ids = local.effective_route_table_ids

  # Apply policy only if non-null—otherwise AWS default policy applies
  policy = var.policy_json

  tags = {
    # Naming convention for Gateway endpoints
    Name    = var.name_gw_endpoint
    Service = var.service
    Client  = var.client
    Region  = var.region
    Env     = var.env
  }
}

########################################
# EC2 Interface Endpoint (optional)./tf-aws-resources-modules/compute-module/bedrock-agentcore
########################################

resource "aws_vpc_endpoint" "ec2_interface" {
  count             = var.create_interface ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = var.interface_service_name
  vpc_endpoint_type = "Interface"

  # If no subnet_ids provided, we discovered first private subnet per AZ
  subnet_ids = distinct(local.effective_subnet_ids)

  security_group_ids  = var.security_group_ids
  private_dns_enabled = true

  tags = {
    # Naming convention for Interface endpoints
    Name    = var.name_ifce_endpoint
    Service = var.service
    Client  = var.client
    Region  = var.region
    Env     = var.env
  }
}

############################################################
# AOSS VPC Endpoint (OpenSearch Serverless — optional)
# -----------------------------------------------------------
# Creates an aws_opensearchserverless_vpc_endpoint (the AOSS-managed endpoint
# type, NOT a generic aws_vpc_endpoint). The output id can be passed to the
# OpenSearch Serverless module via its vpc_endpoint_ids input so the network
# security policy's SourceVPCEs list includes it.
############################################################

resource "aws_opensearchserverless_vpc_endpoint" "aoss" {
  count = var.create_aoss ? 1 : 0

  name               = trimspace(var.aoss_endpoint_name) != "" ? var.aoss_endpoint_name : substr("aoss-${var.service}-${var.client}-${var.env}", 0, 32)
  vpc_id             = var.vpc_id
  subnet_ids         = distinct(local.effective_subnet_ids)
  security_group_ids = var.security_group_ids

  lifecycle {
    precondition {
      condition     = !var.create_aoss || (length(distinct(local.effective_subnet_ids)) > 0 && length(var.security_group_ids) > 0)
      error_message = "When create_aoss = true, subnets (explicit or auto-discovered) and security_group_ids must both be non-empty."
    }
  }
}


############################################################
# Snowflake VPCE (Interface)
############################################################

resource "aws_vpc_endpoint" "snowflake_interface" {
  count             = var.create_snowflake ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = var.snowflake_service_name
  vpc_endpoint_type = "Interface"

  subnet_ids          = distinct(local.effective_subnet_ids)
  security_group_ids  = var.security_group_ids
  private_dns_enabled = false

  tags = {
    Name = var.name_plsvc_provider
  }
}

############################################################
# Create Route53 Zone for Snowflake (ONLY IF DNS mode = route53)
############################################################

resource "aws_route53_zone" "snowflake_zone" {
  count = var.create_snowflake && var.snowflake_dns_mode == "route53" ? 1 : 0
  name  = var.snowflake_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}

############################################################
# Snowflake CNAMEs
############################################################

resource "aws_route53_record" "snowflake_account" {
  count           = var.create_snowflake && var.snowflake_dns_mode == "route53" ? 1 : 0
  zone_id         = aws_route53_zone.snowflake_zone[0].zone_id
  name            = var.snowflake_account_fqdn
  type            = "CNAME"
  ttl             = 60
  records         = [aws_vpc_endpoint.snowflake_interface[0].dns_entry[0].dns_name]
  allow_overwrite = true
}

resource "aws_route53_record" "snowflake_ocsp" {
  count           = var.create_snowflake && var.snowflake_dns_mode == "route53" ? 1 : 0
  zone_id         = aws_route53_zone.snowflake_zone[0].zone_id
  name            = var.snowflake_ocsp_fqdn
  type            = "CNAME"
  ttl             = 60
  records         = [aws_vpc_endpoint.snowflake_interface[0].dns_entry[0].dns_name]
  allow_overwrite = true
}


############################################################
# Databricks VPCE
############################################################

resource "aws_vpc_endpoint" "databricks_workspace" {
  count             = var.create_databricks ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = var.databricks_service_name
  vpc_endpoint_type = "Interface"

  subnet_ids          = distinct(local.effective_subnet_ids)
  security_group_ids  = var.security_group_ids
  private_dns_enabled = false

  tags = {
    Name = var.name_plsvc_provider
  }
}

############################################################
# Create Route53 Zone for Databricks (ONLY IF DNS mode = route53)
############################################################

resource "aws_route53_zone" "databricks_zone" {
  count = var.create_databricks && var.databricks_dns_mode == "route53" ? 1 : 0
  name  = var.databricks_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}

############################################################
# Databricks A Alias Record
############################################################

resource "aws_route53_record" "databricks_region" {
  count = var.create_databricks && var.databricks_dns_mode == "route53" ? 1 : 0

  zone_id = aws_route53_zone.databricks_zone[0].zone_id
  name    = "${var.region}.privatelink.cloud.databricks.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.databricks_workspace[0].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.databricks_workspace[0].dns_entry[0].hosted_zone_id
    evaluate_target_health = false
  }

  allow_overwrite = true
}
 