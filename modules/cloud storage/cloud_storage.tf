resource "google_storage_bucket" "autopark_bucket" {
  name     = var.bucket_name
  location = var.bucket_location
  project  = var.project_id

  # Bucket versioning
  versioning {
    enabled = true
  }

  # Define lifecycle rules
  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age        = 365
      with_state = "ANY"
    }
  }

  # Permissions regarding : uniform bucket-level access / public access prevention / force destroy
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true

  # Set bucket labels
  labels = {
    purpose = var.purpose
  }
}
