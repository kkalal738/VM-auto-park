
variable "function_name" {
  description = "Name of the Cloud Function"
  type        = string
}

variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "cf_region" {
  description = "Cloud Function region"
  type        = string
}

variable "function_description" {
  description = "Description of the Cloud Function"
  type        = string
}

variable "runtime" {
  description = "Runtime environment for the Cloud Function"
  type        = string
}

variable "entry_point" {
  description = "Entry point for the Cloud Function"
  type        = string
}

variable "build_environment_variables" {
  description = "Build environment variables for the Cloud Function"
  type        = map(string)
  default     = {}
}

variable "bucket_name" {
  description = "The name of the storage bucket."
  type        = string
}


variable "source_archive_object" {
  description = "Path to the source archive file"
  type        = string
}

variable "max_instance_count" {
  description = "Maximum number of instances for the Cloud Function"
  type        = number
  default     = 1
}

variable "min_instance_count" {
  description = "Minimum number of instances for the Cloud Function"
  type        = number
  default     = 0
}

variable "available_memory" {
  description = "Memory available to the Cloud Function"
  type        = string
}

variable "available_cpu" {
  description = "CPU available to the Cloud Function"
  type        = string
}

variable "timeout_seconds" {
  description = "Timeout for the Cloud Function"
  type        = number
}

variable "service_environment_variables" {
  description = "Environment variables for the Cloud Function"
  type        = map(string)
  default     = {}
}

variable "ingress_settings" {
  description = "Ingress settings for the Cloud Function"
  type        = string
}

variable "all_traffic_on_latest_revision" {
  description = "Whether all traffic should be directed to the latest revision"
  type        = bool
  default     = true
}

variable "service_account_email" {
  description = "Email of the existing service account"
  type        = string
}

