variable "name" {
  description = "The name of the database."
  type        = string
}

variable "description" {
  description = "Description of the database."
  type        = string
  default     = "Segment Data Lake"
}
