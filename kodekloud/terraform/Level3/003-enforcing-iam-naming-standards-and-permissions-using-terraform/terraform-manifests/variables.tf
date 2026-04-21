# - `KKE_PROJECT`: name of the project(must be non-empty).
variable "KKE_PROJECT" {
  description = "Name of the project (must be non-empty)."
  type        = string
  validation {
    condition     = length(trimspace(var.KKE_PROJECT)) > 0
    error_message = "KKE_PROJECT must be non-empty."
  }
}
# - `KKE_TEAM`: name of the team (only letters, digits, dashes or underscores)
variable "KKE_TEAM" {
  description = "Name of the team (only letters, digits, dashes or underscores)."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.KKE_TEAM))
    error_message = "KKE_TEAM must only contain letters, digits, dashes, or underscores."
  }
}
# - `KKE_ENVIRONMENT`: name of the environment
variable "KKE_ENVIRONMENT" {
  description = "Name of the environment."
  type        = string
}