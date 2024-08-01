resource "google_cloud_scheduler_job" "trigger_function" {
  name        = var.name
  description = var.description
  project     = var.project_id
  region    = var.cf_region
  schedule = var.schedule  # Cron expression for the desired schedule
  time_zone = var.time_zone  # Set your desired time zone

  http_target {
    http_method = "POST"
    uri         = var.uri
    oidc_token {
      service_account_email = var.service_account_email
    }
  }

  retry_config {
    retry_count = var.retry_count
    min_backoff_duration = var.min_backoff_duration
    max_backoff_duration = var.max_backoff_duration
    max_retry_duration = var.max_retry_duration
  }
}
