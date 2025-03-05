# Lambda function configurations
data "aws_lambda_function" "lambda_configs" {
  for_each      = toset(["get", "post", "delete"])
  function_name = each.key
}

# Create Lambda functions recursively
resource "aws_lambda_function" "lambda_functions" {
  for_each = data.aws_lambda_function.lambda_configs

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
