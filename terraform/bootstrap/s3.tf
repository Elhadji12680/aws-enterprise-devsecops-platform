# TERRAFORM STATE BUCKET ---------------------------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = "jupiter-terraform-state-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "jupiter-terraform-state"
    Purpose     = "Terraform remote state storage"
    ManagedBy   = "terraform-bootstrap"
  }
}

data "aws_caller_identity" "current" {}

# VERSIONING — keeps full history of every state file change
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ENCRYPTION — AES-256 at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# BLOCK ALL PUBLIC ACCESS
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# LIFECYCLE — expire old non-current state versions after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  depends_on = [aws_s3_bucket_versioning.terraform_state]

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
