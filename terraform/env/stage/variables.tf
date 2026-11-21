variable "project_id" {
  description = "The ID of the project in which to deploy resources"
  type        = string
}

variable "region" {
  description = "The region in which to deploy resources"
  type        = string
  default     = "us-east1"
}

variable "service_account_email" {
  description = "The email of the service account to grant roles"
  type        = string
}

variable "stage_id" {
  description = "Environment/stage identifier used to make resource names unique"
  type        = string
  default     = "stage"
}

variable "bucket_name" {
  description = "Base name of the storage bucket used to hold the Cloud Functions source archive"
  type        = string
  default     = "function-source"
}

variable "vpc_connector" {
  description = "Name of the Serverless VPC Access connector used by Cloud Functions"
  type        = string
}

variable "function_source_zip_path" {
  description = "Local path to the zipped function source code to upload"
  type        = string
  default     = "../../../zip/function_source.zip"
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

variable "topics" {
  description = "Map of Pub/Sub topic keys to topic names to create"
  type        = map(string)
  default     = {}
}

variable "firestore_indexes" {
  description = "List of composite Firestore indexes to create"
  type = list(object({
    name       = string
    collection = string
    fields = list(object({
      field_path = string
      order      = string
    }))
  }))
  default = []
}

variable "scheduler_http_jobs" {
  description = "List of Cloud Scheduler jobs that call an HTTP endpoint"
  type = list(object({
    name             = string
    description      = optional(string)
    schedule         = string
    time_zone        = optional(string)
    attempt_deadline = optional(string)
    retry_count      = optional(number)
    http_method      = string
    uri              = string
  }))
  default = []
}

variable "scheduler_pubsub_jobs" {
  description = "List of Cloud Scheduler jobs that publish a message to a Pub/Sub topic"
  type = list(object({
    name        = string
    description = optional(string)
    schedule    = string
    time_zone   = optional(string)
    topic       = string
    message     = string
  }))
  default = []
}

variable "task_queues" {
  description = "List of Cloud Tasks queues to create"
  type = list(object({
    name                      = string
    max_attempts              = optional(number)
    max_doublings             = optional(number)
    max_dispatches_per_second = optional(number)
  }))
  default = []
}

variable "api_name" {
  description = "Base name used for the API Gateway API and gateway resources"
  type        = string
  default     = "api"
}

variable "openapi_spec_path" {
  description = "Optional path to a custom OpenAPI spec template; defaults to the module's generic sample spec"
  type        = string
  default     = null
}
