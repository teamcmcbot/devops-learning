# `KKE_SNS_TOPIC_NAME`:name of the sns topic created.
# `KKE_ROLE_NAME`: name of the role created.
# `KKE_POLICY_NAME`: name of the policy created.

locals {
  KKE_SNS_TOPIC_NAME = "devops-sns-topic"
  KKE_ROLE_NAME      = "devops-sns-role"
  KKE_POLICY_NAME    = "devops-sns-policy"
}
