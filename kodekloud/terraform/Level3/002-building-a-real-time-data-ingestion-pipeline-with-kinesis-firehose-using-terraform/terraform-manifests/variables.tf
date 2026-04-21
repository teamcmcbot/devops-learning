# - `KKE_S3_BUCKET_NAME`: name of the bucket.
variable "KKE_S3_BUCKET_NAME" {
  description = "Name of the S3 bucket to be created"
  type        = string
  default     = "nautilus-stream-bucket-22256"
}
# - `KKE_FIREHOSE_STREAM_NAME`: name of the firehose stream.
variable "KKE_FIREHOSE_STREAM_NAME" {
  description = "Name of the Kinesis Firehose stream to be created"
  type        = string
  default     = "nautilus-firehose-stream"
}
# - `KKE_FIREHOSE_ROLE_NAME` : name of the firehose role
variable "KKE_FIREHOSE_ROLE_NAME" {
  description = "Name of the IAM role for Kinesis Firehose"
  type        = string
  default     = "firehose-sts-role"
}