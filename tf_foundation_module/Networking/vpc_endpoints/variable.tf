########################################
# Core networking inputs
########################################

variable "vpc_id" {
  description = "The VPC ID where endpoints and DNS will be created."
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "vpc_id must look like vpc-xxxxxxxx."
  }
}

variable "azs" {
  description = <<-EOT
    Optional comma-separated list of Availability Zones to consider (e.g., "us-east-1a,us-east-1b").
    If empty, all available AZs in the region will be used.
  EOT
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = "Security Group"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = <<-EOT
    Optional explicit list of subnet IDs to use for Interface endpoints.
    If empty, the module discovers the first 'private*' subnet in each AZ.
  EOT
  type        = list(string)
  default     = []
}



variable "route_table_ids" {
  description = <<-EOT
    Optional explicit list of route table IDs for Gateway endpoints (e.g., S3).
    If empty, the module discovers 'private*' route tables.
  EOT
  type        = list(string)
  default     = []
}

########################################
# Naming & tagging
########################################

variable "name" {
  description = "Base name used for resource names (e.g., security group)."
  type        = string
  default     = "core"
}

variable "service" {
  description = "Logical service or domain name (used in naming convention)."
  type        = string
}

variable "name_plsvc_provider" {
  description = "Private endpoint for snowflake/databricks"
  type        = string
}

variable "name_gw_endpoint" {
  description = "Gateway endpoint name"
  type        = string
}

variable "name_ifce_endpoint" {
  description = "Interface endpoint"
  type        = string
}

variable "client" {
  description = "Client or business unit (used in naming convention)."
  type        = string
}

variable "region" {
  description = "AWS region code (used in naming convention and service names)."
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, stage, prod)."
  type        = string
}

########################################
# Feature toggles
########################################

variable "create_gateway" {
  description = "Create S3 Gateway endpoint (true/false)."
  type        = bool
  default     = false
}

variable "create_interface" {
  description = "Create EC2 Interface endpoint (true/false)."
  type        = bool
  default     = false
}

variable "create_snowflake" {
  description = "Create Snowflake PrivateLink (Interface endpoint + Route53 records)."
  type        = bool
  default     = false
}

variable "create_databricks" {
  description = "Create Databricks PrivateLink (Interface endpoint + Route53 A-ALIAS record)."
  type        = bool
  default     = false
}

variable "create_aoss" {
  description = "Create a dedicated AOSS VPC endpoint (aws_opensearchserverless_vpc_endpoint) for OpenSearch Serverless."
  type        = bool
  default     = false
}

variable "aoss_endpoint_name" {
  description = "Optional name for the AOSS VPC endpoint (3-32 chars). Auto-generated from service/client/region/env when empty."
  type        = string
  default     = ""

  validation {
    condition     = var.aoss_endpoint_name == "" || (length(var.aoss_endpoint_name) >= 3 && length(var.aoss_endpoint_name) <= 32)
    error_message = "aoss_endpoint_name must be 3-32 characters if provided."
  }
}

########################################
# Policies
########################################

variable "policy_json" {
  description = <<-EOT
    Optional JSON policy for Gateway endpoint (S3). If null or empty, AWS default policy applies.
    Example: jsonencode({...})
  EOT
  type        = string
  default     = null
}

########################################
# Gateway & Interface service names
########################################

variable "gateway_service_name" {
  description = <<-EOT
    The VPC endpoint service name for the Gateway endpoint (e.g., S3).
    Example: "com.amazonaws.us-east-1.s3"
  EOT
  type        = string
  default     = ""
}

variable "interface_service_name" {
  description = <<-EOT
    The VPC endpoint service name for the Interface endpoint (e.g., EC2).
    Example: "com.amazonaws.us-east-1.ec2"
  EOT
  type        = string
  default     = ""
}

########################################
# Snowflake PrivateLink inputs
########################################

variable "snowflake_service_name" {
  description = <<-EOT
    The VPC endpoint service name provided by Snowflake for your account/region.
    Example: "com.amazonaws.vpce.<region>.aws.snowflakecomputing.com"
  EOT
  type        = string
  default     = ""
}

variable "snowflake_dns_mode" {
  description = "DNS mode for Snowflake (currently only 'route53' is supported in this module)."
  type        = string
  default     = ""
}

variable "snowflake_zone_name" {
  description = "Snowflake hosted zone."
  type        = string
  default     = ""
}



variable "snowflake_account_fqdn" {
  description = <<-EOT
    Full account endpoint FQDN under the Snowflake privatelink zone.
    Example: "<account>.<org>.<region>.privatelink.snowflakecomputing.com"
  EOT
  type        = string
  default     = ""
}

variable "snowflake_ocsp_fqdn" {
  description = <<-EOT
    OCSP endpoint FQDN under the Snowflake privatelink zone.
    Example: "ocsp.<region>.privatelink.snowflakecomputing.com"
  EOT
  type        = string
  default     = ""
}

########################################
# Databricks PrivateLink inputs
########################################

variable "databricks_service_name" {
  description = <<-EOT
    Databricks VPC endpoint service name for Workspace PrivateLink.
    Example: "com.amazonaws.vpce.<region>.cloud.databricks.com"
  EOT
  type        = string
  default     = ""
}

variable "databricks_dns_mode" {
  description = "DNS mode for Databricks (currently only 'route53' with existing PHZ is supported)."
  type        = string
  default     = "route53"
}

variable "databricks_zone_name" {
  description = "Databricks hosted zone."
  type        = string
  default     = ""
}

 