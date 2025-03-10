# Data Sources: Attempt to retrieve existing buckets
data "aws_s3_bucket" "existing_raw_data" {
  bucket = var.bucket_data_name
}

data "aws_s3_bucket" "existing_tfstate" {
  bucket = var.bucket_tfstate_name
}

data "aws_s3_bucket" "device_csv_data_bucket" {
  bucket = var.device_csv_data_bucket
}

# Locals to check if buckets exist
locals {
  # try() returns an empty string if the bucket isn’t found,
  # so length("") == 0 means it doesn’t exist.
  raw_data_bucket_exists   = length(try(data.aws_s3_bucket.existing_raw_data.id, "")) > 0
  tfstate_bucket_exists    = length(try(data.aws_s3_bucket.existing_tfstate.id, "")) > 0
  device_csv_bucket_exists = length(try(data.aws_s3_bucket.device_csv_data_bucket.id, "")) > 0
}

# Create Raw Data bucket only if it doesn't exist
resource "aws_s3_bucket" "raw_data" {
  count         = local.raw_data_bucket_exists ? 0 : 1
  bucket        = var.bucket_data_name
  force_destroy = true

  lifecycle_rule {
    id      = "expire-old-data"
    enabled = true
    expiration {
      days = 30
    }
  }
}

# Create Terraform State bucket only if it doesn't exist
resource "aws_s3_bucket" "terraform_state" {
  count         = local.tfstate_bucket_exists ? 0 : 1
  bucket        = var.bucket_tfstate_name
  force_destroy = true

  lifecycle_rule {
    id      = "terraform-state-retention"
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }
}

# Create Device CSV Data bucket only if it doesn't exist
resource "aws_s3_bucket" "device_raw_data_bucket" {
  count         = local.device_csv_bucket_exists ? 0 : 1
  bucket        = var.device_csv_data_bucket
  force_destroy = true

  lifecycle_rule {
    id      = "expire-old-data"
    enabled = true
    expiration {
      days = 30
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
