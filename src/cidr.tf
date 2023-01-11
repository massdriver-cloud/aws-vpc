
locals {
  // can't interpolate resource names, so need a specific statement for every one of them
  existing_vpc_cidrs = [for vpc in data.aws_vpc.existing_vpc : vpc.cidr_block]
  vpc_cidr           = var.network.automatic ? utility_available_cidr.vpc.0.result : var.network.cidr
}

data "aws_vpcs" "existing_vpcs" {}
data "aws_vpc" "existing_vpc" {
  for_each = toset(data.aws_vpcs.existing_vpcs.ids)
  id       = each.key
}

resource "utility_available_cidr" "vpc" {
  count      = var.network.automatic ? 1 : 0
  from_cidrs = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  used_cidrs = local.existing_vpc_cidrs
  mask       = var.network.mask
}
