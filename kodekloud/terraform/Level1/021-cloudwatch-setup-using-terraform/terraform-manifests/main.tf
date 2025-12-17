# Create Cloudwatch Log Group
resource "aws_cloudwatch_log_group" "devops_log_group" {
  name = "devops-log-group"
}

# Create Cloudwatch Log Stream
resource "aws_cloudwatch_log_stream" "devops_log_stream" {
  name           = "devops-log-stream"
  log_group_name = aws_cloudwatch_log_group.devops_log_group.name
}

# Output ARN of the Log Group and Log Stream
output "log_group_arn" {
  value = aws_cloudwatch_log_group.devops_log_group.arn
}
output "log_stream_arn" {
  value = aws_cloudwatch_log_stream.devops_log_stream.arn
} 
