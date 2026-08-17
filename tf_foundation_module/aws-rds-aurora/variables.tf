variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "prefix_separator" {
  description = "The separator to use between the prefix and the generated suffix for resource names"
  type        = string
  default     = "-"
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster
################################################################################

variable "name" {
  description = "Identifier for the Aurora MySQL cluster"
  type        = string
}

variable "engine_version" {
  description = "The database engine version. Refer to AWS documentation for valid Aurora MySQL versions (e.g. 8.0.mysql_aurora.3.05.2)"
  type        = string
  default     = "8.0.mysql_aurora.3.05.2"
}

variable "database_name" {
  description = "Name of the default database to create when the DB cluster is created"
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "admin"
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager. Recommended — avoids storing credentials in Terraform state"
  type        = bool
  default     = true
}

variable "master_password" {
  description = "Password for the master DB user. Required if manage_master_user_password is false. Must be at least 8 characters. Avoid — exposes credentials in Terraform state"
  type        = string
  default     = null
  sensitive   = true
}

variable "port" {
  description = "The port on which the DB accepts connections. Default is 3306 for Aurora MySQL"
  type        = number
  default     = 3306
}

variable "availability_zones" {
  description = "List of EC2 availability zones in which the cluster instances can be created"
  type        = list(string)
  default     = []
}

variable "deletion_protection" {
  description = "If the DB cluster should have deletion protection enabled. If true, the database cannot be deleted without first disabling deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB cluster is deleted. Must be provided if skip_final_snapshot is false"
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "The days to retain backups. Must be between 1 and 35"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created. Must not overlap with preferred_maintenance_window. Format: hh24:mi-hh24:mi"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur. Format: ddd:hh24:mi-ddd:hh24:mi"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = false
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether IAM Database authentication is enabled"
  type        = bool
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to CloudWatch. Valid values: audit, error, general, slowquery"
  type        = list(string)
  default     = ["audit", "error", "general", "slowquery"]
}

variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

################################################################################
# Cluster Instances
################################################################################

variable "instance_count" {
  description = "Number of Aurora MySQL cluster instances to create. The first is the writer; any additional are readers"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 15
    error_message = "instance_count must be between 1 and 15."
  }
}

variable "instance_class" {
  description = "The instance class to use for cluster instances (e.g. db.r6g.large, db.serverless)"
  type        = string
  default     = "db.r6g.large"
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Bool to control if instances are publicly accessible. Should be false for production"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected. Valid values: 0, 1, 5, 10, 15, 30, 60"
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch. Required if monitoring_interval > 0"
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled for cluster instances"
  type        = bool
  default     = true
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data. Defaults to the cluster KMS key if not provided"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data. Valid values: 7, 731 (2 years), or a multiple of 31"
  type        = number
  default     = 7
}

variable "instance_tags" {
  description = "A map of additional tags to add to each cluster instance"
  type        = map(string)
  default     = {}
}

################################################################################
# Networking
################################################################################

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the Aurora cluster. Security groups are created and managed outside this module and passed in here"
  type        = list(string)
  default     = []
}

################################################################################
# DB Subnet Group
################################################################################

variable "create_db_subnet_group" {
  description = "Determines whether to create a DB subnet group or use an existing one"
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group. If not provided, defaults to the cluster name"
  type        = string
  default     = null
}

variable "db_subnet_group_description" {
  description = "The description of the DB subnet group"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs for the DB subnet group"
  type        = list(string)
  default     = []
}

variable "db_subnet_group_tags" {
  description = "A map of additional tags to add to the DB subnet group"
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster Parameter Group
################################################################################

variable "create_cluster_parameter_group" {
  description = "Determines whether to create a cluster parameter group"
  type        = bool
  default     = true
}

variable "cluster_parameter_group_name" {
  description = "The name of the cluster parameter group. If not provided, defaults to the cluster name"
  type        = string
  default     = null
}

variable "cluster_parameter_group_description" {
  description = "The description of the cluster parameter group"
  type        = string
  default     = null
}

variable "cluster_parameter_group_family" {
  description = "The DB cluster parameter group family (e.g. aurora-mysql8.0)"
  type        = string
  default     = "aurora-mysql8.0"
}

variable "cluster_parameters" {
  description = "List of DB cluster parameters to apply"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

variable "cluster_parameter_group_tags" {
  description = "A map of additional tags to add to the cluster parameter group"
  type        = map(string)
  default     = {}
}

################################################################################
# DB Instance Parameter Group
################################################################################

variable "create_db_parameter_group" {
  description = "Determines whether to create a DB instance parameter group"
  type        = bool
  default     = true
}

variable "db_parameter_group_name" {
  description = "The name of the DB instance parameter group. If not provided, defaults to the cluster name"
  type        = string
  default     = null
}

variable "db_parameter_group_description" {
  description = "The description of the DB instance parameter group"
  type        = string
  default     = null
}

variable "db_parameter_group_family" {
  description = "The DB parameter group family (e.g. aurora-mysql8.0)"
  type        = string
  default     = "aurora-mysql8.0"
}

variable "db_parameters" {
  description = "List of DB instance parameters to apply"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

variable "db_parameter_group_tags" {
  description = "A map of additional tags to add to the DB instance parameter group"
  type        = map(string)
  default     = {}
}

################################################################################
# KMS Key
################################################################################

variable "kms_key_id" {
  description = "ARN of an existing KMS key to use for storage encryption. If null, AWS automatically uses the default AWS-managed KMS key for RDS"
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted. Should always be true"
  type        = bool
  default     = true
}

################################################################################
# CloudWatch Log Groups
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether to create a CloudWatch log group for each enabled log type"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain CloudWatch log events"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "ARN of KMS key to use to encrypt CloudWatch log groups. Defaults to the cluster KMS key if not provided"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_tags" {
  description = "A map of additional tags to add to each CloudWatch log group"
  type        = map(string)
  default     = {}
}
