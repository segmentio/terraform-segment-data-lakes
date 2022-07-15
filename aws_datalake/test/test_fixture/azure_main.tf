terraform {
  required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
    }

    azurerm = "~> 2"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}


locals {
  region         = ""
  resource_group = ""

  storage_account = ""
  container_name  = ""

  key_vault_name = ""

  server_name = "segment-server-db"
  db_name     = "segment_db"
  db_password = ""
  db_admin    = ""

  start_ip          = "0.0.0.0"
  end_ip            = "255.255.255.255"
  sku               = "premium"
  service_principal_name = ""

  databricks_workspace_url = ""
  cluster_name   = ""
  tenant_id      = ""
}

resource "azurerm_resource_group" "segment_datalake" {
  name     = local.resource_group
  location = local.region
}

resource "azurerm_key_vault" "segment_vault" {
  name                     = local.key_vault_name
  location                 = azurerm_resource_group.segment_datalake.location
  resource_group_name      = azurerm_resource_group.segment_datalake.name
  tenant_id                = local.tenant_id
  soft_delete_enabled      = false
  purge_protection_enabled = false
  sku_name                 = "standard"
}

resource "azurerm_key_vault_access_policy" "segment_vault" {
  key_vault_id       = azurerm_key_vault.segment_vault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["delete", "get", "list", "set"]
}


module "segment_data_lake_storage_account" {
  source = "./modules/storageaccount"

  name           = local.storage_account
  region         = local.region
  resource_group_name = azurerm_resource_group.segment_datalake.name
  container_name = local.container_name
}

module "segment_data_lake_mysql" {
  source = "./modules/mysql"


  region = local.region
  server_name = local.server_name
  resource_group_name = azurerm_resource_group.segment_datalake.name
  db_name     = local.db_name
  db_admin    = local.db_admin
  password   =  local.db_password

}

module "segment_data_lake_service_principal" {
  source = "./modules/serviceprincipal"

  app_name = local.service_principal_name

}

module "segment_data_lake_databricks_cluster" {
  source = "./modules/databricks"
  workspace_url = local.databricks_workspace_url

  cluster_name             = local.cluster_name
  storage_account_name     = local.storage_account
  container_name           = local.container_name
  mysql_dbname             = module.segment_data_lake_mysql.mysql_dbname
  mysql_password           = module.segment_data_lake_mysql.mysql_password
  mysql_server_url         = module.segment_data_lake_mysql.mysql_server_fqdn
  mysql_username           = module.segment_data_lake_mysql.mysql_username
  service_principal_id     = module.segment_data_lake_service_principal.client_id
  service_principal_secret = module.segment_data_lake_service_principal.spsecret
  keyvault_dns_name        = azurerm_key_vault.segment_vault.vault_uri
  keyvault_resource_id     = azurerm_key_vault.segment_vault.id
  tenant_id                = local.tenant_id

}