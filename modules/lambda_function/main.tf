resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  runtime       = var.runtime
  handler       = var.handler
  role          = var.role
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key

  environment {
    variables = var.environment_variables
  }
}
