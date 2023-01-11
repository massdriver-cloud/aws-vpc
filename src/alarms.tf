locals {
  // iterate accross the subnets summing the size of each subnet (subtracting 5 from each since 5 IPs are reserved per subnet)
  max_vpc_ip_addresses = sum([for subnet in [local.public_cidr_range, local.private_cidr_range, local.internal_cidr_range] : pow(2, 32 - tonumber(split("/", subnet)[1])) - (5 * length(cache_store.azs.value))])

  automated_ip_address_percent_threshold          = 90
  automated_nat_gateway_port_allocation_threshold = 1

  automated_alarms = {
    ip_address_utilization = {
      percent = local.automated_ip_address_percent_threshold
    }
    nat_gateway_port_allocation = {
      count = local.automated_nat_gateway_port_allocation_threshold
    }
  }
  alarms_map = {
    "AUTOMATED" = local.automated_alarms
    "DISABLED"  = {}
    "CUSTOM"    = lookup(var.monitoring, "alarms", {})
  }

  alarms = lookup(local.alarms_map, var.monitoring.mode, {})
}

module "alarm_channel" {
  source      = "github.com/massdriver-cloud/terraform-modules//aws/alarm-channel?ref=bafd9d9"
  md_metadata = var.md_metadata
}

module "ip_address_utilization" {
  count         = lookup(local.alarms, "ip_address_utilization", null) == null ? 0 : 1
  source        = "github.com/massdriver-cloud/terraform-modules//aws/cloudwatch-alarm?ref=bafd9d9"
  sns_topic_arn = module.alarm_channel.arn
  display_name  = "IP Address Availability"
  depends_on = [
    aws_vpc.main
  ]

  md_metadata         = var.md_metadata
  message             = "AWS VPC ${aws_vpc.main.id}: IP Address Utilization > ${local.alarms.ip_address_utilization.percent}%"
  alarm_name          = "${aws_vpc.main.id}-highIPAddressUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkAddressUsage"
  namespace           = "AWS/EC2"
  period              = 86400
  statistic           = "Maximum"
  threshold           = floor(local.max_vpc_ip_addresses * (local.alarms.ip_address_utilization.percent / 100))

  dimensions = {
    "Per-VPC Metrics" = aws_vpc.main.id
  }
}

module "nat_gateway_port_allocation" {
  source        = "github.com/massdriver-cloud/terraform-modules//aws/cloudwatch-alarm?ref=bafd9d9"
  for_each      = lookup(local.alarms, "nat_gateway_port_allocation", null) == null ? {} : local.nat_cidr_blocks
  sns_topic_arn = module.alarm_channel.arn
  display_name  = "NAT Gateway Port Allocation"
  depends_on = [
    aws_nat_gateway.private
  ]

  md_metadata         = var.md_metadata
  message             = "AWS NAT Gateway ${aws_nat_gateway.private[each.key].id}: Port Allocation Errors > ${local.alarms.nat_gateway_port_allocation.count}"
  alarm_name          = "${aws_nat_gateway.private[each.key].id}-highPortAllocationErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorPortAllocation"
  namespace           = "AWS/NATGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = local.alarms.nat_gateway_port_allocation.count

  dimensions = {
    "NatGatewayId" = aws_nat_gateway.private[each.key].id
  }
}
