################################################################################
# General
################################################################################

variable "name" {
  description = "Name identifier for the Aurora MySQL cluster and associated resources"
  type        = string
}

variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "sandbox"
    Team        = "platform"
    ManagedBy   = "terraform"
    Project     = "acxglobal"
  }
}

################################################################################
# Engine
################################################################################

variable "engine_version" {
  description = "Aurora MySQL engine version"
  type        = string
  default     = "8.0.mysql_aurora.3.05.2"
}

################################################################################
# Master Credentials
################################################################################

variable "master_username" {
  description = "Master DB username. Password is managed automatically by AWS Secrets Manager"
  type        = string
  default     = "admin"
}

################################################################################
# Networking
################################################################################

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Aurora DB subnet group. At least 2 subnets in different AZs required"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the Aurora cluster on port 3306"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

################################################################################
# Instances
################################################################################

variable "instance_count" {
  description = "Number of Aurora cluster instances. First is writer, additional are readers"
  type        = number
  default     = 1
}

variable "instance_class" {
  description = "Instance class for all Aurora cluster instances"
  type        = string
  default     = "db.r6g.large"
}

################################################################################
# Monitoring
################################################################################

variable "monitoring_interval" {
  description = "Enhanced Monitoring interval in seconds. Set to 0 to disable. Valid values: 0, 1, 5, 10, 15, 30, 60"
  type        = number
  default     = 60
}

variable "monitoring_role_arn" {
  description = "IAM role ARN for Enhanced Monitoring. Required when monitoring_interval > 0"
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights on cluster instances"
  type        = bool
  default     = true
}

################################################################################
# Encryption
################################################################################

variable "kms_key_id" {
  description = "ARN of the KMS key for Aurora storage encryption. Leave null to use the AWS-managed RDS key"
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Enable storage encryption for the Aurora cluster"
  type        = bool
  default     = true
}

################################################################################
# Backup
################################################################################

variable "backup_retention_period" {
  description = "Number of days to retain automated backups. Must be between 1 and 35"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Daily time range for automated backups (UTC). Must not overlap with maintenance window. Format: hh24:mi-hh24:mi"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "Weekly time range for system maintenance (UTC). Format: ddd:hh24:mi-ddd:hh24:mi"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on cluster deletion. Set to false in production"
  type        = bool
  default     = true
}

################################################################################
# Protection
################################################################################

variable "deletion_protection" {
  description = "Enable deletion protection on the Aurora cluster. Set to true in production"
  type        = bool
  default     = false
}

################################################################################
# Logs
################################################################################

variable "enabled_cloudwatch_logs_exports" {
  description = "Log types to export to CloudWatch. Valid values: audit, error, general, slowquery"
  type        = list(string)
  default     = ["audit", "error", "general", "slowquery"]
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain CloudWatch log events"
  type        = number
  default     = 90
}
