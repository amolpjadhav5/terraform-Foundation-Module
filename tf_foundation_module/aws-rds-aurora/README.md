# Aurora  Cluster Module

A Terraform module to provision an Amazon Aurora  cluster with configurable instances, parameter groups, encryption, enhanced monitoring, and CloudWatch logging.

## Overview

This module provisions the Aurora  cluster and all its supporting resources. It does **not** create or manage security groups — the caller is responsible for creating the security group and passing its ID in via `vpc_security_group_ids`. This keeps the module focused on cluster concerns and gives callers full control over their network access rules.

Master credentials are managed by **AWS Secrets Manager by default**, ensuring passwords are never stored in the Terraform state file.

## Features

- **Aurora  cluster** – Configurable engine version, master credentials via Secrets Manager, backup, and maintenance windows.
- **Cluster instances** – Scalable instance count (1–15); first instance is the writer, remaining are readers.
- **Parameter groups** – Optional cluster-level and instance-level parameter groups with dynamic parameter support.
- **DB subnet group** – Create or reuse an existing subnet group.
- **Encryption** – Storage encryption enabled by default; supports bring-your-own KMS key with intelligent fallback for CloudWatch and Performance Insights.
- **IAM DB authentication** – Enabled by default.
- **Enhanced Monitoring** – Configurable interval (0–60 seconds) with external monitoring role.
- **Performance Insights** – Enabled by default with configurable retention and KMS key.
- **CloudWatch Log Groups** – Auto-created per enabled log type (`audit`, `error`, `general`, `slowquery`) with configurable retention and KMS encryption.
- **Deletion protection** – Enabled by default to guard against accidental cluster deletion.

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.3.0` |
| AWS provider | `>= 5.0` |

## Inputs

### Base Configuration

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `name` | `string` | — | **yes** | Identifier for the Aurora  cluster. |
| `create` | `bool` | `true` | no | Controls if resources should be created. |
| `region` | `string` | `null` | no | AWS region where resources are managed. Defaults to provider region. |
| `prefix_separator` | `string` | `"-"` | no | Separator used between prefix and generated suffix for resource names. |
| `tags` | `map(string)` | `{}` | no | Map of tags applied to all resources. |

### Cluster

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `engine_version` | `string` | `"8.0._aurora.3.05.2"` | no | Aurora  engine version. |
| `database_name` | `string` | `null` | no | Name of the default database created at cluster init. |
| `master_username` | `string` | `"admin"` | no | Master DB username. |
| `manage_master_user_password` | `bool` | `true` | no | Let RDS manage the master password in Secrets Manager. Recommended — avoids credentials in state file. |
| `master_password` | `string` | `null` | no | Master DB password. Only used when `manage_master_user_password = false`. Minimum 8 characters. **Avoid — exposes credentials in Terraform state.** |
| `port` | `number` | `3306` | no | Port the DB accepts connections on. |
| `availability_zones` | `list(string)` | `[]` | no | AZs in which cluster instances can be created. |
| `deletion_protection` | `bool` | `true` | no | Prevent cluster deletion without first disabling this flag. |
| `skip_final_snapshot` | `bool` | `false` | no | Skip final snapshot on cluster deletion. |
| `final_snapshot_identifier` | `string` | `null` | no | Name of the final snapshot. Required if `skip_final_snapshot = false`. |
| `backup_retention_period` | `number` | `7` | no | Days to retain automated backups (1–35). |
| `preferred_backup_window` | `string` | `"02:00-03:00"` | no | Daily time range for automated backups. Must not overlap with maintenance window. |
| `preferred_maintenance_window` | `string` | `"sun:05:00-sun:06:00"` | no | Weekly time range for system maintenance. |
| `apply_immediately` | `bool` | `false` | no | Apply cluster modifications immediately or at next maintenance window. |
| `iam_database_authentication_enabled` | `bool` | `true` | no | Enable IAM database authentication. |
| `enabled_cloudwatch_logs_exports` | `list(string)` | `["audit","error","general","slowquery"]` | no | Log types to export to CloudWatch. |
| `cluster_tags` | `map(string)` | `{}` | no | Additional tags for the cluster resource. |
| `timeouts` | `object` | `null` | no | Create, update, and delete timeout overrides for the cluster. |

### Networking

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `subnet_ids` | `list(string)` | `[]` | **yes** | VPC subnet IDs for the DB subnet group. |
| `vpc_security_group_ids` | `list(string)` | `[]` | **yes** | Security group IDs to attach to the cluster. Created and managed outside this module. |

### Cluster Instances

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `instance_count` | `number` | `1` | no | Number of cluster instances (1–15). First is writer; rest are readers. |
| `instance_class` | `string` | `"db.r6g.large"` | no | Instance class for all cluster instances. |
| `auto_minor_version_upgrade` | `bool` | `true` | no | Apply minor engine upgrades automatically during maintenance. |
| `publicly_accessible` | `bool` | `false` | no | Make instances publicly accessible. Should be `false` in production. |
| `monitoring_interval` | `number` | `60` | no | Enhanced Monitoring interval in seconds. Valid values: `0, 1, 5, 10, 15, 30, 60`. |
| `monitoring_role_arn` | `string` | `null` | no | IAM role ARN for Enhanced Monitoring. Required if `monitoring_interval > 0`. |
| `performance_insights_enabled` | `bool` | `true` | no | Enable Performance Insights for cluster instances. |
| `performance_insights_kms_key_id` | `string` | `null` | no | KMS key for Performance Insights encryption. Falls back to cluster KMS key. |
| `performance_insights_retention_period` | `number` | `7` | no | Performance Insights data retention in days. Valid values: `7`, `731`, or a multiple of `31`. |
| `instance_tags` | `map(string)` | `{}` | no | Additional tags for each cluster instance. |

### DB Subnet Group

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `create_db_subnet_group` | `bool` | `true` | no | Create a new DB subnet group or use an existing one. |
| `db_subnet_group_name` | `string` | `null` | no | Subnet group name. Defaults to cluster name. |
| `db_subnet_group_description` | `string` | `null` | no | Description for the DB subnet group. |
| `db_subnet_group_tags` | `map(string)` | `{}` | no | Additional tags for the DB subnet group. |

### Cluster Parameter Group

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `create_cluster_parameter_group` | `bool` | `true` | no | Create a cluster-level parameter group. |
| `cluster_parameter_group_name` | `string` | `null` | no | Parameter group name. Defaults to cluster name. |
| `cluster_parameter_group_description` | `string` | `null` | no | Description for the cluster parameter group. |
| `cluster_parameter_group_family` | `string` | `"aurora-8.0"` | no | DB cluster parameter group family. |
| `cluster_parameters` | `list(object)` | `[]` | no | List of cluster parameters (`name`, `value`, optional `apply_method`). |
| `cluster_parameter_group_tags` | `map(string)` | `{}` | no | Additional tags for the cluster parameter group. |

### DB Instance Parameter Group

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `create_db_parameter_group` | `bool` | `true` | no | Create a DB instance parameter group. |
| `db_parameter_group_name` | `string` | `null` | no | Parameter group name. Defaults to cluster name. |
| `db_parameter_group_description` | `string` | `null` | no | Description for the instance parameter group. |
| `db_parameter_group_family` | `string` | `"aurora-8.0"` | no | DB instance parameter group family. |
| `db_parameters` | `list(object)` | `[]` | no | List of instance parameters (`name`, `value`, optional `apply_method`). |
| `db_parameter_group_tags` | `map(string)` | `{}` | no | Additional tags for the DB instance parameter group. |

### Encryption (KMS)

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `storage_encrypted` | `bool` | `true` | no | Enable storage encryption. Should always be `true`. |
| `kms_key_id` | `string` | `null` | no | ARN of an existing KMS key for storage encryption. Defaults to AWS-managed RDS key. |

### CloudWatch Log Groups

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `create_cloudwatch_log_group` | `bool` | `true` | no | Create a CloudWatch log group per enabled log type. |
| `cloudwatch_log_group_retention_in_days` | `number` | `90` | no | Retention period in days for CloudWatch log events. |
| `cloudwatch_log_group_kms_key_id` | `string` | `null` | no | KMS key ARN for CloudWatch log group encryption. Falls back to cluster KMS key. |
| `cloudwatch_log_group_tags` | `map(string)` | `{}` | no | Additional tags for each CloudWatch log group. |

