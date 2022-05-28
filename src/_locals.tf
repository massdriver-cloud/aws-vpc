locals {
  az_region_map = {
    # "eu-central-1" = [
    #   "eu-central-1a",
    #   "eu-central-1b",
    #   "eu-central-1c"
    # ]
    # "eu-west-1" = [
    #   "eu-west-1a",
    #   "eu-west-1b",
    #   "eu-west-1c"
    # ]
    # "sa-east-1" = [
    #   "sa-east-1a",
    #   "sa-east-1b",
    #   "sa-east-1c"
    # ]
    "us-east-1" = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c",
      "us-east-1d",
      # "us-east-1e" us-east-1e is full (plus you're limited to 5 EIPs per region)
      "us-east-1f"
    ]
    "us-east-2" = [
      "us-east-2a",
      "us-east-2b",
      "us-east-2c"
    ]
    # "us-west-1" = [  AWS only allows new customers to use 2 AZs in us-west-1. We'll support this region when AWS allows 3+ AZs
    #   "us-west-1a",
    #   "us-west-1b",
    #   "us-west-1c"
    # ]
    "us-west-2" = [
      "us-west-2a",
      "us-west-2b",
      "us-west-2c",
      "us-west-2d"
    ]
  }

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
  azs = local.az_region_map[var.aws_region]

  public_cidr_range   = cidrsubnet(var.cidr, 2, 2)
  private_cidr_range  = cidrsubnet(var.cidr, 1, 0)
  internal_cidr_range = cidrsubnet(var.cidr, 3, 6)
  spare_cidr_range    = cidrsubnet(var.cidr, 3, 7)

  # hardcoding variables for this here. Down the road we may want to determine based on inputs
  create_public   = true
  create_private  = true
  create_internal = true
  create_spare    = true
}