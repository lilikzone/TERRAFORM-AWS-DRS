output "drs_role_arn" {
  description = "ARN of the DRS IAM role"
  value       = aws_iam_role.drs_replication_role.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.drs_kms_key.arn
}
