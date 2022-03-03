variable "suffix" {
  description = "Optional suffix to the IAM roles/policies created by this module. Allows creating multiple such modules in the same AWS account. Common practice is to set the env here ie dev/stage/prod"
  type        = string
  default     = ""
}

variable "segment_aws_accounts" {
  description = "ARN of the AWS accounts used by Segment to connect to your Data Lake."
  type        = list(string)

  default = [
    "arn:aws:iam::294048959147:role/datalakes-aws-worker",
    "arn:aws:iam::294048959147:role/datalakes-customer-service",
    "arn:aws:iam::294048959147:role/customer-datalakes-prod-admin",
  ]
}

variable "external_ids" {
  description = "External IDs that will be used to assume the role. Segment will currently use the source ID as the external ID when connecting to your AWS account, and this should be a list of IDs of the sources that you want to connect to your Data Lake. These IDs are generated by Segment and can be retrieved from the Segment app."
  type        = list(string)
}

variable "s3_bucket" {
  description = "Name of the S3 bucket used by the Data Lake."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources. A vendor=segment tag will be added automatically."
  type        = map(string)
  default     = {}
}

locals {
  tags = merge(tomap("vendor", "segment"), var.tags)
}
