# Create API Key for External Clients
resource "aws_api_gateway_api_key" "client_api_key" {
  name        = var.api_key_name
  description = var.api_key_description
  enabled     = true
}

# Enable API Gateway Usage Plan
resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  name        = var.usage_plan_name
  description = var.usage_plan_description

  api_stages {
    api_id = aws_api_gateway_rest_api.device_event_api.id
    stage  = var.stage_name
  }

  throttle_settings {
    rate_limit  = var.rate_limit
    burst_limit = var.burst_limit
  }
}

# Associate API Key with Usage Plan
resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.client_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_usage_plan.id
}
