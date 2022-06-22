locals {
  public_subnets = [
    for subnet in aws_subnet.public : {
      arn      = subnet.arn
      cidr     = subnet.cidr_block
      aws_zone = subnet.availability_zone
    }
  ]

  private_subnets = [
    for subnet in aws_subnet.private : {
      arn      = subnet.arn
      cidr     = subnet.cidr_block
      aws_zone = subnet.availability_zone
    }
  ]

  internal_subnets = [
    for subnet in aws_subnet.internal : {
      arn      = subnet.arn
      cidr     = subnet.cidr_block
      aws_zone = subnet.availability_zone
    }
  ]
}

resource "massdriver_artifact" "vpc" {
  field                = "vpc"
  provider_resource_id = aws_vpc.main.arn
  name                 = "AWS VPC ${var.md_metadata.name_prefix} (${aws_vpc.main.id})"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          arn              = aws_vpc.main.arn
          cidr             = aws_vpc.main.cidr_block
          private_subnets  = local.private_subnets
          public_subnets   = local.public_subnets
          internal_subnets = local.internal_subnets
        }
      }
      specs = {
        aws = {
          region = var.aws_region
        }
      }
    }
  )
}
