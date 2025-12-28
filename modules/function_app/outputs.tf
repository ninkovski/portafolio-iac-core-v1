# Outputs placeholder
output "function_app_id" {
  description = "Function App resource id"
  value       = azurerm_linux_function_app.this.id
}

output "function_app_default_hostname" {
  description = "Default hostname of the Function App"
  value       = azurerm_linux_function_app.this.default_hostname
}
