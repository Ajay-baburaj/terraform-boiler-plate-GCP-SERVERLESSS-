# Terraform GCP Infrastructure Template

A generic, project-agnostic Terraform layout for a serverless GCP backend:
API Gateway + Cloud Functions (2nd gen) + Firestore + Pub/Sub + Cloud
Scheduler + Cloud Tasks + Cloud Storage. All application-specific resources
(which functions exist, which Pub/Sub topics, which Firestore indexes,
which API routes, which scheduled jobs/queues) are supplied as input
variables with empty defaults, so this deploys as a bare skeleton until you
configure it for your own project.

## Structure

```
terraform/
├── env/
│   ├── dev/      # root module for the dev environment
│   └── stage/    # root module for the stage environment
└── modules/
    ├── api_gateway/      # API Gateway API + config + gateway
    ├── cloud_functions/  # HTTP + Pub/Sub event-triggered Cloud Functions
    ├── cloud_storage/    # generic GCS buckets
    ├── commons/          # enables the shared GCP APIs used by other modules
    ├── firestore/        # Firestore database + composite indexes
    ├── pubsub/           # Pub/Sub topics
    ├── schedulers/       # Cloud Scheduler HTTP/Pub/Sub jobs
    └── task/             # Cloud Tasks queues
```

Each `env/<name>` directory is a standalone root module: it declares
providers/version constraints (`versions.tf`), wires the shared modules
together (`main.tf`), and exposes the knobs you set per environment
(`variables.tf`). Add more environments (e.g. `env/prod`) by copying one of
the existing directories.

## Usage

1. `cd env/dev` (or `env/stage`)
2. Copy the example files and fill in your own values:
   ```
   cp terraform.tfvars.example terraform.tfvars
   cp backend.hcl.example backend.hcl
   ```
   Both `terraform.tfvars` and `backend.hcl` are gitignored — they hold
   project IDs, service account emails, and your state bucket, so they
   should never be committed.
3. Authenticate with GCP (Application Default Credentials; no service
   account key file is used by this template):
   ```
   gcloud auth application-default login
   ```
4. Initialize with your backend config and apply:
   ```
   terraform init -backend-config=backend.hcl
   terraform plan
   terraform apply
   ```

`.terraform.lock.hcl` is committed for each environment to pin provider
versions — don't delete it when you adopt this template elsewhere; let
`terraform init -upgrade` update it deliberately instead.

## Configuring your own application

All business-specific resources are empty by default. Populate the
relevant variables in your `terraform.tfvars` (shapes are documented in
each module's `variables.tf`):

| Variable | Module | Purpose |
|---|---|---|
| `http_functions` / `event_functions` | `cloud_functions` | Cloud Functions to deploy |
| `topics` | `pubsub` | Pub/Sub topics to create |
| `firestore_indexes` | `firestore` | Composite Firestore indexes |
| `scheduler_http_jobs` / `scheduler_pubsub_jobs` | `schedulers` | Cron jobs |
| `task_queues` | `task` | Cloud Tasks queues |
| `openapi_spec_path` | `api_gateway` | Path to your own OpenAPI spec template (defaults to a generic sample with a single `/health` route) |

The `api_gateway` module processes the spec at `openapi_spec_path` with
`templatefile`, exposing `region`, `project_id` and `stage_id` as template
variables — mirror the pattern in `modules/api_gateway/api-config.tpl` for
your own routes.
