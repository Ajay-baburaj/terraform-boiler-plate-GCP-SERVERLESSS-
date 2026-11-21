swagger: "2.0"
info:
  title: Api-Gateway config
  description: Example API on API Gateway with a Google Cloud Functions backend
  version: 1.0.0
schemes:
- https
produces:
- application/json
paths:
  # Replace this sample path with your own routes, or point the module's
  # `openapi_spec_path` variable at a spec file maintained in your own
  # project. ${region}, ${project_id} and ${stage_id} are available as
  # template variables and resolve to the function's backend URL:
  # https://${region}-${project_id}.cloudfunctions.net/<functionName>-${stage_id}
  /health:
    options:
      summary: CORS configuration
      operationId: healthCors
      x-google-backend:
        address: https://${region}-${project_id}.cloudfunctions.net/corsFunction-${stage_id}
        disable_auth: false
      responses:
        "204":
          description: CORS preflight response
    get:
      summary: Health check endpoint
      operationId: health
      x-google-backend:
        address: https://${region}-${project_id}.cloudfunctions.net/health-${stage_id}
        disable_auth: false
      responses:
        "200":
          description: A successful response
