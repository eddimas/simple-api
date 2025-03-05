
resource "aws_lambda_function" "event_processor" {
  function_name = "event_processor"
  runtime       = var.runtime
  handler       = "lambda_function.lambda_handler"
  s3_bucket     = var.bucket_data_name
  s3_key        = "event_processor.zip"
  role          = aws_iam_role.lambda_exec.arn
  environment {
    variables = {
      S3_BUCKET      = var.bucket_data_name,
      DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
    }
  }
}

resource "aws_lambda_function" "data_statistics" {
  function_name = "data_statistics"
  runtime       = var.runtime
  handler       = "statistics_function.lambda_handler"
  s3_bucket     = var.bucket_data_name
  s3_key        = "data_statistics.zip"
  role          = aws_iam_role.lambda_exec.arn
  environment {
    variables = {
      S3_BUCKET      = var.bucket_data_name,
      DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
    }
  }
}
