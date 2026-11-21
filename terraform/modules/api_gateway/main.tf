# enabling resources
resource "google_project_service" "service_api_gateway_enable" {
  project            = var.project_id
  service            = "apigateway.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "service_management_api_enable" {
  project            = var.project_id
  service            = "servicemanagement.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "service_control_api_enable" {
  project            = var.project_id
  service            = "servicecontrol.googleapis.com"
  disable_on_destroy = false
}

resource "random_id" "rng" {
  keepers = {
    first = timestamp()
  }
  byte_length = 8
}

# API Gateway API creation
resource "google_api_gateway_api" "_api_gateway_api" {
  provider     = google-beta
  api_id       = "${var.api_name}-${var.stage_id}"
  display_name = "${var.api_name}-${var.stage_id}"

  depends_on = [
    google_project_service.service_api_gateway_enable,
    google_project_service.service_management_api_enable,
    google_project_service.service_control_api_enable,
  ]
}

locals {
  openapi_spec_path = coalesce(var.openapi_spec_path, "${path.module}/api-config.tpl")
}

resource "local_file" "api_config_updated" {
  content = templatefile(local.openapi_spec_path, {
    stage_id   = var.stage_id
    project_id = var.project_id
    region     = var.region
  })
  filename = "${path.module}/api-config-updated.yaml"
}

# API Gateway Configuration
resource "google_api_gateway_api_config" "api_cfg" {
  provider      = google-beta
  api           = google_api_gateway_api._api_gateway_api.api_id
  api_config_id = "config-${replace(lower(random_id.rng.id), "_", "-")}"

  gateway_config {
    backend_config {
      google_service_account = var.service_account_email
    }
  }

  openapi_documents {
    document {
      path     = local_file.api_config_updated.filename
      contents = base64encode(local_file.api_config_updated.content)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_project_service.service_api_gateway_enable,
    google_project_service.service_management_api_enable,
    google_project_service.service_control_api_enable,
    local_file.api_config_updated,
  ]
}

# API Gateway instance creation
resource "google_api_gateway_gateway" "gateway_gateway" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_cfg.id
  gateway_id = "${var.api_name}-${var.stage_id}"
  project    = var.project_id
  region     = var.region

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_api_gateway_api_config.api_cfg,
    google_project_service.service_api_gateway_enable,
    google_project_service.service_management_api_enable,
    google_project_service.service_control_api_enable,
  ]
}
