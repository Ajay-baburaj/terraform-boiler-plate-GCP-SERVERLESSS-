output "bucket_names" {
  value       = { for key, bucket in google_storage_bucket.buckets : key => bucket.name }
  description = "Map of requested bucket names to their actual created bucket names."
}
