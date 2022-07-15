output "storage_account_name" {
  value       = azurerm_storage_account.segment_data_lake_storage_account.name
}

output "storage_container_name" {
  value       = azurerm_storage_container.segment_data_lake_storage_container.name
}

output "region" {
  value       = azurerm_storage_account.segment_data_lake_storage_account.location
}