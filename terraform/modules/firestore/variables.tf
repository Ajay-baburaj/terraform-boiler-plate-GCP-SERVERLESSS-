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

variable "indexes" {
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
