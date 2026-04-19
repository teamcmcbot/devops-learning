# `KKE_SECRET_NAME` for the secret name.
variable "KKE_SECRET_NAME" {
  description = "Name of the secret to be created in AWS Secrets Manager"
  type        = string
  default    = "xfusion-app-secret"
}
# `KKE_SECRET_VALUE` for the secret value.
variable "KKE_SECRET_VALUE" {
  description = "Value of the secret to be stored in AWS Secrets Manager"
  type        = string
  default = "{\"db_user\":\"admin\",\"db_pass\":\"supersecret\"}"
}
# `KKE_ROLE_NAME` for the IAM role name.
variable "KKE_ROLE_NAME" {
  description = "Name of the IAM role to be created"
  type        = string
  default    = "xfusion-app-role"
}
# `KKE_POLICY_NAME` for the IAM policy name.
variable "KKE_POLICY_NAME" {
  description = "Name of the IAM policy to be created"
  type        = string
  default    = "xfusion-app-policy"
}