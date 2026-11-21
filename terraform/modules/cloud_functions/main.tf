resource "random_id" "rng" {
  keepers = {
    first = timestamp()
  }
  byte_length = 8
}

resource "google_project_service" "cloud_functions" {
  project            = var.project_id
  service            = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloud_build_api" {
  project            = var.project_id
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "default" {
  name                        = "${var.bucket_name}-${var.stage_id}"
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true
}

# Google Cloud Storage object holding the function source code archive
resource "google_storage_bucket_object" "function_source" {
  name   = "function-source-${var.stage_id}-${replace(lower(random_id.rng.id), "_", "-")}.zip"
  bucket = google_storage_bucket.default.name
  source = var.function_source_zip_path

  # Ensure existing object is not accidentally deleted
  lifecycle {
    prevent_destroy = false
  }
}

# HTTP-triggered functions (2nd Gen)
resource "google_cloudfunctions2_function" "http_function" {
  for_each = var.http_functions

  name        = "${each.value.name}-${var.stage_id}"
  description = each.value.description
  project     = var.project_id
  location    = var.region

  build_config {
    runtime     = var.runtime
    entry_point = each.value.entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.default.name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    available_memory      = "${lookup(each.value, "memory_mb", 256)}M"
    timeout_seconds       = lookup(each.value, "timeout_seconds", 3600)
    service_account_email = var.service_account_email
    min_instance_count    = var.min_instance_count
    ingress_settings      = var.ingress_settings
    vpc_connector         = "projects/${var.project_id}/locations/${var.region}/connectors/${var.vpc_connector}"
  }

  depends_on = [google_project_service.cloud_functions, google_project_service.cloud_build_api]

  lifecycle {
    create_before_destroy = true
  }
}

# Event-triggered functions (2nd Gen), subscribed to a Pub/Sub topic
resource "google_cloudfunctions2_function" "event_function" {
  for_each = var.event_functions

  name        = "${each.value.name}-${var.stage_id}"
  description = each.value.description
  project     = var.project_id
  location    = var.region

  build_config {
    runtime     = var.runtime
    entry_point = each.value.entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.default.name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    available_memory               = "${lookup(each.value, "memory_mb", 256)}M"
    timeout_seconds                = lookup(each.value, "timeout_seconds", 540)
    service_account_email          = var.service_account_email
    min_instance_count             = var.min_instance_count
    ingress_settings               = var.ingress_settings
    all_traffic_on_latest_revision = true
    vpc_connector                  = "projects/${var.project_id}/locations/${var.region}/connectors/${var.vpc_connector}"
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = "projects/${var.project_id}/topics/${each.value.pubsub_topic}-${var.stage_id}"
    retry_policy   = "RETRY_POLICY_RETRY"
  }

  depends_on = [google_project_service.cloud_functions, google_project_service.cloud_build_api]

  lifecycle {
    create_before_destroy = true
  }
}

# IAM binding for HTTP-triggered functions
resource "google_cloud_run_service_iam_binding" "http_function_invoker" {
  for_each = google_cloudfunctions2_function.http_function

  project  = var.project_id
  service  = lower(each.value.name)
  location = var.region
  role     = "roles/run.invoker"
  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}

# IAM binding for event-triggered functions
resource "google_cloud_run_service_iam_binding" "event_function_invoker" {
  for_each = google_cloudfunctions2_function.event_function

  project  = var.project_id
  service  = lower(each.value.name)
  location = var.region
  role     = "roles/run.invoker"
  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}
