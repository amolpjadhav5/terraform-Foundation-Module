locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  public_subnet_map = {
    for subnet in var.public_subnets : subnet.name => subnet
  }

  private_subnet_map = {
    for subnet in var.private_subnets : subnet.name => subnet
  }

  database_subnet_map = {
    for subnet in var.database_subnets : subnet.name => subnet
  }
}

resource "aws_vpc" "this" {
  cidr_block                           = var.vpc_cidr
  instance_tenancy                     = var.instance_tenancy
  enable_dns_support                   = var.enable_dns_support
  enable_dns_hostnames                 = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block     = var.assign_generated_ipv6_cidr_block
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  tags = merge(local.common_tags, var.vpc_tags, {
    Name = var.vpc_name != null ? var.vpc_name : "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, var.internet_gateway_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnet_map

  vpc_id                                         = aws_vpc.this.id
  cidr_block                                     = each.value.cidr_block
  availability_zone                              = each.value.availability_zone
  map_public_ip_on_launch                        = each.value.map_public_ip_on_launch
  assign_ipv6_address_on_creation                = each.value.assign_ipv6_address_on_creation
  private_dns_hostname_type_on_launch            = each.value.private_dns_hostname_type_on_launch
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch

  tags = merge(local.common_tags, var.public_subnet_tags, each.value.tags, {
    Name = each.value.name
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnet_map

  vpc_id                                         = aws_vpc.this.id
  cidr_block                                     = each.value.cidr_block
  availability_zone                              = each.value.availability_zone
  map_public_ip_on_launch                        = each.value.map_public_ip_on_launch
  assign_ipv6_address_on_creation                = each.value.assign_ipv6_address_on_creation
  private_dns_hostname_type_on_launch            = each.value.private_dns_hostname_type_on_launch
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch

  tags = merge(local.common_tags, var.private_subnet_tags, each.value.tags, {
    Name = each.value.name
    Tier = "private"
  })
}

resource "aws_subnet" "database" {
  for_each = local.database_subnet_map

  vpc_id                                         = aws_vpc.this.id
  cidr_block                                     = each.value.cidr_block
  availability_zone                              = each.value.availability_zone
  map_public_ip_on_launch                        = each.value.map_public_ip_on_launch
  assign_ipv6_address_on_creation                = each.value.assign_ipv6_address_on_creation
  private_dns_hostname_type_on_launch            = each.value.private_dns_hostname_type_on_launch
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch

  tags = merge(local.common_tags, var.database_subnet_tags, each.value.tags, {
    Name = each.value.name
    Tier = "database"
  })
}

resource "aws_route_table" "public" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, var.public_route_table_tags, {
    Name = "${local.name_prefix}-public-rt"
    Tier = "public"
  })
}

resource "aws_route" "public_internet_ipv4" {
  count = var.create_internet_gateway && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? {
    for subnet in var.public_subnets : subnet.name => subnet
    if contains(var.nat_gateway_subnet_names, subnet.name)
  } : {}

  domain = "vpc"

  tags = merge(local.common_tags, var.nat_eip_tags, {
    Name = "${each.key}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  for_each = aws_eip.nat

  allocation_id = each.value.id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(local.common_tags, var.nat_gateway_tags, {
    Name = "${each.key}-nat-gw"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  for_each = var.create_private_route_table_per_az ? {
    for subnet in var.private_subnets : subnet.name => subnet
  } : length(var.private_subnets) > 0 ? { shared = null } : {}

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, var.private_route_table_tags, {
    Name = each.key == "shared" ? "${local.name_prefix}-private-rt" : "${each.key}-rt"
    Tier = "private"
  })
}

resource "aws_route" "private_nat_ipv4" {
  for_each = var.enable_nat_gateway ? aws_route_table.private : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.create_private_route_table_per_az ? aws_nat_gateway.this[var.private_subnet_nat_gateway_map[each.key]].id : aws_nat_gateway.this[var.default_nat_gateway_subnet_name].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = var.create_private_route_table_per_az ? aws_route_table.private[each.key].id : aws_route_table.private["shared"].id
}

resource "aws_route_table" "database" {
  count  = length(var.database_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, var.database_route_table_tags, {
    Name = "${local.name_prefix}-database-rt"
    Tier = "database"
  })
}

resource "aws_route_table_association" "database" {
  for_each = aws_subnet.database

  subnet_id      = each.value.id
  route_table_id = aws_route_table.database[0].id
}

resource "aws_db_subnet_group" "this" {
  count = var.create_database_subnet_group && length(var.database_subnets) > 0 ? 1 : 0

  name        = var.database_subnet_group_name != null ? var.database_subnet_group_name : "${local.name_prefix}-db-subnet-group"
  description = var.database_subnet_group_description
  subnet_ids  = values(aws_subnet.database)[*].id

  tags = merge(local.common_tags, var.database_subnet_group_tags, {
    Name = var.database_subnet_group_name != null ? var.database_subnet_group_name : "${local.name_prefix}-db-subnet-group"
  })
}
