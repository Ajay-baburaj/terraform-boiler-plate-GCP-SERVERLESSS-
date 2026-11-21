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

variable "bucket_names" {
  description = "List of base bucket names to create (each gets the stage_id appended)"
  type        = list(string)
  default     = []
}
