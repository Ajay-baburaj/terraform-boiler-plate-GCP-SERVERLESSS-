# GCP Serverless Infrastructure Template

Reusable Terraform template for a serverless backend on Google Cloud:
**API Gateway → Cloud Functions (2nd gen) → Firestore / Pub/Sub / Cloud
Storage**, with Cloud Scheduler for cron jobs and Cloud Tasks for delayed
work. Every application-specific resource (which functions exist, which
topics, which Firestore indexes, which API routes) is supplied through
input variables with empty defaults — clone this, fill in your own
variables, and you get the same infrastructure shape for a different
project.

## Architecture

```
                                   ┌─────────────────┐
                 HTTPS requests    │   API Gateway    │
              ───────────────────▶│  (OpenAPI spec)  │
                                   └────────┬─────────┘
                                            │ routes to
                                            ▼
                  ┌─────────────────────────────────────────────┐
                  │        Cloud Functions (2nd gen)             │
                  │  ┌───────────────────┐  ┌──────────────────┐ │
                  │  │  HTTP functions    │  │  Event functions │ │
                  │  │  (one per route)   │  │  (Pub/Sub driven)│ │
                  │  └─────────┬─────────┘  └────────┬─────────┘ │
                  └────────────┼──────────────────────┼──────────┘
                                │                      ▲
                 reads/writes  │                      │ triggers on
                                ▼                      │ message
                  ┌──────────────────────┐   ┌───────────────────┐
                  │      Firestore        │   │    Pub/Sub topics  │
                  │  (native mode +       │   │  (fan-out, async   │
                  │   composite indexes)  │   │   workflows)       │
                  └──────────────────────┘   └─────────┬─────────┘
                                                         ▲
                              ┌──────────────────────────┤
                              │                          │
                     ┌────────┴────────┐       ┌─────────┴─────────┐
                     │  Cloud Scheduler │       │    Cloud Tasks     │
                     │  (cron: calls an │       │  (delayed/queued   │
                     │  HTTP function   │       │  one-off work,     │
                     │  or publishes to │       │  e.g. "wait 7 days │
                     │  a topic)        │       │  then notify")     │
                     └──────────────────┘       └────────────────────┘

                  Cloud Storage buckets hold the Cloud Functions source
                  archive, and any static/user-uploaded assets.

                  A shared service account + VPC connector is used by all
                  Cloud Functions; the `commons` module just enables the
                  GCP APIs every other module depends on.
```

**Request flow:** a client calls an API Gateway route → the gateway proxies
to the matching HTTP Cloud Function → the function reads/writes Firestore
and optionally publishes to a Pub/Sub topic for async work → a Pub/Sub
event function picks that up (e.g. to send an email, update a report,
etc.). Cloud Scheduler drives recurring jobs (reports, reminders) the same
way a client request would — by calling an HTTP function or publishing to
a topic on a cron schedule. Cloud Tasks handles one-off delayed work
(e.g. "notify the user 24 hours after they sign up") that doesn't fit a
fixed cron schedule.

## Repository layout

```
terraform/
├── env/
│   ├── dev/      # root module — dev environment
│   └── stage/    # root module — stage environment
└── modules/
    ├── api_gateway/      # API Gateway API + OpenAPI config + gateway
    ├── cloud_functions/  # HTTP + Pub/Sub event-triggered Cloud Functions
    ├── cloud_storage/    # generic GCS buckets
    ├── commons/          # enables the shared GCP APIs other modules need
    ├── firestore/        # Firestore database + composite indexes
    ├── pubsub/           # Pub/Sub topics
    ├── schedulers/       # Cloud Scheduler HTTP/Pub/Sub jobs
    └── task/             # Cloud Tasks queues
```

See [terraform/README.md](terraform/README.md) for setup steps (backend
config, tfvars, auth) and the full list of variables you populate to
describe your own application (functions, topics, indexes, routes,
scheduled jobs, queues).

## Why this shape

- **API Gateway** fronts everything with a single HTTPS endpoint, handles
  CORS, and maps each route to a backend Cloud Function — so routing logic
  lives in one OpenAPI spec rather than scattered across functions.
- **Cloud Functions (2nd gen)** run on Cloud Run under the hood, so HTTP
  and event-triggered functions share the same deploy model, scaling, and
  IAM.
- **Pub/Sub** decouples the request path from slower side effects (emails,
  reports, third-party sync) so API responses stay fast.
- **Cloud Scheduler** and **Cloud Tasks** cover the two shapes of
  "do this later": fixed recurring schedules vs. one-off delays triggered
  by an event.
- **Firestore** is the primary datastore; composite indexes are declared
  per-project since they depend entirely on your query patterns.

Every piece above is a separate Terraform module so you can adopt only
the pieces you need (e.g. drop `task` if you don't need delayed
one-off jobs) without touching the rest.
