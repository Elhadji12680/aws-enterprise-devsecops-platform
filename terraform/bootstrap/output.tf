output "state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Paste this into the backend block in main.tf"
}

output "state_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}
