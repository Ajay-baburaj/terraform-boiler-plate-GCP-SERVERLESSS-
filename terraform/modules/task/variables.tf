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

variable "queues" {
  description = "List of Cloud Tasks queues to create"
  type = list(object({
    name                      = string
    max_attempts              = optional(number)
    max_doublings             = optional(number)
    max_dispatches_per_second = optional(number)
  }))
  default = []
}
