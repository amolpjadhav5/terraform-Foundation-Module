################################################################################
# Aurora MySQL Module - Basic Example
################################################################################



module "aws_rds_aurora" {
  source = "../../aws-rds-aurora"
  # General
  region = var.region
  name   = var.name
  tags   = var.tags

  # Engine
  engine_version = var.engine_version

  # Master credentials
  # manage_master_user_password is hardcoded to true — AWS Secrets Manager handles
  # credential creation and rotation. Do NOT pass master_password here as it
  # would expose credentials in the Terraform state file.
  manage_master_user_password = true
  master_username             = var.master_username

  # Networking — SG created above, ID passed in here
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = []

  # Instances
  instance_count = var.instance_count
  instance_class = var.instance_class

  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  # Performance Insights
  performance_insights_enabled = var.performance_insights_enabled

  # Encryption
  kms_key_id        = var.kms_key_id
  storage_encrypted = var.storage_encrypted

  # Backup
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  skip_final_snapshot          = var.skip_final_snapshot

  # Protection
  deletion_protection = var.deletion_protection

  # Logs
  enabled_cloudwatch_logs_exports        = var.enabled_cloudwatch_logs_exports
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
}
