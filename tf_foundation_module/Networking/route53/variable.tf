# ============================================================
# Hosted Zone
# ============================================================

variable "create_zone" {
  description = "Whether to create the Route53 hosted zone. Set to false to use an existing zone via zone_id."
  type        = bool
  default     = true
}

variable "zone_name" {
  description = "The DNS name of the hosted zone (e.g. 'example.com'). Required when create_zone is true."
  type        = string
  default     = null
}

variable "zone_id" {
  description = "ID of an existing hosted zone to manage records in. Used when create_zone is false."
  type        = string
  default     = null
}

variable "comment" {
  description = "An optional comment to associate with the hosted zone."
  type        = string
  default     = "Managed by Terraform"
}

variable "force_destroy" {
  description = "Whether to destroy all records inside the zone before deleting the zone itself."
  type        = bool
  default     = false
}

# ============================================================
# Zone Type: Public vs Private
# ============================================================

variable "private_zone" {
  description = "If true, creates a private hosted zone. If false (default), creates a public hosted zone."
  type        = bool
  default     = false
}

variable "vpc_associations" {
  description = <<-EOT
    List of VPCs to associate with a private hosted zone. Only applicable when private_zone = true.
    Each entry requires:
    - vpc_id     (string) : The ID of the VPC to associate.
    - vpc_region (string) : AWS region of the VPC. Defaults to the provider region when omitted.
  EOT
  type = list(object({
    vpc_id     = string
    vpc_region = optional(string)
  }))
  default = []

  validation {
    condition     = length(var.vpc_associations) == 0 || var.private_zone
    error_message = "vpc_associations can only be set when private_zone = true."
  }
}

# ============================================================
# DNS Records
# ============================================================

variable "records" {
  description = <<-EOT
    Map of DNS records to create. The map key is a logical, unique record identifier.
    Each record supports:
    - name            (string)       : The record name relative to the zone apex (use "" or "@" for apex).
    - type            (string)       : Record type: A, AAAA, CNAME, TXT, MX, NS, SRV, CAA.
    - ttl             (number)       : Time-to-live in seconds. Required for non-alias records.
    - records         (list(string)) : Record values. Required for non-alias records.
    - alias           (object)       : Alias target block. Mutually exclusive with ttl/records.
      - name                   (string) : DNS name of the alias target (e.g. ALB DNS name).
      - zone_id                (string) : Hosted zone ID of the alias target resource (NOT this module's zone_id output).
      - evaluate_target_health (bool)   : Whether Route53 evaluates target health.
    - health_check_id (string) : Optional ID of a Route53 health check to associate.
    - set_identifier  (string) : Unique identifier for weighted/latency/failover routing policies.
    - weighted_routing_policy (object) : weight (number). Use set_identifier with this.
    - failover_routing_policy (object) : type (string) — PRIMARY or SECONDARY.
    - latency_routing_policy  (object) : region (string).
    - allow_overwrite (bool) : Allow Terraform to overwrite records not managed by it. Default false.
    Note: records are created only from this map. If this map is empty, no Route53 records are created.
  EOT
  type = map(object({
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

    simple_routing_policy = optional(object({}), {}) # Defaults to simple routing when no other policy is specified

    weighted_routing_policy = optional(object({
      weight = number
    }))

    failover_routing_policy = optional(object({
      type = string
    }))

    latency_routing_policy = optional(object({
      region = string
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, r in var.records :
      contains(["A", "AAAA", "CNAME", "TXT", "MX", "NS", "SRV", "CAA", "PTR", "SPF"], r.type)
    ])
    error_message = "Each record type must be one of: A, AAAA, CNAME, TXT, MX, NS, SRV, CAA, PTR, SPF."
  }

  validation {
    condition = alltrue([
      for k, r in var.records :
      (r.alias != null) != (length(r.records) > 0 || r.ttl != null)
    ])
    error_message = "Each record must define either 'alias' OR ('ttl' + 'records'), not both."
  }

  validation {
    condition = alltrue([
      for k, r in var.records :
      r.failover_routing_policy == null ||
      contains(["PRIMARY", "SECONDARY"], try(r.failover_routing_policy.type, "PRIMARY"))
    ])
    error_message = "failover_routing_policy.type must be 'PRIMARY' or 'SECONDARY'."
  }
}

# ============================================================
# Delegation Set
# ============================================================

variable "delegation_set_id" {
  description = "ID of a reusable delegation set to assign to the hosted zone. Used to maintain consistent name servers across zones."
  type        = string
  default     = null
}

# ============================================================
# Tags
# ============================================================

variable "tags" {
  description = "Map of tags to apply to the hosted zone and all supporting resources."
  type        = map(string)
  default     = {}
}
 