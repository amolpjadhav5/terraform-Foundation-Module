################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "this" {
  count = local.create && var.create_db_subnet_group ? 1 : 0

  region = var.region

  name        = local.db_subnet_group_name
  description = coalesce(var.db_subnet_group_description, "Aurora MySQL subnet group for ${var.name}")
  subnet_ids  = var.subnet_ids

  tags = merge(
    var.tags,
    var.db_subnet_group_tags,
    { Name = local.db_subnet_group_name }
  )
}

################################################################################
# Cluster Parameter Group
################################################################################

resource "aws_rds_cluster_parameter_group" "this" {
  count = local.create && var.create_cluster_parameter_group ? 1 : 0

  region = var.region

  name        = local.cluster_parameter_group_name
  family      = var.cluster_parameter_group_family
  description = coalesce(var.cluster_parameter_group_description, "Aurora MySQL cluster parameter group for ${var.name}")

  dynamic "parameter" {
    for_each = var.cluster_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(
    var.tags,
    var.cluster_parameter_group_tags,
    { Name = local.cluster_parameter_group_name }
  )
}

################################################################################
# DB Instance Parameter Group
################################################################################

resource "aws_db_parameter_group" "this" {
  count = local.create && var.create_db_parameter_group ? 1 : 0

  region = var.region

  name        = local.db_parameter_group_name
  family      = var.db_parameter_group_family
  description = coalesce(var.db_parameter_group_description, "Aurora MySQL instance parameter group for ${var.name}")

  dynamic "parameter" {
    for_each = var.db_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(
    var.tags,
    var.db_parameter_group_tags,
    { Name = local.db_parameter_group_name }
  )
}

################################################################################
# CloudWatch Log Groups
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  for_each = {
    for log_type in var.enabled_cloudwatch_logs_exports :
    log_type => log_type
    if local.create && var.create_cloudwatch_log_group
  }

  region = var.region

  name              = "/aws/rds/cluster/${var.name}/${each.value}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = local.cloudwatch_kms_key_id

  tags = merge(
    var.tags,
    var.cloudwatch_log_group_tags,
    { Name = "/aws/rds/cluster/${var.name}/${each.value}" }
  )
}

################################################################################
# Aurora Cluster
################################################################################

resource "aws_rds_cluster" "this" {
  count = local.create ? 1 : 0

  region = var.region

  cluster_identifier = var.name
  engine             = "aurora-mysql"
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username
  port               = var.port
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : null

  # Credentials — managed by AWS Secrets Manager by default.
  manage_master_user_password = var.manage_master_user_password
  master_password             = var.manage_master_user_password ? null : var.master_password

  # Networking

  db_subnet_group_name   = var.create_db_subnet_group ? aws_db_subnet_group.this[0].name : var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  # Parameter groups
  db_cluster_parameter_group_name = var.create_cluster_parameter_group ? aws_rds_cluster_parameter_group.this[0].name : null

  # Encryption
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.storage_encrypted ? local.kms_key_id : null

  # Backup & maintenance
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  apply_immediately            = var.apply_immediately
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = var.skip_final_snapshot ? null : var.final_snapshot_identifier

  # Protection
  deletion_protection = var.deletion_protection

  # Auth
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  # Logs
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = merge(
    var.tags,
    var.cluster_tags,
    { Name = var.name }
  )

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_db_subnet_group.this,
    aws_rds_cluster_parameter_group.this,
  ]

  lifecycle {
    ignore_changes = [availability_zones]
  }
}

################################################################################
# Cluster Instances
################################################################################

resource "aws_rds_cluster_instance" "this" {
  count = local.create ? var.instance_count : 0

  region = var.region

  identifier         = "${var.name}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version

  db_subnet_group_name    = var.create_db_subnet_group ? aws_db_subnet_group.this[0].name : var.db_subnet_group_name
  db_parameter_group_name = var.create_db_parameter_group ? aws_db_parameter_group.this[0].name : null

  # The first instance (index 0) is the writer; remaining are readers
  promotion_tier = count.index

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  publicly_accessible        = var.publicly_accessible
  apply_immediately          = var.apply_immediately

  # Enhanced Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? var.monitoring_role_arn : null

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? local.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  tags = merge(
    var.tags,
    var.instance_tags,
    { Name = "${var.name}-${count.index + 1}" }
  )
}
