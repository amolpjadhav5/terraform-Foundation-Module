output "vpc_id" {
  description = "Created VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "Created VPC ARN."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "VPC IPv4 CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID, if created."
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "public_subnet_ids" {
  description = "Map of public subnet name to subnet ID."
  value       = { for name, subnet in aws_subnet.public : name => subnet.id }
}

output "private_subnet_ids" {
  description = "Map of private subnet name to subnet ID."
  value       = { for name, subnet in aws_subnet.private : name => subnet.id }
}

output "database_subnet_ids" {
  description = "Map of database subnet name to subnet ID."
  value       = { for name, subnet in aws_subnet.database : name => subnet.id }
}

output "public_route_table_id" {
  description = "Public route table ID."
  value       = try(aws_route_table.public[0].id, null)
}

output "private_route_table_ids" {
  description = "Map of private route table names to IDs."
  value       = { for name, rt in aws_route_table.private : name => rt.id }
}

output "database_route_table_id" {
  description = "Database route table ID."
  value       = try(aws_route_table.database[0].id, null)
}

output "nat_gateway_ids" {
  description = "Map of public subnet name to NAT Gateway ID."
  value       = { for name, nat in aws_nat_gateway.this : name => nat.id }
}

output "nat_eip_public_ips" {
  description = "Map of public subnet name to NAT EIP public IP."
  value       = { for name, eip in aws_eip.nat : name => eip.public_ip }
}

output "database_subnet_group_name" {
  description = "DB subnet group name, if created."
  value       = try(aws_db_subnet_group.this[0].name, null)
}
