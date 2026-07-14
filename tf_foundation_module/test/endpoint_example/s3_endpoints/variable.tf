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
}

variable "name_gw_endpoint" {
  description = "Gateway endpoint name"
  type        = string
}

variable "name_ifce_endpoint" {
  description = "Interface endpoint"
  type        = string
}


variable "route_table_ids" {
  description = "Optional explicit route table IDs for the S3 Gateway endpoint."
  type        = list(string)
  default     = []
}

variable "service" {
  description = "Logical service or domain name for naming (e.g., data)."
  type        = string
  default     = "data"
}

variable "client" {
  description = "Client or BU name for naming (e.g., acme)."
  type        = string
  default     = "acme"
}
variable "name" {
  description = "Base name used for resource names (e.g., security group)."
  type        = string
  default     = "core"
}

variable "env" {
  description = "Environment (e.g., dev, stage, prod)."
  type        = string
  default     = "dev"
}

variable "gateway_service_name" {
  description = "The VPC endpoint service name for the S3 Gateway endpoint."
  type        = string
}

variable "policy_json" {
  description = <<-EOT
    Optional JSON policy for the S3 Gateway endpoint. If null, AWS default policy applies.
    Example restrictive policy (use jsonencode({...}) if passing as HCL expression):
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": "*",
          "Action": [
            "s3:GetObject",
            "s3:ListBucket"
          ],
          "Resource": [
            "arn:aws:s3:::example-bucket",
            "arn:aws:s3:::example-bucket/*"
          ]
        }
      ]
    }
  EOT
  type    = string
  default = null
}