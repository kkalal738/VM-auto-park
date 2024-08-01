module "cloud_storage_bucket" {
  source = "./modules/cloud storage"

  bucket_name     = var.bucket_name
  bucket_location = var.bucket_location
  project_id      = var.project_id
  #purpose         = var.purpose
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/scripts"
  output_path = "${path.module}/tmp/function.zip"
}

# Enable required APIs
module "enable_apis" {
  source = "./modules/enable apis"

  project_id = var.project_id
}

module "cloud_scheduler" {
  source = "./modules/cloud scheduler"
  project_id                     = var.project_id
  cf_region                      = var.cf_region
  name                  = "trigger-function-job"
  description           = "Trigger the Cloud Function every day at 16:10 except weekends"
  schedule              = "10 16 * * 1-5"
  time_zone             = "Asia/Kolkata"
  uri                   = "https://${var.cf_region}-${var.project_id}.cloudfunctions.net/${var.function_name}"
  service_account_email          = var.existing_service_account_email
  retry_count           = 3
  min_backoff_duration  = "5s"
  max_backoff_duration  = "10s"
  max_retry_duration    = "60s"

  depends_on = [
    google_project_service.cloud_scheduler,
    module.cloud_function
  ]
}
resource "null_resource" "upload_function_zip" {
  provisioner "local-exec" {
    command = "gsutil cp ${data.archive_file.source.output_path} gs://${var.bucket_name}/gce_source_code/function.zip"
  }

  triggers = {
    main_py_sha1          = filesha1("${path.module}/scripts/main.py")
    requirements_txt_sha1 = filesha1("${path.module}/scripts/requirements.txt")
    #function_zip_sha1 = filesha1("${path.module}/tmp/function.zip")
  }

  depends_on = [
    module.cloud_storage_bucket,
    data.archive_file.source
  ]
}
# locals {
#   create_service_account = var.create_new_service_account == 1
#   service_account_email  = local.create_service_account ? google_service_account.function_service_account[0].email : var.existing_service_account_email
# }

# # Conditionally create service account
# resource "google_service_account" "function_service_account" {
#   count = local.create_service_account ? 1 : 0

#   account_id   = "autopark-sa"
#   display_name = "Service Account for AutoPark Function"
#   project      = var.project_id
# }
resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${var.existing_service_account_email}"
}

resource "google_project_iam_member" "cloudscheduler_admin" {
  project = var.project_id
  role    = "roles/cloudscheduler.admin"
  member  = "serviceAccount:${var.existing_service_account_email}"
}

resource "google_project_iam_member" "cloudfunctions_developer" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${var.existing_service_account_email}"
}

resource "google_project_iam_member" "compute_instance_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${var.existing_service_account_email}"
}

resource "google_project_iam_member" "service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${var.existing_service_account_email}"
}

resource "google_project_iam_member" "container_cluster_viewer" {
  project = var.project_id
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${var.existing_service_account_email}"
}

resource "google_project_iam_member" "container_viewer" {
  project = var.project_id
  role    = "roles/container.viewer"
  member  = "serviceAccount:${var.existing_service_account_email}"
}

resource "google_project_iam_member" "run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${var.existing_service_account_email}"
}

resource "google_project_iam_member" "run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${var.existing_service_account_email}"
}

resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.createOnPushWriter"
  member  = "serviceAccount:${var.existing_service_account_email}"
}

# module "cloud_function" {
#   source = "./modules/cloud_function"

#   function_name                  = var.function_name
#   project_id                     = var.project_id
#   cf_region                      = var.cf_region
#   function_description           = var.function_description
#   runtime                        = var.runtime
#   entry_point                    = var.entry_point
#   build_environment_variables    = var.build_environment_variables
#   bucket_name                    = module.cloud_storage_bucket.bucket_name
#   source_archive_object          = var.source_archive_object
#   max_instance_count             = var.max_instance_count
#   min_instance_count             = var.min_instance_count
#   available_memory               = var.available_memory
#   available_cpu                  = var.available_cpu
#   timeout_seconds                = var.timeout_seconds
#   service_environment_variables  = var.service_environment_variables
#   ingress_settings               = var.ingress_settings
#   all_traffic_on_latest_revision = var.all_traffic_on_latest_revision
#   service_account_email          = local.service_account_email

#   depends_on = [
#     null_resource.upload_function_zip,
#     google_service_account.function_service_account,
#     google_project_iam_member.storage_admin,
#     google_project_iam_member.cloudscheduler_admin,
#     google_project_iam_member.compute_instance_admin,
#     google_project_iam_member.service_account_user,
#     google_project_iam_member.container_cluster_viewer,
#     google_project_iam_member.container_viewer,
#     google_project_iam_member.run_invoker,
#     google_project_iam_member.run_developer,
#     google_project_iam_member.artifact_registry_writer
#   ]
# }


module "cloud_function" {
  source = "./modules/cloud function"

  function_name                  = var.function_name
  project_id                     = var.project_id
  cf_region                      = var.cf_region
  function_description           = var.function_description
  runtime                        = var.runtime
  entry_point                    = "start_vms_scheduler"  # Ensure this matches your function
  build_environment_variables    = var.build_environment_variables
  bucket_name                    = module.cloud_storage_bucket.bucket_name
  source_archive_object          = var.source_archive_object
  max_instance_count             = var.max_instance_count
  min_instance_count             = var.min_instance_count
  available_memory               = var.available_memory
  available_cpu                  = var.available_cpu
  timeout_seconds                = var.timeout_seconds
  service_environment_variables  = var.service_environment_variables
  ingress_settings               = var.ingress_settings
  all_traffic_on_latest_revision = var.all_traffic_on_latest_revision
  service_account_email          = var.existing_service_account_email

  depends_on = [
    null_resource.upload_function_zip,
    google_project_iam_member.storage_admin,
    google_project_iam_member.cloudscheduler_admin,
    google_project_iam_member.compute_instance_admin,
    google_project_iam_member.service_account_user,
    google_project_iam_member.container_cluster_viewer,
    google_project_iam_member.container_viewer,
    google_project_iam_member.run_invoker,
    google_project_iam_member.run_developer,
    google_project_iam_member.artifact_registry_writer
  ]
}
