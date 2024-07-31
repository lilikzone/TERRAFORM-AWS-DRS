variable "drs_role_name" {
  description = "Name of the IAM role for DRS"
  type        = string
}

variable "drs_replication_template" {
  description = "Name of the DRS replication configuration template"
  type        = string
}

variable "drs_vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "drs_subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "kms_key_alias" {
  description = "Alias for the KMS key"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  type        = string
}

variable "trail_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
}

variable "drs_bucket_lifecycle_rules" {
  description = "Lifecycle rules for the DRS S3 bucket"
  type = list(object({
    id                            = string
    enabled                       = bool
    prefix                        = string
    tags                          = map(string)
    expiration_days               = number
    transition_to_glacier_days    = number
    noncurrent_version_transition = list(object({
      storage_class                = string
      noncurrent_days              = number
    }))
  }))
  default = []
}
