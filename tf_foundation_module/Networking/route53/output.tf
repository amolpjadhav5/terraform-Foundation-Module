# ============================================================
# Hosted Zone Outputs
# ============================================================

output "zone_id" {
  description = "The hosted zone ID. Use this when creating records in other modules or when referencing the zone in Route53 alias records."
  value       = local.zone_id
}

output "zone_arn" {
  description = "The ARN of the hosted zone."
  value       = var.create_zone ? aws_route53_zone.this[0].arn : null
}

output "zone_name" {
  description = "The DNS name of the hosted zone."
  value       = var.create_zone ? aws_route53_zone.this[0].name : var.zone_name
}

output "name_servers" {
  description = "A list of name servers assigned to the hosted zone. Delegate these to your domain registrar for a public zone."
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : []
}

output "primary_name_server" {
  description = "The first name server assigned to the hosted zone. Useful for NS record delegation."
  value       = var.create_zone ? aws_route53_zone.this[0].primary_name_server : null
}

# ============================================================
# DNS Record Outputs
# ============================================================

output "standard_record_fqdns" {
  description = "Map of logical record key to the fully-qualified domain name (FQDN) of each standard (non-alias) record."
  value       = { for k, r in aws_route53_record.standard : k => r.fqdn }
}

output "alias_record_fqdns" {
  description = "Map of logical record key to the fully-qualified domain name (FQDN) of each alias record."
  value       = { for k, r in aws_route53_record.alias : k => r.fqdn }
}

output "all_record_fqdns" {
  description = "Combined map of all record FQDNs (standard + alias) keyed by the logical record identifier."
  value = merge(
    { for k, r in aws_route53_record.standard : k => r.fqdn },
    { for k, r in aws_route53_record.alias : k => r.fqdn }
  )
}

# ============================================================
# Convenience Object
# ============================================================

output "zone" {
  description = "A consolidated object exposing the most commonly consumed zone identifiers."
  value = {
    id           = local.zone_id
    arn          = var.create_zone ? aws_route53_zone.this[0].arn : null
    name         = var.create_zone ? aws_route53_zone.this[0].name : var.zone_name
    name_servers = var.create_zone ? aws_route53_zone.this[0].name_servers : []
    private      = var.private_zone
  }
}
 