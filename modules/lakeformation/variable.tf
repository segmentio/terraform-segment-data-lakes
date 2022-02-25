variable "name" {
  description = "The name of the database."
  type        = "string"
}

variable "iam_roles" {
  description = "The arn of the segment datalake iam role."
  type        = set(string)
}