# This file contains the Terraform configuration for creating an S3 bucket to store the Terraform state file.
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "tickerops-tfstate-921499350264"

  tags = {
    Project = "tickerops"
    Purpose = "terraform-state"
  }
  lifecycle {
    prevent_destroy = true
  }

}

# This file contains the Terraform configuration for enabling versioning, server-side encryption, and public access block on the S3 bucket created in the previous file.
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# This file contains the Terraform configuration for enabling server-side encryption on the S3 bucket created in the previous file.
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# This file contains the Terraform configuration for enabling public access block on the S3 bucket created in the previous file.
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}