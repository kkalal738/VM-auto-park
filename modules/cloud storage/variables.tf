variable "project_id" {
  description = "The project utilised for the storage bucket."
  type        = string
}

variable "bucket_name" {
  description = "The name of the storage bucket."
  type        = string
}

variable "bucket_location" {
  description = "The location of the storage bucket."
  type        = string
  default     = "US"
}

variable "purpose" {
  description = "The purpose of creating this bucket."
  type        = string
  default     = "autopark_implementation"
}