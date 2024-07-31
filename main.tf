provider "aws" {
  region = "us-southeast-3"
}

resource "aws_iam_role" "drs_role" {
  name = "drs-replication-role"

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

resource "aws_iam_role_policy" "drs_policy" {
  name = "drs-replication-policy"
  role = aws_iam_role.drs_role.id

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

resource "aws_drs_replication_configuration_template" "example" {
  name                         = "drs-configuration"
  staging_area_subnet_id       = "subnet-0123456789abcdef"
  staging_area_tags            = { "Name" = "DRS Staging Area" }
  use_dedicated_replication_server = false
  bandwidth_throttling         = 10000
  ebs_encryption               = "DEFAULT"
  replicated_disks {
    device_name = "/dev/sda1"
    iops        = 3000
    throughput  = 125
  }
}

output "drs_replication_configuration_template_id" {
  value = aws_drs_replication_configuration_template.example.id
}
