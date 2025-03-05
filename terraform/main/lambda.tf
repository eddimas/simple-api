# Lambda function configurations
locals {
  lambda_functions = ["get", "post", "delete"]
}

# Create Lambda functions recursively
resource "aws_lambda_function" "lambda_functions" {
  for_each = toset(local.lambda_functions)

  function_name = each.key
  runtime       = "python3.8"
  handler       = "${each.key}/device_data.lambda_handler"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = "${each.key}.zip"
  role          = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
    }
  }
}
