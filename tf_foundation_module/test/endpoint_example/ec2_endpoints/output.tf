output "example_vpc_id" {
  description = "Echo the VPC ID used in the example."
  value       = var.vpc_id
}

output "effective_subnet_ids" {
  description = "Subnets used for the EC2 Interface endpoint (explicit or discovered)."
  value       = try(module.ec2_interface_endpoint.effective_subnet_ids, [])
}

output "ec2_interface_endpoint_id" {
  description = "ID of the EC2 Interface endpoint."
  value       = try(module.ec2_interface_endpoint.ec2_interface_endpoint_id, null)
}

output "ec2_interface_endpoint_dns_names" {
  description = "DNS names exposed by the EC2 Interface endpoint."
  value       = try(module.ec2_interface_endpoint.ec2_interface_endpoint_dns_names, [])
}

output "aoss_vpc_endpoint_id" {
  description = "AOSS VPC endpoint ID (null when create_aoss = false). Pass into opensearch-module's vpc_endpoint_ids input."
  value       = try(module.ec2_interface_endpoint.aoss_vpc_endpoint_id, null)
}

output "aoss_vpc_endpoint_name" {
  description = "AOSS VPC endpoint name (null when create_aoss = false)."
  value       = try(module.ec2_interface_endpoint.aoss_vpc_endpoint_name, null)
}