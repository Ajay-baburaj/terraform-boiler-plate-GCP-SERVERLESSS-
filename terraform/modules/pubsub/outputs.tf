output "topic_ids" {
  value = {
    for key, topic in google_pubsub_topic.topics :
    key => topic.id
  }
  description = "Map of Pub/Sub topic names to their IDs."
}
