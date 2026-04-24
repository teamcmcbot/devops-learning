# - `kke_staging_bucket_name`:name of the bucket used.
output "kke_staging_bucket_name" {
    value = aws_s3_bucket.kke_staging_bucket.bucket
}

# - `kke_firehose_name`:name of the firehose delivery stream used.
output "kke_firehose_name" {
    value = aws_kinesis_firehose_delivery_stream.kke_firehose_stream.name
}

# - `kke_sns_topic_name`:name of the sns topic used.
output "kke_sns_topic_name" {
    value = aws_sns_topic.nautilus_sns_topic.name
}

# - `kke_cloudwatch_alarm_name`:name of the cloudwatch used.
output "kke_cloudwatch_alarm_name" {
    value = aws_cloudwatch_metric_alarm.kke_firehose_failures_alarm.alarm_name
}

# - `kke_ses_identity`:name of the ses identity used.
output "kke_ses_identity" {
    value = aws_ses_email_identity.kke_ses_identity.email
}
