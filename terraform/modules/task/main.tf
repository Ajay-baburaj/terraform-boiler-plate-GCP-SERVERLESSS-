# Enable Cloud Tasks API
resource "google_project_service" "cloud_tasks" {
  project            = var.project_id
  service            = "cloudtasks.googleapis.com"
  disable_on_destroy = false
}

# Cloud Tasks queues, ensuring each waits for the API to be enabled
resource "google_cloud_tasks_queue" "queues" {
  for_each = { for q in var.queues : q.name => q }

  name     = "${each.value.name}-${var.stage_id}"
  location = var.region

  retry_config {
    max_attempts  = lookup(each.value, "max_attempts", 1)
    max_doublings = lookup(each.value, "max_doublings", 0)
  }

  rate_limits {
    max_dispatches_per_second = lookup(each.value, "max_dispatches_per_second", 500)
  }

  depends_on = [google_project_service.cloud_tasks]
}
