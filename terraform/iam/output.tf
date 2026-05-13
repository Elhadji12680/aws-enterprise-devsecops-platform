output "rds_secrets_manager_role" {
  value = aws_iam_role.rds_secrets_manager_role.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}