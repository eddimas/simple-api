# Create API Key for External Clients
resource "aws_api_gateway_api_key" "client_api_key" {
  name        = "client-api-key"
  description = "API Key for secured API access"
  enabled     = true
}

# Enable API Gateway Usage Plan
resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  name        = "api-usage-plan"
  description = "Usage plan for secured API Gateway"

  api_stages {
    api_id = aws_api_gateway_rest_api.device_event_api.id
    stage  = var.api_gw_stg_name
  }

  throttle_settings {
    rate_limit  = 10
    burst_limit = 5
  }
}

# Associate API Key with Usage Plan
resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.client_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_usage_plan.id
}
