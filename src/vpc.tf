resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.md_metadata.name_prefix
  }
}

resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id
}
