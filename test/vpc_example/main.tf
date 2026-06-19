module "vpc_foundation" {
  source = "../../Networking/VPC"

  project     = var.project
  environment = var.environment
  tags        = var.tags

  vpc_name                             = var.vpc_name
  vpc_cidr                             = var.vpc_cidr
  instance_tenancy                     = var.instance_tenancy
  enable_dns_support                   = var.enable_dns_support
  enable_dns_hostnames                 = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block     = var.assign_generated_ipv6_cidr_block
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  create_internet_gateway = var.create_internet_gateway

  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway                = var.enable_nat_gateway
  nat_gateway_subnet_names          = var.nat_gateway_subnet_names
  default_nat_gateway_subnet_name   = var.default_nat_gateway_subnet_name
  create_private_route_table_per_az = var.create_private_route_table_per_az
  private_subnet_nat_gateway_map    = var.private_subnet_nat_gateway_map

  create_database_subnet_group      = var.create_database_subnet_group
  database_subnet_group_name        = var.database_subnet_group_name
  database_subnet_group_description = var.database_subnet_group_description

  vpc_tags                   = var.vpc_tags
  internet_gateway_tags      = var.internet_gateway_tags
  public_subnet_tags         = var.public_subnet_tags
  private_subnet_tags        = var.private_subnet_tags
  database_subnet_tags       = var.database_subnet_tags
  public_route_table_tags    = var.public_route_table_tags
  private_route_table_tags   = var.private_route_table_tags
  database_route_table_tags  = var.database_route_table_tags
  nat_eip_tags               = var.nat_eip_tags
  nat_gateway_tags           = var.nat_gateway_tags
  database_subnet_group_tags = var.database_subnet_group_tags
}
