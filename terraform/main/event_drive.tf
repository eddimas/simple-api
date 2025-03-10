# Data Source for Existing S3 Bucket (Ensures the bucket exists)
data "aws_s3_bucket" "device_csv_data_bucket" {
  bucket = var.device_csv_data_bucket
}

# Lambda Function: Extract & Transform (Triggered by S3)
resource "aws_lambda_function" "extract_transform" {
  function_name = "extract_transform"
  runtime       = var.runtime
  role          = aws_iam_role.lambda_exec.arn
  handler       = "device_data.lambda_handler"
  s3_bucket     = var.bucket_data_name
  s3_key        = "extract_transform.zip"
  timeout       = 30

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.event_notifications.arn
    }
  }
}

# Lambda Function: Load (Triggered by SNS and writes to DynamoDB)
resource "aws_lambda_function" "load" {
  function_name = "load"
  runtime       = var.runtime
  role          = aws_iam_role.lambda_exec.arn
  handler       = "device_data.lambda_handler"
  s3_bucket     = var.bucket_data_name
  s3_key        = "load.zip"
  timeout       = 30

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
    }
  }
}

# Lambda Permission to Allow S3 to Invoke extract_transform Function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.extract_transform.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.device_csv_data_bucket.arn
}

# S3 Event Notification to Trigger extract_transform Lambda on Object Creation
resource "aws_s3_bucket_notification" "s3_event_trigger" {
  bucket = data.aws_s3_bucket.device_csv_data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.extract_transform.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3, aws_lambda_function.extract_transform]
}


/////////////
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.event_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.load.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.load.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.event_notifications.arn
}



resource "aws_iam_policy" "lambda_s3_read_policy" {
  name        = "lambda_s3_read_policy"
  description = "Allows Lambda to read objects from S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::${var.device_csv_data_bucket}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_read_attach" {
  policy_arn = aws_iam_policy.lambda_s3_read_policy.arn
  role       = aws_iam_role.lambda_exec.name
}
