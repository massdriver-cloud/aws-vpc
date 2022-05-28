

# default table - empty for now as we don't have direct-routable subnets
resource "aws_default_route_table" "vpc" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${var.md_metadata.name_prefix}-default"
  }
}

# route tables for individual subnets, they use their own NAT gateways
resource "aws_route_table" "private" {
  for_each = module.private_subnets_cidr.network_cidr_blocks

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.md_metadata.name_prefix}-private-${each.key}"
  }
}

resource "aws_route" "private_nat_gateway" {
  for_each = module.private_subnets_cidr.network_cidr_blocks

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = module.private_subnets_cidr.network_cidr_blocks

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# public route table - just getting out to the Internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.md_metadata.name_prefix}-public"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  for_each = module.public_subnets_cidr.network_cidr_blocks

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}
