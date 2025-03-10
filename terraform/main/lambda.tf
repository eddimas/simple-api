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


# resource "aws_lambda_function" "lambdas" {
#   for_each = local.lambda_functions

#   function_name = each.key
#   runtime       = "python3.8"
#   handler       = "device_data.lambda_handler"
#   s3_bucket     = var.bucket_data_name
#   s3_key        = "${each.key}.zip"
#   role          = aws_iam_role.lambda_exec.arn
#   timeout       = 30

#   environment {
#     variables = each.value.env_vars
#   }
# }


# locals {
#   # Define a map with all Lambda functions and their specific settings
#   lambda_functions = {
#     "get" = {
#       env_vars = {
#         DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
#       }
#     },
#     "post" = {
#       env_vars = {
#         DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
#       }
#     },
#     "delete" = {
#       env_vars = {
#         DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
#       }
#     },
#     "extract_transform" = {
#       env_vars = {
#         SNS_TOPIC_ARN = aws_sns_topic.event_notifications.arn
#       }
#     },
#     "load" = {
#       env_vars = {
#         DYNAMODB_TABLE = aws_dynamodb_table.processed_data.name
#       }
#     }
#   }
# }
