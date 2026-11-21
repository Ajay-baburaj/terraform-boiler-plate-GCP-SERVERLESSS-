module "commons" {
  source     = "../../modules/commons"
  project_id = var.project_id
}

module "api_gateway" {
  source                = "../../modules/api_gateway"
  project_id            = var.project_id
  service_account_email = var.service_account_email
  stage_id              = var.stage_id
  region                = var.region
  api_name              = var.api_name
  openapi_spec_path     = var.openapi_spec_path
}

module "firestore" {
  source     = "../../modules/firestore"
  project_id = var.project_id
  stage_id   = var.stage_id
  region     = var.region
  indexes    = var.firestore_indexes
}

module "schedulers" {
  source      = "../../modules/schedulers"
  project_id  = var.project_id
  stage_id    = var.stage_id
  region      = var.region
  http_jobs   = var.scheduler_http_jobs
  pubsub_jobs = var.scheduler_pubsub_jobs
}

module "pubsub" {
  source     = "../../modules/pubsub"
  project_id = var.project_id
  stage_id   = var.stage_id
  region     = var.region
  topics     = var.topics
}

module "cloud_functions" {
  source                   = "../../modules/cloud_functions"
  project_id               = var.project_id
  stage_id                 = var.stage_id
  region                   = var.region
  service_account_email    = var.service_account_email
  bucket_name              = var.bucket_name
  vpc_connector            = var.vpc_connector
  function_source_zip_path = var.function_source_zip_path
  http_functions           = var.http_functions
  event_functions          = var.event_functions
}

module "task" {
  source     = "../../modules/task"
  project_id = var.project_id
  stage_id   = var.stage_id
  region     = var.region
  queues     = var.task_queues
}
