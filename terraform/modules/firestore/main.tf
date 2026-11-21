# enabling firestore
resource "google_project_service" "firestore_api" {
  project            = var.project_id
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
}

resource "google_firestore_database" "firestore" {
  name                    = "${var.project_id}-${var.stage_id}"
  project                 = var.project_id
  location_id             = var.region
  type                    = "FIRESTORE_NATIVE"
  delete_protection_state = "DELETE_PROTECTION_DISABLED"
  deletion_policy         = "DELETE"
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [google_project_service.firestore_api]
}

resource "google_firestore_index" "indexes" {
  for_each = { for idx in var.indexes : "${idx.collection}-${idx.name}" => idx }

  project    = var.project_id
  database   = google_firestore_database.firestore.name
  collection = each.value.collection

  dynamic "fields" {
    for_each = each.value.fields
    content {
      field_path = fields.value.field_path
      order      = fields.value.order
    }
  }

  depends_on = [google_firestore_database.firestore]
}

output "firestore_database_id" {
  value = google_firestore_database.firestore.id
}
