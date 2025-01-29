
# resource "aws_route53_zone_association" "main" {
#   count = var.dns.enable_dns ? 1 : 0
#   zone_id = element(split("/", var.dns.hosted_zone_id), 1)
#   vpc_id  = aws_vpc.main.id
# }
