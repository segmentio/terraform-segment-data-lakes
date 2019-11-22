variable "name" {
  description = "The name of the role that will be created."
  type        = "string"
  default     = "segment-data-lake-role"
}

variable "segment_aws_account" {
  description = "ARN of the AWS account used by Segment to connect to your Data Lake."
  type        = "string"
  default     = "arn:aws:iam::798609480926:root"
}

variable "external_ids" {
  description = "The name of the role that will be created."
  type        = "list"
}

variable "s3_bucket" {
  description = "Name of the S3 bucket used by the Data Lake."
  type        = "string"
}

variable "glue_database_name" {
  description = "Name of the Glue database used by the Data Lake."
  type        = "string"
  default     = "segment"
}

variable "tags" {
  description = "A map of tags to add to all resources. A vendor=segment tag will be added automatically."
  type        = "map"
  default     = {}
}

locals {
  tags = "${merge(map("vendor", "segment"), var.tags)}"
}
