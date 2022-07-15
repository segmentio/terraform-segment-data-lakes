output "mysql_server_fqdn" {
  value = azurerm_mysql_server.segment_mysql_server.fqdn
}

output "mysql_username" {
  value = azurerm_mysql_server.segment_mysql_server.administrator_login
}

output "mysql_password" {
  value = azurerm_mysql_server.segment_mysql_server.administrator_login_password
}

output "mysql_dbname" {
  value = azurerm_mysql_database.segment_mysql_database.name
}