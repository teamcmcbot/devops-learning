# Create a Kinesis Stream
resource "aws_kinesis_stream" "devops-stream" {
  name        = "devops-stream"
  shard_count = 1

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

}

# Output the Kinesis Stream id, name, arn and tags_all
output "kinesis_stream_id" {
  value = aws_kinesis_stream.devops-stream.id
}
output "kinesis_stream_name" {
  value = aws_kinesis_stream.devops-stream.name
}
output "kinesis_stream_arn" {
  value = aws_kinesis_stream.devops-stream.arn
}
output "kinesis_stream_tags_all" {
  value = aws_kinesis_stream.devops-stream.tags_all
}
