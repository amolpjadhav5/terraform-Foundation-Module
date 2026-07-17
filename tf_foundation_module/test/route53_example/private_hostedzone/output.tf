# ============================================================
# Outputs — one entry per zone in the private_zones map
# ============================================================

output "private_zone_ids" {
  description = "Map of zone name → hosted zone ID."
  value       = { for k, z in module.private_zone : k => z.zone_id }
}

output "private_record_fqdns" {
  description = "Map of zone name → all DNS record FQDNs."
  value       = { for k, z in module.private_zone : k => z.all_record_fqdns }
}

output "private_zones" {
  description = "Map of zone name → consolidated zone info object."
  value       = { for k, z in module.private_zone : k => z.zone }
}
 