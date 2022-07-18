output "client_id" {
  value = azuread_application.segment_service_application.application_id
}

output "spsecret" {
  value = azuread_service_principal_password.segment_sp_password.value
}

output "object_id" {
  value = azuread_application.segment_service_application.object_id
}