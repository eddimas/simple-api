
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



resource "aws_s3_bucket_notification" "s3_event_trigger" {
  bucket = var.device_csv_data_bucket

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
  source_arn    = aws_s3_bucket.device_csv_data_bucket.arn
}
