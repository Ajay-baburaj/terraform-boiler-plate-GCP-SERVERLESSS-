terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.15.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.15.0"
    }
  }

  # GCS backend is left unconfigured here. Supply bucket/prefix via a
  # backend-config file (see backend.hcl.example) at `terraform init` time:
  #   terraform init -backend-config=backend.hcl
  backend "gcs" {}
}
