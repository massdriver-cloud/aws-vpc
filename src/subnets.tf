module "public_subnets_cidr" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = local.public_cidr_range
  networks = local.create_public ? [
    for az, mask in zipmap(local.azs, local.num_azs_to_mask_bits[length(local.azs)]) : {
      name     = az
      new_bits = mask
    }
  ] : []
}

module "private_subnets_cidr" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = local.private_cidr_range
  networks = local.create_private ? [
    for az, mask in zipmap(local.azs, local.num_azs_to_mask_bits[length(local.azs)]) : {
      name     = az
      new_bits = mask
    }
  ] : []
}

module "internal_subnets_cidr" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = local.internal_cidr_range
  networks = local.create_internal ? [
    for az, mask in zipmap(local.azs, local.num_azs_to_mask_bits[length(local.azs)]) : {
      name     = az
      new_bits = mask
    }
  ] : []
}


resource "aws_subnet" "private" {
  for_each = module.private_subnets_cidr.network_cidr_blocks

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name                              = "${var.md_metadata.name_prefix}-private-${each.key}"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "internal" {
  for_each = module.internal_subnets_cidr.network_cidr_blocks

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "${var.md_metadata.name_prefix}-internal-${each.key}"
  }
}

resource "aws_subnet" "public" {
  for_each = module.public_subnets_cidr.network_cidr_blocks

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name                     = "${var.md_metadata.name_prefix}-public-${each.key}"
    "kubernetes.io/role/elb" = 1
  }
}
