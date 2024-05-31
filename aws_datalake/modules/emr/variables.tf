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

variable "additional_master_security_groups" {
  description = "String containing a comma separated list of additional Amazon EC2 security group IDs for the master node."
  type        = string
  default     = ""
}

variable "slave_security_group" {
  description = "Identifier of the Amazon EC2 EMR-Managed security group for the slave nodes."
  type        = string
  default     = ""
}

variable "additional_slave_security_groups" {
  description = "String containing a comma separated list of additional Amazon EC2 security group IDs for the slave nodes as a comma separated string."
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

variable "key_name" {
  description = "Amazon EC2 key pair that can be used to ssh to the master node as the user called hadoop."
  type        = string
  default     = null
}

# FIXME requires aws provider v5
#variable "unhealthy_node_replacement" {
#  description = "Whether Amazon EMR should gracefully replace core nodes that have degraded within the cluster."
#  type        = bool
#  default     = false
#}

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

variable "emr_cluster_version" {
  description = "Version of emr cluster"
  type        = string
  default     = "6.5.0"
}

variable "additional_applications" {
  description = "List of applications to install on the EMR cluster, besides Hadoop, Hive, and Spark."
  type        = list(string)
  default     = []
}

variable "ebs_size" {
  description = "Volume size, in gibibytes (GiB)"
  type        = string
  default     = "64"
}

variable "ebs_type" {
  description = "Volume type. Valid options are gp3, gp2, io1, standard, st1 and sc1."
  type        = string
  default     = "gp2"
}

variable "configurations_json" {
  description = "JSON string for supplying list of configurations for the EMR cluster."
  type        = string
  default     = <<-EOF
    [
      {
        "Classification": "hive-site",
        "Properties": {
          "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
        }
      },
      {
        "Classification": "spark-hive-site",
        "Properties": {
          "hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
        }
      },
      {
        "Classification": "spark-defaults",
        "Properties": {
          "spark.history.fs.cleaner.enabled": "true",
          "spark.history.fs.cleaner.interval": "1d",
          "spark.history.fs.cleaner.maxAge": "7d"
        }
      }
    ]
  EOF
}

locals {
  tags = merge(tomap({"vendor" = "segment"}), var.tags)
}
