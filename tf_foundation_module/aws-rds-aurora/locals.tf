locals {
  create = var.create

  cluster_parameter_group_name = coalesce(var.cluster_parameter_group_name, var.name)
  db_parameter_group_name      = coalesce(var.db_parameter_group_name, var.name)
  db_subnet_group_name         = coalesce(var.db_subnet_group_name, var.name)

  kms_key_id = var.kms_key_id

  cloudwatch_kms_key_id = var.cloudwatch_log_group_kms_key_id != null ? var.cloudwatch_log_group_kms_key_id : local.kms_key_id

  performance_insights_kms_key_id = var.performance_insights_kms_key_id != null ? var.performance_insights_kms_key_id : local.kms_key_id
}
