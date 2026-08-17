################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of the Aurora MySQL cluster"
  value       = try(aws_rds_cluster.this[0].arn, null)
}

output "cluster_id" {
  description = "The identifier of the Aurora MySQL cluster"
  value       = try(aws_rds_cluster.this[0].id, null)
}

output "cluster_resource_id" {
  description = "The region-unique, immutable identifier for the Aurora MySQL cluster"
  value       = try(aws_rds_cluster.this[0].cluster_resource_id, null)
}

output "cluster_endpoint" {
  description = "Writer endpoint for the Aurora MySQL cluster"
  value       = try(aws_rds_cluster.this[0].endpoint, null)
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the Aurora MySQL cluster, automatically load-balanced across replicas"
  value       = try(aws_rds_cluster.this[0].reader_endpoint, null)
}

output "cluster_engine_version_actual" {
  description = "The running version of the Aurora MySQL cluster database engine"
  value       = try(aws_rds_cluster.this[0].engine_version_actual, null)
}

output "cluster_database_name" {
  description = "Name for the default database created at cluster creation"
  value       = try(aws_rds_cluster.this[0].database_name, null)
}

output "cluster_master_username" {
  description = "The master username for the Aurora MySQL cluster"
  value       = try(aws_rds_cluster.this[0].master_username, null)
  sensitive   = true
}

output "cluster_master_user_secret" {
  description = "The generated database master user secret when manage_master_user_password is set to true"
  value       = try(aws_rds_cluster.this[0].master_user_secret, null)
  sensitive   = true
}

output "cluster_port" {
  description = "The database port for the Aurora MySQL cluster"
  value       = try(aws_rds_cluster.this[0].port, null)
}

output "cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = try(aws_rds_cluster.this[0].hosted_zone_id, null)
}

################################################################################
# Cluster Instances
################################################################################

output "cluster_instances" {
  description = "Map of cluster instances and their attributes"
  value       = aws_rds_cluster_instance.this
}

output "cluster_instance_endpoints" {
  description = "List of all instance endpoints in the Aurora MySQL cluster"
  value       = [for instance in aws_rds_cluster_instance.this : instance.endpoint]
}

################################################################################
# DB Subnet Group
################################################################################

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = try(aws_db_subnet_group.this[0].name, null)
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB subnet group"
  value       = try(aws_db_subnet_group.this[0].arn, null)
}

################################################################################
# CloudWatch Log Groups
################################################################################

output "cloudwatch_log_group_names" {
  description = "Map of CloudWatch log group names created for Aurora cluster log types"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "cloudwatch_log_group_arns" {
  description = "Map of CloudWatch log group ARNs created for Aurora cluster log types"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}
