# Create SNS Topic
resource "aws_sns_topic" "nautilus-notifications" {
  name = "nautilus-notifications"
}

# Output the SNS Topic ARN, id, tags_all
output "sns_topic_arn" {
  value = aws_sns_topic.nautilus-notifications.arn
}
output "sns_topic_id" {
  value = aws_sns_topic.nautilus-notifications.id
}
output "sns_topic_tags_all" {
  value = aws_sns_topic.nautilus-notifications.tags_all
}
