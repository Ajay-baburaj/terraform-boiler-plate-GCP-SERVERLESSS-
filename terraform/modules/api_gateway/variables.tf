variable "project_id" {
  description = "The ID of the project in which to deploy resources"
  type        = string
}

variable "region" {
  description = "The region in which to deploy resources"
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account to grant roles"
  type        = string
}

variable "stage_id" {
  description = "Environment/stage identifier appended to resource names"
  type        = string
}

variable "api_name" {
  description = "Base name used for the API Gateway API and gateway resources"
  type        = string
  default     = "api"
}

variable "openapi_spec_path" {
  description = "Path to an OpenAPI/Swagger spec template file (processed with templatefile, exposing region, project_id and stage_id variables). Defaults to the module's own generic sample spec when left null."
  type        = string
  default     = null
}
