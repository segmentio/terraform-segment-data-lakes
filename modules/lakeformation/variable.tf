variable "name" {
  description = "The name of the database."
  type        = string
}

variable "iam_roles" {
  description = "The arns of the segment datalake iam role and emr instance profile role."
  type        = map(string)
}