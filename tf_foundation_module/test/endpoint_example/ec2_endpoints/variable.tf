variable "region" {
  description = "AWS region to deploy into (e.g., us-east-1)."
  type        = string
}

variable "vpc_id" {
  description = "The target VPC ID."
  type        = string
}

variable "name_plsvc_provider" {
  description = "Private endpoint for snowflake/databricks"
  type        = string
  default     = ""
}

variable "name_gw_endpoint" {
  description = "Gateway endpoint name"
  type        = string
  default     = ""
}

variable "name_ifce_endpoint" {
  description = "Interface endpoint"
  type        = string
  default     = ""
}

variable "service" {
  description = "Logical service or domain name for naming (e.g., platform)."
  type        = string
  default     = ""
}

variable "client" {
  description = "Client or BU name for naming (e.g., acme)."
  type        = string
  default     = ""
}

variable "env" {
  description = "Environment (e.g., dev, stage, prod)."
  type        = string
  default     = ""
}

variable "name" {
  description = "Base name used for resource names (e.g., security group)."
  type        = string
  default     = ""
}

variable "azs" {
  description = "Optional comma-separated list of AZs to consider (e.g., \"us-east-1a,us-east-1b\")."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Optional explicit subnet IDs for the EC2 Interface endpoint. If empty, module discovers private* subnets and picks the first per AZ."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security Group"
  type        = list(string)
  default     = []
}

variable "interface_service_name" {
  description = "The VPC endpoint service name for the EC2 Interface endpoint."
  type        = string
}

variable "create_interface" {
  description = "When true, the private-endpoints module creates the EC2 Interface VPC endpoint."
  type        = bool
  default     = true
}

variable "create_aoss" {
  description = "When true, the private-endpoints module creates an AOSS VPC endpoint (aws_opensearchserverless_vpc_endpoint)."
  type        = bool
  default     = false
}

variable "aoss_endpoint_name" {
  description = "Optional name for the AOSS VPC endpoint (3-32 chars). Auto-generated when empty."
  type        = string
  default     = ""
}