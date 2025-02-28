output "api_gateway_url" {
  value       = aws_api_gateway_deployment.deployment.invoke_url
  description = "Base URL of the API Gateway"
}
