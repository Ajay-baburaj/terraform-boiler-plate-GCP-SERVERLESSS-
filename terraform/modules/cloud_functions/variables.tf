variable "project_id" {
  description = "The ID of the project in which to deploy resources"
  type        = string
}

variable "region" {
  description = "The region in which to deploy resources"
  type        = string
}

variable "stage_id" {
  description = "Environment/stage identifier appended to resource names"
  type        = string
}

variable "bucket_name" {
  description = "The name of the storage bucket used to hold the function source archive"
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account to grant roles"
  type        = string
}

variable "vpc_connector" {
  description = "The vpc connector for cloud functions"
  type        = string
}

variable "function_source_zip_path" {
  description = "Local path to the zipped function source code to upload"
  type        = string
}

variable "runtime" {
  description = "Cloud Functions runtime to use for all functions"
  type        = string
  default     = "nodejs20"
}

variable "min_instance_count" {
  description = "Minimum number of instances to keep warm for each function"
  type        = number
  default     = 0
}

variable "ingress_settings" {
  description = "Ingress settings applied to all functions"
  type        = string
  default     = "ALLOW_ALL"
}

variable "http_functions" {
  description = "Map of HTTP-triggered Cloud Functions to deploy"
  type = map(object({
    name            = string
    description     = string
    entry_point     = string
    memory_mb       = optional(number)
    timeout_seconds = optional(number)
  }))
  default = {}
}

variable "event_functions" {
  description = "Map of Pub/Sub event-triggered Cloud Functions to deploy"
  type = map(object({
    name            = string
    description     = string
    entry_point     = string
    pubsub_topic    = string
    memory_mb       = optional(number)
    timeout_seconds = optional(number)
  }))
  default = {}
}
