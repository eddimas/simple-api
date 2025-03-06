resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name = "/aws/apigateway/${aws_api_gateway_rest_api.device_event_api.name}"
  #name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.device_event_api.id}/${var.stage_name}"
  retention_in_days = 7
}
