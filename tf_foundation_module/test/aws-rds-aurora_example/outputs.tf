
output "cluster_arn" {
  description = "ARN of the Aurora MySQL cluster"
  value       = module.aurora_mysql.cluster_arn
}

output "cluster_endpoint" {
  description = "Writer endpoint to connect to the Aurora MySQL cluster"
  value       = module.aurora_mysql.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Read-only endpoint for the Aurora MySQL cluster"
  value       = module.aurora_mysql.cluster_reader_endpoint
}

output "cluster_port" {
  description = "Port the cluster is listening on"
  value       = module.aurora_mysql.cluster_port
}

output "cluster_master_user_secret" {
  description = "Secrets Manager secret ARN containing the master credentials"
  value       = module.aurora_mysql.cluster_master_user_secret
  sensitive   = true
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group created for the cluster"
  value       = module.aurora_mysql.db_subnet_group_name
}

output "cloudwatch_log_group_names" {
  description = "Map of CloudWatch log group names created for the cluster"
  value       = module.aurora_mysql.cloudwatch_log_group_names
}

