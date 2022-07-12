locals {
// Limiting each list to a maximum of 4 entries for 3 reasons:
// * The maximum EIPs per region is 5, so we must stay below 5 so our HA VPCs can deploy w/out a quota increase
// * Provisioning one of our VPCs won't exhaust all EIPs in a region with 5+ AZs
// * The CIDR math for 4 cleaner than 5
  fetched_azs = length(data.aws_availability_zones.azs.names) <= 4 ? data.aws_availability_zones.azs.names : slice(data.aws_availability_zones.azs.names, 0, 4)
}

data "aws_availability_zones" "azs" {
  filter {
    name   = "opt-in-status"
    values = ["opted-in", "opt-in-not-required"]
  }
  filter {
    name   = "region-name"
    values = [var.aws_region]
  }
  state = "available"
}

# cache the AZs so if we pull them dynamically and they change (an AZ is added), we don't break the bundle
resource "cache_store" "azs" {
  value = local.fetched_azs
}