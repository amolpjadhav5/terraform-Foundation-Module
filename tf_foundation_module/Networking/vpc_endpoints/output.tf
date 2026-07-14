
############################################################
# Outputs – S3 Gateway Endpoint
############################################################

output "s3_gateway_endpoint_id" {
  description = "S3 Gateway VPC Endpoint ID (or null if not created)"
  value       = try(aws_vpc_endpoint.s3_gateway[0].id, null)
}

output "s3_gateway_route_table_ids" {
  description = "Route table IDs associated with the S3 Gateway endpoint"
  value       = try(aws_vpc_endpoint.s3_gateway[0].route_table_ids, [])
}

############################################################
# Outputs – EC2 Interface Endpoint
############################################################

output "ec2_interface_vpce_id" {
  description = "EC2 Interface VPC Endpoint ID (or null if not created)"
  value       = try(aws_vpc_endpoint.ec2_interface[0].id, null)
}

output "ec2_interface_vpce_dns_entries" {
  description = "DNS entries for EC2 Interface endpoint"
  value       = try(aws_vpc_endpoint.ec2_interface[0].dns_entry, [])
}

############################################################
# Outputs – Snowflake Interface Endpoint
############################################################

output "snowflake_vpce_id" {
  description = "Snowflake Interface VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.snowflake_interface[0].id, null)
}

output "snowflake_vpce_arn" {
  description = "Snowflake Interface VPCE ARN"
  value       = try(aws_vpc_endpoint.snowflake_interface[0].arn, null)
}

output "snowflake_vpce_state" {
  description = "State of the Snowflake Interface VPC Endpoint"
  value       = try(aws_vpc_endpoint.snowflake_interface[0].state, null)
}

output "snowflake_vpce_dns_entries" {
  description = "Full DNS entry details of the Snowflake VPCE"
  value       = try(aws_vpc_endpoint.snowflake_interface[0].dns_entry, [])
}

############################################################
# Outputs – Snowflake DNS (Route53 mode)
############################################################

output "snowflake_zone_id" {
  description = "Route53 private hosted zone ID for Snowflake"
  value       = try(aws_route53_zone.snowflake_zone[0].zone_id, null)
}

output "snowflake_zone_name" {
  description = "Route53 private hosted zone name for Snowflake"
  value       = try(aws_route53_zone.snowflake_zone[0].name, null)
}

output "snowflake_account_record_fqdn" {
  description = "Snowflake Account CNAME record FQDN"
  value       = try(aws_route53_record.snowflake_account[0].fqdn, null)
}

output "snowflake_ocsp_record_fqdn" {
  description = "Snowflake OCSP CNAME record FQDN"
  value       = try(aws_route53_record.snowflake_ocsp[0].fqdn, null)
}

############################################################
# Outputs – Databricks Interface Endpoint
############################################################

output "databricks_vpce_id" {
  description = "Databricks Interface VPC Endpoint ID"
  value       = try(aws_vpc_endpoint.databricks_workspace[0].id, null)
}

output "databricks_vpce_arn" {
  description = "Databricks Interface VPCE ARN"
  value       = try(aws_vpc_endpoint.databricks_workspace[0].arn, null)
}

output "databricks_vpce_dns_entries" {
  description = "DNS entries for Databricks Interface VPCE"
  value       = try(aws_vpc_endpoint.databricks_workspace[0].dns_entry, [])
}

############################################################
# Outputs – Databricks DNS (Route53 mode)
############################################################

output "databricks_zone_id" {
  description = "Route53 private hosted zone ID for Databricks"
  value       = try(aws_route53_zone.databricks_zone[0].zone_id, null)
}

output "databricks_zone_name" {
  description = "Route53 private hosted zone name for Databricks"
  value       = try(aws_route53_zone.databricks_zone[0].name, null)
}

output "databricks_region_record_fqdn" {
  description = "Databricks regional A-alias record"
  value       = try(aws_route53_record.databricks_region[0].fqdn, null)
}

############################################################
# Outputs – AOSS VPC Endpoint (OpenSearch Serverless)
############################################################

output "aoss_vpc_endpoint_id" {
  description = "AOSS VPC Endpoint ID (or null if not created). Pass to opensearch-module's vpc_endpoint_ids input."
  value       = try(aws_opensearchserverless_vpc_endpoint.aoss[0].id, null)
}

output "aoss_vpc_endpoint_name" {
  description = "Name of the AOSS VPC endpoint (or null if not created)."
  value       = try(aws_opensearchserverless_vpc_endpoint.aoss[0].name, null)
}

############################################################
# Outputs – Common Discovery
############################################################

output "effective_subnet_ids" {
  description = "Subnets used for interface endpoints (explicit or discovered)"
  value       = try(distinct(local.effective_subnet_ids), [])
}

output "effective_route_table_ids" {
  description = "Route tables used for S3 Gateway (explicit or discovered)"
  value       = try(distinct(local.effective_route_table_ids), [])