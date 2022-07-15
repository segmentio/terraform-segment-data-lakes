
variable "cluster_name" {
  description = "The name of the databricks cluster to be created and used."
}

variable "storage_account_name" {
  description = "The name for the storage account to be created/used."
}

variable "container_name" {
  description = "The Azure Storage Container that should be created."
}

variable "tenant_id" {
  description = "the tenant ID for the azure account"
}

variable "mysql_username" {
  description = "the username for the mysql db metastore"
}

variable "mysql_password" {
  description = "the password for the mysql instance"
}

variable "mysql_server_url" {
  description = "the connection url for mysql"
}

variable "mysql_dbname" {
  description = "the db name for mysql"
}

variable "service_principal_secret" {
  description = "the secret for the service principal"
}

variable "service_principal_id" {
  description = "the client id for the service principal"
}

variable "keyvault_dns_name" {
  description = "dns name for keyvault"
}

variable "keyvault_resource_id" {
  description = "the azure resource id for the keyvault"
}

variable "workspace_url" {
  description = "the workspace for the databricks cluster"
}
