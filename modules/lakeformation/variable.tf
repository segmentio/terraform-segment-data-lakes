/*variable "emr_instance_profile_role" {
  description = "The arn of the emr role."
  type        = "string"
}

variable "segment_datalake_role" {
  description = "The arn of the segment datalake iam role."
  type        = "string"
}*/

variable "name" {
  description = "The name of the database."
  type        = "string"
}

variable "iam_roles" {
  description = "The arn of the segment datalake iam role."
  type        = set(string)
}