module "lambda_function" {
  source = "${path.module}/modules/lambda_function"

  for_each = {
    get    = "get"
    post   = "post"
    delete = "delete"
  }

  function_name = each.key
  runtime       = var.runtime
  handler       = "${each.key}/device_data.lambda_handler"
  s3_bucket     = var.bucket_data_name
  s3_key        = "${each.value}.zip"
  role          = aws_iam_role.lambda_exec.arn
  environment_variables = {
    DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
  }
}
