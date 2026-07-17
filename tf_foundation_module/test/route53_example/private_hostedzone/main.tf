provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {}

# ============================================================
# Private Hosted Zones — single module block, multiple zones.
# Each key in var.private_zones drives one instance of the module.
#   private_create_zone = true  → creates a new zone
#   private_create_zone = false → uses an existing zone (zone_id)
# Adding a new key creates a new zone without affecting others.
# ============================================================

module "private_zone" {
  source   = "../../../networking-modules/route-53"
  for_each = var.private_zones

  create_zone   = each.value.private_create_zone
  zone_id       = each.value.private_existing_zone_id
  zone_name     = each.value.private_create_zone ? each.key : null
  comment       = each.value.private_zone_comment
  private_zone  = true
  force_destroy = each.value.private_zone_force_destroy

  # VPC association is only required when creating a new private hosted zone.
  vpc_associations = each.value.private_create_zone ? [
    {
      vpc_id     = each.value.vpc_id
      vpc_region = each.value.vpc_region
    }
  ] : []

  records = each.value.private_records
  tags    = merge(var.tags, { Visibility = "private" })
}


 