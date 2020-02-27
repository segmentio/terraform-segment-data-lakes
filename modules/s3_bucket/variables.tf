variable "s3_bucket" {
  description = "Name of the S3 bucket used by the Data Lake. The EMR cluster will be configured to store logs in this bucket."
  type        = "string"
}
