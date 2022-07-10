locals {
  # honestly, there is probably an algorithm that can calculate this, but I'm too dumb
  # to figure it out and terraform would probably be too dumb to be able to support it
  num_azs_to_mask_bits = {
    1 = [0]
    2 = [1, 1]
    3 = [2, 2, 1]
    4 = [2, 2, 2, 2]
    5 = [3, 3, 2, 2, 2]
    6 = [3, 3, 3, 3, 2, 2]
    7 = [3, 3, 3, 3, 3, 3, 2],
    8 = [3, 3, 3, 3, 3, 3, 3, 3]
  }

  // Need to use a cache here to get the AZs
  azs = cache_store.azs.value

  public_cidr_range   = cidrsubnet(var.cidr, 2, 2)
  private_cidr_range  = cidrsubnet(var.cidr, 1, 0)
  internal_cidr_range = cidrsubnet(var.cidr, 3, 6)
  spare_cidr_range    = cidrsubnet(var.cidr, 3, 7)

  # hardcoding variables for this here. Down the road we may want to determine based on inputs
  create_public   = true
  create_private  = true
  create_internal = true
  create_spare    = true

  # down-select to a single private az to use in case we aren't doing high-availability
  # I'd prefer this to be a random AZ instead of the first one, but you can't do for_each
  # on a map that isn't determined until runtime, and the random provider violates that
  single_nat_az   = local.azs[0]
  nat_cidr_blocks = var.high_availability ? module.private_subnets_cidr.network_cidr_blocks : { (local.single_nat_az) = module.private_subnets_cidr.network_cidr_blocks[local.single_nat_az] }
}

# cache the AZs so if we pull them dynamically and they change (an AZ is added), we don't break the bundle
resource "cache_store" "azs" {
  value = local.az_region_map[var.aws_region]
}