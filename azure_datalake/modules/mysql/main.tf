

resource "azurerm_mysql_database" "segment_mysql_database" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.segment_mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_server" "segment_mysql_server" {
  name                = var.server_name
  location            = var.region
  resource_group_name = var.resource_group_name

  administrator_login          = var.db_admin
  administrator_login_password = var.password

  sku_name   = "B_Gen5_1"  //tier+family+core
  version    = "5.7"
  storage_mb = 5120
  ssl_enforcement_enabled  = true
}

