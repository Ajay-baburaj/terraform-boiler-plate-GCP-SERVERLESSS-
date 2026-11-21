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

variable "http_jobs" {
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

variable "pubsub_jobs" {
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
