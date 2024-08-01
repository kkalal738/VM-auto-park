resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  project     = var.project_id
  location    = var.cf_region
  description = var.function_description

  build_config {
    runtime = var.runtime
    entry_point = var.entry_point
    environment_variables = var.build_environment_variables
    source {
      storage_source {
        bucket = var.bucket_name
        object = var.source_archive_object
      }
    }
  }

  service_config {
    max_instance_count = var.max_instance_count
    min_instance_count = var.min_instance_count
    available_memory   = var.available_memory
    available_cpu      = var.available_cpu
    timeout_seconds    = var.timeout_seconds
    environment_variables = var.service_environment_variables
    ingress_settings               = var.ingress_settings
    all_traffic_on_latest_revision = var.all_traffic_on_latest_revision
    service_account_email          = var.service_account_email
  }
}

