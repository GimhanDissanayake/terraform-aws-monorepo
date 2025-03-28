################################################################################
# VPC
################################################################################

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.vpc.arn
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = compact(aws_vpc_ipv4_cidr_block_association.this[*].cidr_block)
}

output "name" {
  description = "The name of the VPC"
  value       = join("-", [var.project, var.environment, "vpc"])
}

################################################################################
# Publiс Subnets
################################################################################

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = local.public_subnet_ids
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = local.public_subnet_arns
}

output "public_route_table_arn" {
  description = "Public route table arn"
  value       = aws_route_table.public_routetable.arn
}

output "public_route_table_id" {
  description = "Public route table id"
  value       = aws_route_table.public_routetable.id
}

################################################################################
# Private Subnets
################################################################################
output "private_subnets_ids" {
  description = "List of IDs of private subnets"
  value       = local.private_subnet_ids
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = local.private_subnet_arns
}

output "private_route_table_arn" {
  description = "private route table arn"
  value       = aws_route_table.private_routetable.arn
}

output "private_route_table_id" {
  description = "private route table id"
  value       = aws_route_table.private_routetable.id
}

################################################################################
# Internet Gateway
################################################################################
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = aws_internet_gateway.igw.arn
}

################################################################################
# NAT Gateway
################################################################################

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = try(aws_nat_gateway.nat_gw[*].id, null)
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = try(aws_nat_gateway.nat_gw[*].public_ip, null)
}

output "nat_gateway_private_ip" {
  description = "Private IP of the NAT Gateway"
  value       = try(aws_nat_gateway.nat_gw[*].private_ip, null)
}

################################################################################
# VPC Peering
################################################################################
output "vpc_peering_connection_ids" {
  description = "VPC peering connection ids"
  value       = try(aws_vpc_peering_connection.peering_connection[*].id, null)
}

output "vpc_peering_connection_accept_status" {
  description = "VPC peering connection accept status"
  value       = try(aws_vpc_peering_connection.peering_connection[*].accept_status, null)
}