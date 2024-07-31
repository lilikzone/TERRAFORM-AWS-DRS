output "drs_role_arn" {
  description = "ARN of the DRS IAM role"
  value       = module.drs.drs_role_arn
}

output "drs_kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.drs.kms_key_arn
}
