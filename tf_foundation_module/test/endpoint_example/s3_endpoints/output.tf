output "example_vpc_id" {
  description = "Echo the VPC ID used in the example."
  value       = var.vpc_id
}

output "example_route_table_ids" {
  description = "Route table IDs provided to the example (or discovered by the module)."
  value       = length(var.route_table_ids) > 0 ? var.route_table_ids : try(module.s3_endpoint.effective_route_table_ids, [])
}

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 Gateway endpoint created by the example."
  value       = try(module.s3_endpoint.s3_gateway_endpoint_id, null)
}

output "s3_gateway_endpoint_arn" {
  description = "ARN of the S3 Gateway endpoint created by the example."
  value       = try(module.s3_endpoint.s3_gateway_endpoint_arn, null)
}