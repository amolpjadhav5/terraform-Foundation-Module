# ============================================================
# Provider
# ============================================================

variable "aws_region" {
  description = "AWS region to deploy the hosted zones into."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile to use for the hosted zones."
  type        = string
  default     = "svcterraform-sandbox"
}

# ============================================================
# Private Hosted Zones
# Each key is the zone name (e.g. "internal.example.com").
# User provides the familiar private_ prefixed fields per zone.
# ============================================================

variable "private_zones" {
  description = <<-EOT
    Map of private hosted zones. The key is the zone name.
    For new zones:  private_create_zone = true, vpc_id + vpc_region required
    For existing:   private_create_zone = false, private_existing_zone_id = "Z..."
    Adding a new key creates a new zone without affecting existing ones.
  EOT
  type = map(object({
    private_create_zone        = bool
    private_existing_zone_id   = optional(string)
    private_zone_comment       = optional(string, "Managed by Terraform")
    private_zone_force_destroy = optional(bool, false)
    vpc_id                     = optional(string)
    vpc_region                 = optional(string, "us-east-1")

    private_records = optional(map(object({
      name    = string
      type    = string
      ttl     = optional(number)
      records = optional(list(string), [])

      alias = optional(object({
        name                   = string
        zone_id                = string
        evaluate_target_health = optional(bool, true)
      }))

      health_check_id = optional(string)
      set_identifier  = optional(string)
      allow_overwrite = optional(bool, false)

      weighted_routing_policy = optional(object({
        weight = number
      }))

      failover_routing_policy = optional(object({
        type = string
      }))

      latency_routing_policy = optional(object({
        region = string
      }))
    })), {})
  }))
}

# ============================================================
# Tags
# ============================================================

variable "tags" {
  description = "Tags applied to all resources. ManagedBy=Terraform is always merged in by the module."
  type        = map(string)
  default     = {}
}
 