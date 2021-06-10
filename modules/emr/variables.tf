variable "s3_bucket" {
  description = "Name of the S3 bucket used by the Data Lake. The EMR cluster will be configured to store logs in this bucket."
  type        = string
}

variable "subnet_id" {
  description = "VPC subnet id where you want the job flow to launch. Cannot specify the cc1.4xlarge instance type for nodes of a job flow launched in a Amazon VPC."
  type        = string
}

variable "master_security_group" {
  description = "Identifier of the Amazon EC2 EMR-Managed security group for the master node."
  type        = string
  default     = ""
}

variable "slave_security_group" {
  description = "Identifier of the Amazon EC2 EMR-Managed security group for the slave nodes."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources. A vendor=segment tag will be added automatically (which is also used by the IAM policy to provide Segment access to submit jobs)."
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the EMR cluster that the module creates"
  type        = string
  default     = "segment-data-lake"
}

variable "master_instance_name" {
  description = "Name of the master instance group."
  type        = string
  default     = "master_group"
}

variable "core_instance_name" {
  description = "Name of the core instance group."
  type        = string
  default     = "core_group"
}

variable "task_group_name" {
  description = "Name of the task group."
  type        = string
  default     = "task_group"
}


variable "emr_logs_s3_prefix" {
  description = "Prefix for writing EMR cluster logs to S3. Make sure to include a trailing slash (/) when setting this."
  type        = string
  default     = "logs/"
}

variable "iam_emr_service_role" {
  description = "Name of the EMR service role"
  type        = string
}

variable "iam_emr_autoscaling_role" {
  description = "Name of the EMR autoscaling role"
  type        = string
}

variable "iam_emr_instance_profile" {
  description = "Name of the EMR EC2 instance profile"
  type        = string
}

variable "master_instance_type" {
  description = "EC2 Instance Type for Master"
  type        = string
  default     = "m5.xlarge"
}

variable "core_instance_type" {
  description = "EC2 Instance Type for Core Nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "task_instance_type" {
  description = "EC2 Instance Type for Task Nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "core_instance_count" {
  description = "Number of Core Nodes"
  type        = string
  default     = "2"
}

variable "core_instance_max_count" {
  description = "Max number of Core Nodes used on autoscale"
  type        = string
  default     = "4"
}

variable "task_instance_count" {
  description = "Number of instances of Task Nodes"
  type        = string
  default     = "2"
}

variable "task_instance_max_count" {
  description = "Max number of Task Nodes used on autoscale"
  type        = string
  default     = "4"
}

locals {
  tags = merge(map("vendor", "segment"), var.tags)
}
