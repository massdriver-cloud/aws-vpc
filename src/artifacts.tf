locals {
  public_subnets = [
    for subnet in aws_subnet.public : {
      arn = subnet.arn
    }
  ]

  private_subnets = [
    for subnet in aws_subnet.private : {
      arn = subnet.arn
    }
  ]

  internal_subnets = [
    for subnet in aws_subnet.internal : {
      arn = subnet.arn
    }
  ]
}

resource "massdriver_resource" "vpc" {
  field = "vpc"
  name  = "AWS VPC ${var.md_metadata.name_prefix} (${aws_vpc.main.id})"
  resource = jsonencode(
    {
      infrastructure = {
        arn              = aws_vpc.main.arn
        cidr             = aws_vpc.main.cidr_block
        private_subnets  = local.private_subnets
        public_subnets   = local.public_subnets
        internal_subnets = local.internal_subnets
      }
      specs = {
        aws = {
          region = var.aws_region
        }
      }
    }
  )
}
