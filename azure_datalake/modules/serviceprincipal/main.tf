data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "rbac" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.segment_service_principal.object_id
}

resource "azuread_service_principal_password" "segment_sp_password" {
  service_principal_id = azuread_service_principal.segment_service_principal.object_id
}

resource "azuread_service_principal" "segment_service_principal" {
  application_id  = azuread_application.segment_service_application.application_id
}

resource "azuread_application" "segment_service_application" {
  display_name     = var.app_name
}
