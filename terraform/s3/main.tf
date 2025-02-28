data "aws_s3_bucket" "existing_raw_data" {
  bucket = var.bucket_data_name
}

data "aws_s3_bucket" "existing_tfstate" {
  bucket = var.bucket_tfstate_name
}

resource "aws_s3_bucket" "raw_data" {
  count         = length(data.aws_s3_bucket.existing_raw_data.id) == 0 ? 1 : 0
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

resource "aws_s3_bucket" "terraform_state" {
  count         = length(data.aws_s3_bucket.existing_tfstate.id) == 0 ? 1 : 0
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
