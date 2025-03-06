# API Gateway REST API
resource "aws_api_gateway_rest_api" "device_event_api" {
  name        = var.api_gw_name
  description = var.api_gw_description
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resource
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.device_event_api.id
  parent_id   = aws_api_gateway_rest_api.device_event_api.root_resource_id
  path_part   = var.api_gw_path
}

# API Gateway Account for CloudWatch Logging
resource "aws_api_gateway_account" "apigw_logging" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_logging_role.arn
  depends_on          = [aws_iam_role.api_gateway_logging_role]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "apigw_stage" {
  depends_on    = [aws_cloudwatch_log_group.api_gw_logs]
  stage_name    = var.stage_name
  rest_api_id   = aws_api_gateway_rest_api.device_event_api.id
  deployment_id = aws_api_gateway_deployment.deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format          = "$context.requestId $context.identity.sourceIp $context.httpMethod $context.path $context.status"
  }
}

# IAM Role Policy Attachment for API Gateway Logging
resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.api_gateway_logging_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.get_method,
    aws_api_gateway_method.post_method,
    aws_api_gateway_method.delete_method
  ]

  rest_api_id = aws_api_gateway_rest_api.device_event_api.id
  stage_name  = var.stage_name
}

# Secure GET Method with API Key
resource "aws_api_gateway_method" "get_method" {
  rest_api_id      = aws_api_gateway_rest_api.device_event_api.id
  resource_id      = aws_api_gateway_resource.resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

# Integrate GET Method with AWS Lambda
resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.device_event_api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_functions["get"].invoke_arn
  credentials             = aws_iam_role.api_gateway_invoke_role.arn

  depends_on = [aws_api_gateway_method.get_method]
}

# Secure POST Method with API Key
resource "aws_api_gateway_method" "post_method" {
  rest_api_id      = aws_api_gateway_rest_api.device_event_api.id
  resource_id      = aws_api_gateway_resource.resource.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

# Integrate POST Method with AWS Lambda
resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.device_event_api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_functions["post"].invoke_arn
  credentials             = aws_iam_role.api_gateway_invoke_role.arn

  depends_on = [aws_api_gateway_method.post_method]
}

# Secure DELETE Method with API Key
resource "aws_api_gateway_method" "delete_method" {
  rest_api_id      = aws_api_gateway_rest_api.device_event_api.id
  resource_id      = aws_api_gateway_resource.resource.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = true
}

# Integrate DELETE Method with AWS Lambda
resource "aws_api_gateway_integration" "delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.device_event_api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.delete_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_functions["delete"].invoke_arn
  credentials             = aws_iam_role.api_gateway_invoke_role.arn

  depends_on = [aws_api_gateway_method.delete_method]
}

# API Gateway Method Settings
resource "aws_api_gateway_method_settings" "device_event_settings" {
  rest_api_id = aws_api_gateway_rest_api.device_event_api.id
  stage_name  = aws_api_gateway_stage.apigw_stage.stage_name
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}
