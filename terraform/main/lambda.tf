# Lambda function configurations
locals {
  lambda_functions = ["get", "post", "delete"]
}

# Create Lambda functions recursively
resource "aws_lambda_function" "lambda_functions" {
  for_each = toset(local.lambda_functions)

  function_name = each.key
  runtime       = "python3.8"
  handler       = "device_data.lambda_handler"
  s3_bucket     = var.bucket_data_name
  s3_key        = "${each.key}.zip"
  role          = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
    }
  }
}

resource "aws_lambda_function" "s3_processor" {
  function_name = "extract_transform"
  runtime       = var.runtime
  role          = aws_iam_role.lambda_exec.arn
  handler       = "extract_transform.lambda_handler"
  s3_bucket     = var.bucket_data_name
  //filename      = "lambda_function.zip"
  s3_key  = "extract_transform.zip"
  timeout = 30
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.event_notifications.arn
    }
  }
}

resource "aws_lambda_function" "sns_to_dynamodb" {
  function_name = "load"
  runtime       = var.runtime
  role          = aws_iam_role.lambda_exec.arn
  handler       = "load.lambda_handler"
  s3_bucket     = var.bucket_data_name
  //filename      = "lambda_function.zip"
  s3_key  = "load.zip"
  timeout = 30
  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
    }
  }
}
