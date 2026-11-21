# enabling resources
resource "google_project_service" "cloud_scheduler_api" {
  project            = var.project_id
  service            = "cloudscheduler.googleapis.com"
  disable_on_destroy = false
}

# HTTP-target scheduler jobs (e.g. trigger a Cloud Function on a cron schedule)
resource "google_cloud_scheduler_job" "http_jobs" {
  for_each = { for job in var.http_jobs : job.name => job }

  name             = "${each.value.name}-${var.stage_id}"
  description      = lookup(each.value, "description", null)
  schedule         = each.value.schedule
  time_zone        = lookup(each.value, "time_zone", "UTC")
  attempt_deadline = lookup(each.value, "attempt_deadline", "320s")

  retry_config {
    retry_count = lookup(each.value, "retry_count", 1)
  }

  http_target {
    http_method = each.value.http_method
    uri         = each.value.uri
    headers = {
      "Content-Type" = "application/json"
    }
  }

  depends_on = [google_project_service.cloud_scheduler_api]
}

# Pub/Sub-target scheduler jobs (e.g. publish a message on a cron schedule)
resource "google_cloud_scheduler_job" "pubsub_jobs" {
  for_each = { for job in var.pubsub_jobs : job.name => job }

  name        = "${each.value.name}-${var.stage_id}"
  description = lookup(each.value, "description", null)
  schedule    = each.value.schedule
  time_zone   = lookup(each.value, "time_zone", "UTC")

  pubsub_target {
    topic_name = "projects/${var.project_id}/topics/${each.value.topic}-${var.stage_id}"
    data       = base64encode(each.value.message)
  }

  depends_on = [google_project_service.cloud_scheduler_api]
}
