locals {
  flow_log_for_each = var.enable_flow_logs ? toset([var.md_metadata.name_prefix]) : toset([])
  # Hardcoding destination to cloudwatch for now
  flow_log_destination_type = "cloud-watch-logs"

  enable_cloudwatch_flow_log   = var.enable_flow_logs && local.flow_log_destination_type != "s3"
  cloudwatch_flow_log_for_each = local.enable_cloudwatch_flow_log ? toset([var.md_metadata.name_prefix]) : toset([])
  cloudwatch_flow_log_name     = "${var.md_metadata.name_prefix}-flow-log"
  cloudwatch_flow_log_arn      = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch_flow_log_name}"

  kms_key_arn_prefix = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/*"
}

################################################################################
# Flow Log
################################################################################

resource "aws_flow_log" "flow_log" {
  for_each = local.flow_log_for_each

  log_destination_type = local.flow_log_destination_type
  log_destination      = aws_cloudwatch_log_group.flow_log[each.key].arn
  iam_role_arn         = aws_iam_role.vpc_flow_log_cloudwatch[each.key].arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  tags = {
    Name = "${var.md_metadata.name_prefix}-flow-log"
  }
}

################################################################################
# Flow Log CloudWatch
################################################################################

data "aws_iam_policy_document" "flow_log_encryption_key_policy" {
  for_each = local.cloudwatch_flow_log_for_each

  statement {
    sid = "Enable IAM User Permissions"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = [local.kms_key_arn_prefix]
  }

  statement {
    sid = "AWSVPCFlowLogsKMSKey"
    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [local.kms_key_arn_prefix]
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = [local.cloudwatch_flow_log_arn]
    }
  }
}

resource "aws_kms_key" "flow_log_encryption_key" {
  for_each            = local.cloudwatch_flow_log_for_each
  description         = "${var.md_metadata.name_prefix}-flow-log encryption key"
  policy              = data.aws_iam_policy_document.flow_log_encryption_key_policy[each.key].json
  enable_key_rotation = true
  tags                = var.md_metadata.default_tags
}

resource "aws_kms_alias" "flow_log_encryption_key" {
  for_each      = local.cloudwatch_flow_log_for_each
  name          = "alias/${var.md_metadata.name_prefix}-flow-log"
  target_key_id = aws_kms_key.flow_log_encryption_key[each.key].key_id
}

resource "aws_cloudwatch_log_group" "flow_log" {
  for_each          = local.cloudwatch_flow_log_for_each
  name              = local.cloudwatch_flow_log_name
  retention_in_days = 30
  kms_key_id        = aws_kms_key.flow_log_encryption_key[each.key].arn
  tags              = var.md_metadata.default_tags
}

resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
  for_each           = local.cloudwatch_flow_log_for_each
  name               = "${var.md_metadata.name_prefix}-flow-log"
  assume_role_policy = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role[each.key].json
  tags               = var.md_metadata.default_tags
}

data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  for_each = local.cloudwatch_flow_log_for_each
  statement {
    sid = "AWSVPCFlowLogsAssumeRole"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  for_each   = local.cloudwatch_flow_log_for_each
  role       = aws_iam_role.vpc_flow_log_cloudwatch[each.key].name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch[each.key].arn
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  for_each    = local.cloudwatch_flow_log_for_each
  name_prefix = "vpc-flow-log-to-cloudwatch-"
  policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch[each.key].json
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
  for_each = local.cloudwatch_flow_log_for_each
  statement {
    sid = "AWSVPCFlowLogsPushToCloudWatch"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:PutRetentionPolicy",
      "logs:DescribeLogStreams",
    ]

    resources = [
      local.cloudwatch_flow_log_arn,
      "${local.cloudwatch_flow_log_arn}:log-stream:*",
    ]
  }
}
