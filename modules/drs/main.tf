resource "aws_iam_role" "drs_replication_role" {
  name = var.drs_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "drs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "drs_replication_policy" {
  name = "${var.drs_role_name}-policy"
  role = aws_iam_role.drs_replication_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:CreateTags",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_key" "drs_kms_key" {
  description = "KMS key for DRS"
  key_usage   = "ENCRYPT_DECRYPT"
  alias       = var.kms_key_alias

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_vpc" "drs_vpc" {
  cidr_block = var.drs_vpc_cidr
}

resource "aws_subnet" "drs_subnet" {
  vpc_id     = aws_vpc.drs_vpc.id
  cidr_block = var.drs_subnet_cidr
}

resource "aws_security_group" "drs_id" {
  vpc_id = aws_vpc.drs_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "drs_log_group" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = 30
}

resource "aws_cloudtrail" "drs_trail" {
  name                          = "drs-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.drs_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
}

resource "aws_s3_bucket" "drs_bucket" {
  bucket = var.trail_bucket_name

  lifecycle_rule {
    for_each = { for rule in var.drs_bucket_lifecycle_rules : rule.id => rule }

    id     = each.value.id
    status = each.value.enabled ? "Enabled" : "Disabled"

    filter {
      prefix = each.value.prefix
      tags   = each.value.tags
    }

    expiration {
      days = each.value.expiration_days
    }

    transition {
      days          = each.value.transition_to_glacier_days
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      for_each = { for transition in each.value.noncurrent_version_transition : transition.storage_class => transition }

      storage_class = each.value.storage_class
      days          = each.value.noncurrent_days
    }
  }
}

resource "aws_drs_replication_configuration_template" "drs_replication_template" {
  name                         = var.drs_replication_template
  staging_area_subnet_id       = aws_subnet.drs_subnet.id
  staging_area_tags            = { "Name" = "DRS Staging Area" }
  use_dedicated_replication_server = false
  bandwidth_throttling         = 10000
  default_large_staging_disk_type = "gp2"
  ebs_encryption               = "DEFAULT"
  replicated_disks {
    device_name = "/dev/sda1"
    iops        = 3000
    throughput  = 125
  }
replication_servers_security_groups_ids = [aws_security_group.drs_id.id]
}
