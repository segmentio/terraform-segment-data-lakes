variable "url" {
  description = "External IDs that will be used to assume the role. Segment will currently use the source ID as the external ID when connecting to your AWS account, and this should be a list of IDs of the sources that you want to connect to your Data Lake. These IDs are generated by Segment and can be retrieved from the Segment app."
  type        = "string"
}

variable "token" {
  description = "Name of the S3 bucket used by the Data Lake."
  type        = "string"
}

variable "environment" {
  description = "Name of the S3 bucket used by the Data Lake."
  type        = "string"
}

variable "cluster_id" {
  description = "Name of the S3 bucket used by the Data Lake."
  type        = "string"
}
