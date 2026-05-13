provider "aws" {
  region = "us-east-1"
}

# Uses local backend — this config exists only to create the S3 bucket
# that the main infrastructure config uses as its remote backend.
# Run this once before running terraform init in the root directory.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
