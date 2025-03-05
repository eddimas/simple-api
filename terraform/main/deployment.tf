resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.get_method,
    aws_api_gateway_method.post_method,
    aws_api_gateway_method.delete_method
  ]

  rest_api_id = aws_api_gateway_rest_api.device_event_api.id
  stage_name  = var.api_gw_stg_name
}
