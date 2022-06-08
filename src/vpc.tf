resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.md_metadata.name_prefix
  }
}

resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "${var.md_metadata.name_prefix}-alarms"
  # https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html
  delivery_policy = <<EOF
  {
    "http": {
      "defaultHealthyRetryPolicy": {
        "numNoDelayRetries": 5,
        "minDelayTarget": 1,
        "numMinDelayRetries": 5,
        "maxDelayTarget": 3,
        "numMaxDelayRetries": 5,
        "numRetries": 30
      },
      "disableSubscriptionOverrides": false
    }
  }
  EOF
}

resource "aws_sns_topic_subscription" "massdriver_cloudwatch_alarm_subscription" {
  endpoint  = var.md_metadata.observability.alarm_webhook_url
  protocol  = "https"
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
}