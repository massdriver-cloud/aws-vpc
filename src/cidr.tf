
locals {
  // can't interpolate resource names, so need a specific statement for every one of them
  vpc_cidrs = flatten([
    [for vpc in data.aws_vpc.us-east-1 : vpc.cidr_block],
    [for vpc in data.aws_vpc.us-east-2 : vpc.cidr_block],
    [for vpc in data.aws_vpc.us-west-1 : vpc.cidr_block],
    [for vpc in data.aws_vpc.us-west-2 : vpc.cidr_block],
    [for vpc in data.aws_vpc.ap-northeast-1 : vpc.cidr_block],
    [for vpc in data.aws_vpc.ap-northeast-2 : vpc.cidr_block],
    [for vpc in data.aws_vpc.ap-northeast-3 : vpc.cidr_block],
    [for vpc in data.aws_vpc.ap-southeast-1 : vpc.cidr_block],
    [for vpc in data.aws_vpc.ap-southeast-2 : vpc.cidr_block],
    [for vpc in data.aws_vpc.ap-south-1 : vpc.cidr_block],
    [for vpc in data.aws_vpc.ca-central-1 : vpc.cidr_block],
    [for vpc in data.aws_vpc.eu-central-1 : vpc.cidr_block],
    [for vpc in data.aws_vpc.eu-north-1 : vpc.cidr_block],
    [for vpc in data.aws_vpc.eu-west-1 : vpc.cidr_block],
    [for vpc in data.aws_vpc.eu-west-2 : vpc.cidr_block],
    [for vpc in data.aws_vpc.eu-west-3 : vpc.cidr_block],
  ])

  vpc_cidr = var.network.automatic ? utility_available_cidr.vpc.0.result : var.network.cidr
}

resource "utility_available_cidr" "vpc" {
  count      = var.network.automatic ? 1 : 0
  from_cidrs = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  used_cidrs = local.vpc_cidrs
  mask       = var.network.mask
}


// You can't create providers using a for_each, so we need to manually create one for every AWS region to check VPC CIDRs
// US Regions
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "us-east-1" {
  provider = aws.us-east-1
}
data "aws_vpc" "us-east-1" {
  provider = aws.us-east-1
  for_each = toset(data.aws_vpcs.us-east-1.ids)
  id       = each.key
}

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "us-east-2" {
  provider = aws.us-east-2
}
data "aws_vpc" "us-east-2" {
  provider = aws.us-east-2
  for_each = toset(data.aws_vpcs.us-east-2.ids)
  id       = each.key
}

provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "us-west-1" {
  provider = aws.us-west-1
}
data "aws_vpc" "us-west-1" {
  provider = aws.us-west-1
  for_each = toset(data.aws_vpcs.us-west-1.ids)
  id       = each.key
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "us-west-2" {
  provider = aws.us-west-2
}
data "aws_vpc" "us-west-2" {
  provider = aws.us-west-2
  for_each = toset(data.aws_vpcs.us-west-2.ids)
  id       = each.key
}

// AP Regions
provider "aws" {
  alias  = "ap-northeast-1"
  region = "ap-northeast-1"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "ap-northeast-1" {
  provider = aws.ap-northeast-1
}
data "aws_vpc" "ap-northeast-1" {
  provider = aws.ap-northeast-1
  for_each = toset(data.aws_vpcs.ap-northeast-1.ids)
  id       = each.key
}

provider "aws" {
  alias  = "ap-northeast-2"
  region = "ap-northeast-2"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "ap-northeast-2" {
  provider = aws.ap-northeast-2
}
data "aws_vpc" "ap-northeast-2" {
  provider = aws.ap-northeast-2
  for_each = toset(data.aws_vpcs.ap-northeast-2.ids)
  id       = each.key
}

provider "aws" {
  alias  = "ap-northeast-3"
  region = "ap-northeast-3"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "ap-northeast-3" {
  provider = aws.ap-northeast-3
}
data "aws_vpc" "ap-northeast-3" {
  provider = aws.ap-northeast-3
  for_each = toset(data.aws_vpcs.ap-northeast-3.ids)
  id       = each.key
}

provider "aws" {
  alias  = "ap-south-1"
  region = "ap-south-1"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "ap-south-1" {
  provider = aws.ap-south-1
}
data "aws_vpc" "ap-south-1" {
  provider = aws.ap-south-1
  for_each = toset(data.aws_vpcs.ap-south-1.ids)
  id       = each.key
}

provider "aws" {
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "ap-southeast-1" {
  provider = aws.ap-southeast-1
}
data "aws_vpc" "ap-southeast-1" {
  provider = aws.ap-southeast-1
  for_each = toset(data.aws_vpcs.ap-southeast-1.ids)
  id       = each.key
}

provider "aws" {
  alias  = "ap-southeast-2"
  region = "ap-southeast-2"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "ap-southeast-2" {
  provider = aws.ap-southeast-2
}
data "aws_vpc" "ap-southeast-2" {
  provider = aws.ap-southeast-2
  for_each = toset(data.aws_vpcs.ap-southeast-2.ids)
  id       = each.key
}

// CA Regions
provider "aws" {
  alias  = "ca-central-1"
  region = "ca-central-1"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "ca-central-1" {
  provider = aws.ca-central-1
}
data "aws_vpc" "ca-central-1" {
  provider = aws.ca-central-1
  for_each = toset(data.aws_vpcs.ca-central-1.ids)
  id       = each.key
}

// EU Regions
provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "eu-central-1" {
  provider = aws.eu-central-1
}
data "aws_vpc" "eu-central-1" {
  provider = aws.eu-central-1
  for_each = toset(data.aws_vpcs.eu-central-1.ids)
  id       = each.key
}

provider "aws" {
  alias  = "eu-north-1"
  region = "eu-north-1"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "eu-north-1" {
  provider = aws.eu-north-1
}
data "aws_vpc" "eu-north-1" {
  provider = aws.eu-north-1
  for_each = toset(data.aws_vpcs.eu-north-1.ids)
  id       = each.key
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "eu-west-1" {
  provider = aws.eu-west-1
}
data "aws_vpc" "eu-west-1" {
  provider = aws.eu-west-1
  for_each = toset(data.aws_vpcs.eu-west-1.ids)
  id       = each.key
}

provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "eu-west-2" {
  provider = aws.eu-west-2
}
data "aws_vpc" "eu-west-2" {
  provider = aws.eu-west-2
  for_each = toset(data.aws_vpcs.eu-west-2.ids)
  id       = each.key
}

provider "aws" {
  alias  = "eu-west-3"
  region = "eu-west-3"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "eu-west-3" {
  provider = aws.eu-west-3
}
data "aws_vpc" "eu-west-3" {
  provider = aws.eu-west-3
  for_each = toset(data.aws_vpcs.eu-west-3.ids)
  id       = each.key
}

// SA Regions
provider "aws" {
  alias  = "sa-east-1"
  region = "sa-east-1"
  assume_role {
    role_arn    = var.aws_authentication.data.arn
    external_id = var.aws_authentication.data.external_id
  }
}
data "aws_vpcs" "sa-east-1" {
  provider = aws.sa-east-1
}
data "aws_vpc" "sa-east-1" {
  provider = aws.sa-east-1
  for_each = toset(data.aws_vpcs.sa-east-1.ids)
  id       = each.key
}
