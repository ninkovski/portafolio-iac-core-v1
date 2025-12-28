resource "azurerm_linux_function_app" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = var.service_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  identity {
    type         = var.identity_id != "" ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_id != "" ? [var.identity_id] : null
  }

  site_config {
    application_stack {
      node_version   = var.runtime == "node" ? "18" : null
      python_version = var.runtime == "python" ? "3.11" : null
    }
    ftps_state = "Disabled"
  }

  app_settings = {
    FUNCTIONS_EXTENSION_VERSION = "~4"
    FUNCTIONS_WORKER_RUNTIME    = var.runtime
    WEBSITE_RUN_FROM_PACKAGE    = "1"
    AzureWebJobsStorage         = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_access_key};EndpointSuffix=core.windows.net"
  }
}
