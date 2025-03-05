resource "aws_api_gateway_rest_api" "device_event_api" {
  name        = var.api_gw_name
  description = var.api_gw_description
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.device_event_api.id
  parent_id   = aws_api_gateway_rest_api.device_event_api.root_resource_id
  path_part   = var.api_gw_path
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
  integration_http_method = "GET"
  uri                     = aws_lambda_function.lambda_functions["get"].invoke_arn
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
  integration_http_method = "DELETE"
  uri                     = aws_lambda_function.lambda_functions["delete"].invoke_arn
}
