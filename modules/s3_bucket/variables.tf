variable "s3_bucket" {
  description = "Name of the S3 bucket used by the Data Lake. The EMR cluster will be configured to store logs in this bucket."
  type        = "string"
}

variable "tags" {
  description = "A map of tags to add to all resources. A vendor=segment tag will be added automatically."
  type        = "map"
  default     = {}
}

locals {
  tags = "${merge(map("vendor", "segment"), var.tags)}"
}
