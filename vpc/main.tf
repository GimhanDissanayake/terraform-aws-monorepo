################################################################################
# VPC
################################################################################
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr

  instance_tenancy                     = var.instance_tenancy
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_dns_support                   = var.enable_dns_support
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  tags = { "Name" = join("-", [var.project, var.environment, "vpc"]) }
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  vpc_id = aws_vpc.vpc.id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

################################################################################
# Publiс Subnets
################################################################################
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = length(var.azs) > 0 ? var.azs : data.aws_availability_zones.available.names
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(local.availability_zones, count.index % length(data.aws_availability_zones.available.names))
  cidr_block        = element(var.public_subnets, count.index)

  tags = merge(
    { "Name" = join("-", [var.project, var.environment, "pub-sn", count.index + 1]) },
    var.public_subnet_tags
  )

  depends_on = [aws_vpc_ipv4_cidr_block_association.this]
}

resource "aws_route_table" "public_routetable" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { "Name" = join("-", [var.project, var.environment, "pub-routetable"]) }

  depends_on = [aws_internet_gateway.igw]
}

locals {
  public_subnet_count = length(var.public_subnets)
  public_subnet_ids   = [for subnet in aws_subnet.public_subnet : subnet.id]
  public_subnet_arns  = [for subnet in aws_subnet.public_subnet : subnet.arn]
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(local.public_subnet_ids, count.index)
  route_table_id = aws_route_table.public_routetable.id

  depends_on = [aws_subnet.public_subnet]
}

################################################################################
# Private Subnets
################################################################################
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(local.availability_zones, count.index % length(data.aws_availability_zones.available.names))
  cidr_block        = element(var.private_subnets, count.index)

  tags = merge(
    { "Name" = join("-", [var.project, var.environment, "pvt-sn", count.index + 1]) },
    var.private_subnet_tags
  )

  depends_on = [aws_vpc_ipv4_cidr_block_association.this]
}

resource "aws_route_table" "private_routetable" {
  vpc_id = aws_vpc.vpc.id

  tags = { "Name" = join("-", [var.project, var.environment, "pvt-routetable"]) }
}

locals {
  private_subnet_count = length(var.private_subnets)
  private_subnet_ids   = [for subnet in aws_subnet.private_subnet : subnet.id]
  private_subnet_arns  = [for subnet in aws_subnet.private_subnet : subnet.arn]
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(local.private_subnet_ids, count.index)
  route_table_id = aws_route_table.private_routetable.id

  depends_on = [aws_subnet.private_subnet]
}

################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = { "Name" = join("-", [var.project, var.environment, "igw"]) }
}

################################################################################
# NAT Gateway
################################################################################
resource "aws_eip" "nat_eip" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = { "Name" = join("-", [var.project, var.environment, "nat-eip"]) }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = { "Name" = join("-", [var.project, var.environment, "nat"]) }

  timeouts {
    create = "30m"
    delete = "30m"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "nat_gateway_private_route_table" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private_routetable.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id

  depends_on = [aws_nat_gateway.nat_gw]
}

################################################################################
# S3 Gateway Endpoint
################################################################################
data "aws_region" "current" {}
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  count = var.create_s3_gateway_endpoint ? 1 : 0

  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = { "Name" = join("-", [var.project, var.environment, "vpc-s3-gateway-endpoint"]) }
}

locals {
  route_table_ids = [aws_route_table.public_routetable.id, aws_route_table.private_routetable.id]
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway_endpoint_route_table_association" {
  for_each = var.create_s3_gateway_endpoint ? toset(local.route_table_ids) : toset([])

  route_table_id  = each.key
  vpc_endpoint_id = aws_vpc_endpoint.s3_gateway_endpoint[0].id
}
