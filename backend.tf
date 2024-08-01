# For Tf_Backend configuration
terraform {
  backend "gcs" {
    bucket = "gce_tf_backend"
    prefix = "tf_statefile"
  }
}