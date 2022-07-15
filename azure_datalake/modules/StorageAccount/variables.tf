variable "name" {
  description = "The name for the storage account to be created/used."
}

variable "region" {
  description = "The Azure Region in which all resources should be created."
}

variable "resource_group_name" {
  description = "The name for the resource group to be used."
}

variable "container_name" {
  description = "The Azure Storage Container that should be created."
}