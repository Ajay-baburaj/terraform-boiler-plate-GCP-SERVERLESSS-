resource "google_pubsub_topic" "topics" {
  for_each = var.topics

  name                       = "${each.value}-${var.stage_id}"
  message_retention_duration = var.message_retention_duration

  message_storage_policy {
    allowed_persistence_regions = [
      var.region
    ]
  }
}
