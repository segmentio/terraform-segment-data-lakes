variable "server_name" {
  description = "The name for the mysql server to be created and used."
}

variable "region" {
  description = "The Azure Region in which all resources should be created."
}

variable "resource_group_name" {
  description = "The name for the resource group to be used."
}

variable "db_name" {
  description = "The name for the mysql database to be created."
}

variable "db_admin" {
  description = "The name of the admin of the mysql database."
}

variable "password" {
  description = "The password required to connect to the database being created."
}
