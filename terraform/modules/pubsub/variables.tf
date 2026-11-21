variable "stage_id" {
  description = "Environment/stage identifier appended to resource names"
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which to deploy resources"
  type        = string
}

variable "region" {
  description = "The region in which to deploy resources"
  type        = string
}

variable "topics" {
  description = "Map of topic keys to Pub/Sub topic names (without stage suffix) to create"
  type        = map(string)
  default     = {}
}

variable "message_retention_duration" {
  description = "Message retention duration for the topics, e.g. \"86600s\""
  type        = string
  default     = "86600s"
}
