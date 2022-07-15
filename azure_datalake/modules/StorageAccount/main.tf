resource "azurerm_storage_container" "segment_data_lake_storage_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.segment_data_lake_storage_account.name
}

resource "azurerm_storage_account" "segment_data_lake_storage_account" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"
  allow_blob_public_access = false
  is_hns_enabled           = true
}
