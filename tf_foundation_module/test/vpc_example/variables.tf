variable "aws_region" {
  description = "AWS region for the provider."
  type        = string
}

variable "project" {
  description = "Project or application name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name such as dev, test, stage, or prod."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "Optional explicit VPC Name tag."
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default = "10.0.0.0/16"
}

variable "instance_tenancy" {
  description = "VPC instance tenancy. Valid values: default or dedicated."
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "Whether DNS support is enabled for the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled for the VPC."
  type        = bool
  default     = true
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Whether to assign an Amazon-provided IPv6 CIDR block to the VPC."
  type        = bool
  default     = false
}

variable "enable_network_address_usage_metrics" {
  description = "Whether network address usage metrics are enabled for the VPC."
  type        = bool
  default     = false
}

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway for public subnet internet routing."
  type        = bool
  default     = true
}

variable "public_subnets" {
  description = "Public subnet definitions. Name must be unique."
  type = list(object({
    name                                            = string
    cidr_block                                      = string
    availability_zone                               = string
    map_public_ip_on_launch                         = optional(bool, true)
    assign_ipv6_address_on_creation                 = optional(bool, false)
    private_dns_hostname_type_on_launch             = optional(string, "ip-name")
    enable_resource_name_dns_a_record_on_launch     = optional(bool, false)
    enable_resource_name_dns_aaaa_record_on_launch  = optional(bool, false)
    tags                                            = optional(map(string), {})
  }))
  default = []
}

variable "private_subnets" {
  description = "Private application subnet definitions. Name must be unique."
  type = list(object({
    name                                            = string
    cidr_block                                      = string
    availability_zone                               = string
    map_public_ip_on_launch                         = optional(bool, false)
    assign_ipv6_address_on_creation                 = optional(bool, false)
    private_dns_hostname_type_on_launch             = optional(string, "ip-name")
    enable_resource_name_dns_a_record_on_launch     = optional(bool, false)
    enable_resource_name_dns_aaaa_record_on_launch  = optional(bool, false)
    tags                                            = optional(map(string), {})
  }))
  default = []
}

variable "database_subnets" {
  description = "Isolated database subnet definitions. Name must be unique."
  type = list(object({
    name                                            = string
    cidr_block                                      = string
    availability_zone                               = string
    map_public_ip_on_launch                         = optional(bool, false)
    assign_ipv6_address_on_creation                 = optional(bool, false)
    private_dns_hostname_type_on_launch             = optional(string, "ip-name")
    enable_resource_name_dns_a_record_on_launch     = optional(bool, false)
    enable_resource_name_dns_aaaa_record_on_launch  = optional(bool, false)
    tags                                            = optional(map(string), {})
  }))
  default = []
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways for private subnet outbound internet access."
  type        = bool
  default     = true
}

variable "nat_gateway_subnet_names" {
  description = "Public subnet names where NAT Gateways and Elastic IPs will be created."
  type        = list(string)
  default     = []
}

variable "default_nat_gateway_subnet_name" {
  description = "NAT Gateway public subnet name used when create_private_route_table_per_az is false."
  type        = string
  default     = null
}

variable "create_private_route_table_per_az" {
  description = "Whether to create one private route table per private subnet. False creates one shared private route table."
  type        = bool
  default     = false
}

variable "private_subnet_nat_gateway_map" {
  description = "Map of private subnet name to public subnet name hosting the NAT Gateway. Required when create_private_route_table_per_az is true and NAT is enabled."
  type        = map(string)
  default     = {}
}

variable "create_database_subnet_group" {
  description = "Whether to create an RDS DB subnet group from database subnets."
  type        = bool
  default     = true
}

variable "database_subnet_group_name" {
  description = "Optional DB subnet group name."
  type        = string
  default     = null
}

variable "database_subnet_group_description" {
  description = "DB subnet group description."
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for VPC." 
}

variable "internet_gateway_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for IGW." 
 }
variable "public_subnet_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for public subnets." 
 }
variable "private_subnet_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for private subnets." 
 }
variable "database_subnet_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for database subnets." 
 }
variable "public_route_table_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for public route table." 
 }
variable "private_route_table_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for private route tables." 
 }
variable "database_route_table_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for database route table." 
 }
variable "nat_eip_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for NAT EIPs." 
 }
variable "nat_gateway_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for NAT Gateways." 
 }
variable "database_subnet_group_tags" { 
  type = map(string) 
  default = {} 
  description = "Additional tags for DB subnet group." 
 }
