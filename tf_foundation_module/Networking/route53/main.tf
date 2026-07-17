locals {
  # Merge common metadata into every tag map
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
    }
  )

  # The zone ID to use for record creation — either from the newly-created zone
  # or from the caller-supplied existing zone ID.
  # When create_zone = false, callers must pass a valid zone_id.
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id

  # Records are created only from var.records.
  # If var.records is empty (or tfvars is not loaded), no aws_route53_record resources are created.
  # Separate alias vs. standard records to drive dynamic blocks cleanly.
  alias_records    = { for k, r in var.records : k => r if r.alias != null }
  standard_records = { for k, r in var.records : k => r if r.alias == null }
}

# ============================================================
# Hosted Zone
# ============================================================

resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0

  name              = var.zone_name
  comment           = var.comment
  delegation_set_id = var.private_zone ? null : var.delegation_set_id
  force_destroy     = var.force_destroy

  # VPC associations make this a private zone.
  # Dynamic block handles zero or many VPCs cleanly.
  dynamic "vpc" {
    for_each = var.private_zone ? var.vpc_associations : []

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.vpc_region
    }
  }

  tags = local.common_tags
}

# ============================================================
# Standard DNS Records (A, AAAA, CNAME, TXT, MX, NS, SRV…)
# ============================================================

resource "aws_route53_record" "standard" {
  for_each = local.standard_records

  zone_id         = local.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = each.value.ttl
  records         = each.value.records
  health_check_id = each.value.health_check_id
  set_identifier  = each.value.set_identifier
  allow_overwrite = each.value.allow_overwrite

  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted_routing_policy != null ? [each.value.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover_routing_policy != null ? [each.value.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.latency_routing_policy != null ? [each.value.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }
}

# ============================================================
# Alias DNS Records (ALB, CloudFront, API Gateway, S3…)
# ============================================================

resource "aws_route53_record" "alias" {
  for_each = local.alias_records

  zone_id         = local.zone_id
  name            = each.value.name
  type            = each.value.type
  health_check_id = each.value.health_check_id
  set_identifier  = each.value.set_identifier
  allow_overwrite = each.value.allow_overwrite

  # Important: alias.zone_id must be the hosted zone ID of the alias TARGET
  # (for example ALB/CloudFront/API Gateway), not this Route53 hosted zone ID.
  alias {
    name                   = each.value.alias.name
    zone_id                = each.value.alias.zone_id
    evaluate_target_health = each.value.alias.evaluate_target_health
  }

  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted_routing_policy != null ? [each.value.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover_routing_policy != null ? [each.value.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.latency_routing_policy != null ? [each.value.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }
}
 