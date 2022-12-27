resource "aws_vpc" "main" {
  cidr_block                           = local.vpc_cidr
  enable_dns_hostnames                 = true
  enable_network_address_usage_metrics = true

  tags = {
    Name = var.md_metadata.name_prefix
  }
}

resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.md_metadata.name_prefix}-default"
  }
}
