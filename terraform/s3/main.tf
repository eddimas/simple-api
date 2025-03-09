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


resource "aws_s3_bucket_notification" "s3_event_trigger" {
  bucket = aws_s3_bucket.device_raw_data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.device_raw_data_bucket.arn
}
