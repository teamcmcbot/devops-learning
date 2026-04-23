# - `KKE_ENV_TAGS`: `KKE_ENV_TAGS` is a map that holds environment-specific metadata such as bucket name, owner, and backup flag.
variable "KKE_ENV_TAGS" {
  description = "Environment-specific bucket metadata"
  type = map(object({
    bucket_name = string
    owner       = string
    backup      = bool
  }))

  default = {
    Dev = {
      bucket_name = "datacenter-dev-bucket-32108"
      owner       = "Alice"
      backup      = false
    }
    Staging = {
      bucket_name = "datacenter-staging-bucket-32108"
      owner       = "Bob"
      backup      = true
    }
    Prod = {
      bucket_name = "datacenter-prod-bucket-32108"
      owner       = "Carol"
      backup      = true
    }
  }
}