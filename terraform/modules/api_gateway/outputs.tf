output "api_gateway_endpoint" {
  value       = "https://${google_api_gateway_gateway.gateway_gateway.default_hostname}"
  description = "The API Gateway endpoint URL"
}
