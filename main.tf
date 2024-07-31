provider "aws" {
  region = "us-west-2"
}

module "drs" {
  source                     = "./modules/drs"
  drs_role_name              = var.drs_role_name
  drs_replication_template   = var.drs_replication_template
  drs_vpc_cidr               = var.drs_vpc_cidr
  drs_subnet_cidr            = var.drs_subnet_cidr
  kms_key_alias              = var.kms_key_alias
  cloudwatch_log_group_name  = var.cloudwatch_log_group_name
  trail_bucket_name          = var.trail_bucket_name
  drs_bucket_lifecycle_rules = var.drs_bucket_lifecycle_rules
}
