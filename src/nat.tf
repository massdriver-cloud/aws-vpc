resource "aws_eip" "nat" {
  for_each = module.private_subnets_cidr.network_cidr_blocks

  vpc = true

  tags = {
    Name = "${var.md_metadata.name_prefix}-${each.key}-nat-gateway"
  }
}

# NAT gateways for use by the private subnets, but existing in the public subnets
resource "aws_nat_gateway" "private" {
  for_each = module.private_subnets_cidr.network_cidr_blocks

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${var.md_metadata.name_prefix}-private-${each.key}"
  }
}
