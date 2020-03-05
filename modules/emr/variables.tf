variable "s3_bucket" {
  description = "Name of the S3 bucket used by the Data Lake. The EMR cluster will be configured to store logs in this bucket."
  type        = "string"
}

variable "subnet_id" {
  description = "VPC subnet id where you want the job flow to launch. Cannot specify the cc1.4xlarge instance type for nodes of a job flow launched in a Amazon VPC."
  type        = "string"
}

variable "master_security_group" {
  description = "Identifier of the Amazon EC2 EMR-Managed security group for the master node."
  type        = "string"
  default     = ""
}

variable "slave_security_group" {
  description = "Identifier of the Amazon EC2 EMR-Managed security group for the slave nodes."
  type        = "string"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources. A vendor=segment tag will be added automatically (which is also used by the IAM policy to provide Segment access to submit jobs)."
  type        = "map"
  default     = {}
}

variable "cluster_name" {
  description = "Name of the EMR cluster that the module creates"
  type        = "string"
  default     = "segment-data-lake"
}

variable "emr_logs_s3_prefix" {
  description = "Prefix for writing EMR cluster logs to S3. Make sure to include a trailing slash (/) when setting this."
  type        = "string"
  default     = "logs/"
}

locals {
  tags = "${merge(map("vendor", "segment"), var.tags)}"
}
