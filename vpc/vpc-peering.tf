################################################################################
# VPC Peering
################################################################################
resource "aws_vpc_peering_connection" "peering_connection" {
  count = var.enable_vpc_peering ? length(var.vpc_peering_connections) : 0

  vpc_id = aws_vpc.vpc.id

  peer_owner_id = var.vpc_peering_connections[count.index].peer_owner_id
  peer_region   = var.vpc_peering_connections[count.index].peer_region
  peer_vpc_id   = var.vpc_peering_connections[count.index].peer_vpc_id

  tags = { "Name" = join("-", [var.project, var.environment, aws_vpc.vpc.id, "to", var.vpc_peering_connections[count.index].peer_vpc_id, "vpc-pc"]) }

  depends_on = [aws_vpc.vpc]
}

resource "aws_route" "vpc_pc_routes_public_route_table" {
  count = var.enable_vpc_peering ? length(var.vpc_peering_connections) : 0

  route_table_id            = aws_route_table.public_routetable.id
  destination_cidr_block    = var.vpc_peering_connections[count.index].acceptor_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection[count.index].id

  depends_on = [aws_vpc_peering_connection.peering_connection]
}

resource "aws_route" "vpc_pc_routes_private_route_table" {
  count = var.enable_vpc_peering ? length(var.vpc_peering_connections) : 0

  route_table_id            = aws_route_table.private_routetable.id
  destination_cidr_block    = var.vpc_peering_connections[count.index].acceptor_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection[count.index].id

  depends_on = [aws_vpc_peering_connection.peering_connection]
}