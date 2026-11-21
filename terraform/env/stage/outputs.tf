# Outputs from all modules
output "api_gateway_outputs" {
  value = module.api_gateway
}

output "firestore_outputs" {
  value = module.firestore
}

output "schedulers_outputs" {
  value = module.schedulers
}

output "pubsub_outputs" {
  value = module.pubsub
}

output "cloud_functions_outputs" {
  value = module.cloud_functions
}

output "task_outputs" {
  value = module.task
}
