resource "aws_sns_topic" "this" {
  name = var.KKE_SNS_TOPIC_NAME
}