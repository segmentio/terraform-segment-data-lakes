variable "tags" {
  description = "A map of tags to add to all resources. A vendor=segment tag will be added automatically (which is also used by the IAM policy to provide Segment access to submit jobs)."
  type        = "map"
  default     = {}
}

variable "s3_bucket" {
  description = "Name of the S3 bucket used by the Data Lake. The EMR cluster will be configured to store logs in this bucket."
  type        = "string"
}

variable "subnet_id" {
  description = "VPC subnet id where you want the job flow to launch. Cannot specify the cc1.4xlarge instance type for nodes of a job flow launched in a Amazon VPC."
  type        = "string"
  default     = ""
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

variable "instance_profile" {
  description = "Instance Profile for EC2 instances of the cluster assume this role."
  type        = "string"
}

locals {
  tags = "${merge(map("vendor", "segment"), var.tags)}"
}
