# Output HTTP Trigger URLs
output "http_function_count" {
  value = length(google_cloudfunctions2_function.http_function)
}

output "event_function_count" {
  value = length(google_cloudfunctions2_function.event_function)
}