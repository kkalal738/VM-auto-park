variable "name" {
  description = "The name of the Cloud Scheduler job"
  type        = string
}

variable "description" {
  description = "The description of the Cloud Scheduler job"
  type        = string
}

variable "schedule" {
  description = "The cron schedule for the Cloud Scheduler job"
  type        = string
}


variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "cf_region" {
  description = "Region for the Cloud Function"
  type        = string
}
variable "time_zone" {
  description = "The time zone for the Cloud Scheduler job"
  type        = string
}

variable "uri" {
  description = "The URI to invoke for the Cloud Scheduler job"
  type        = string
}

variable "service_account_email" {
  description = "The service account email to use for the Cloud Scheduler job"
  type        = string
}

variable "retry_count" {
  description = "The number of retry attempts for the Cloud Scheduler job"
  type        = number
  default     = 3
}

variable "min_backoff_duration" {
  description = "The minimum backoff duration for retries"
  type        = string
  default     = "5s"
}

variable "max_backoff_duration" {
  description = "The maximum backoff duration for retries"
  type        = string
  default     = "10s"
}

variable "max_retry_duration" {
  description = "The maximum retry duration"
  type        = string
  default     = "60s"
}
