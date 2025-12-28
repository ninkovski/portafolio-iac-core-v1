resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption plan
}

resource "azurerm_linux_function_app" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  identity {
    type         = var.identity_id != "" ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_id != "" ? [var.identity_id] : null
  }

  site_config {
    application_stack {
      # Keep stack minimal; rely on FUNCTIONS_WORKER_RUNTIME
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
