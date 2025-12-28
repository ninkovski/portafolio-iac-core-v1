resource "azurerm_resource_group" "core" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

output "resource_group_name" {
  value = azurerm_resource_group.core.name
}

# Storage Account (module)
module "storage" {
  source                   = "./modules/storage"
  name                     = length(lower(replace(var.prefix, "-", ""))) >= 3 ? substr(lower(replace(var.prefix, "-", "")), 0, 24) : "stgacct"
  resource_group_name      = azurerm_resource_group.core.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "pdfs" {
  name                  = "pdfs"
  storage_account_id    = module.storage.storage_account_id
  container_access_type = "private"
}

resource "azurerm_storage_queue" "cv_requests" {
  name               = "cv-requests"
  storage_account_id = module.storage.storage_account_id
}

# Lifecycle management policy: delete blobs after 1 day
resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = module.storage.storage_account_id

  rule {
    name    = "auto-delete-pdfs"
    enabled = true

    filters {
      prefix_match = ["pdfs/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 0
        tier_to_archive_after_days_since_modification_greater_than = 0
        delete_after_days_since_modification_greater_than          = 1
      }
    }
  }
}

# Managed identity for Function Apps
resource "azurerm_user_assigned_identity" "functions" {
  name                = "${var.prefix}-id"
  resource_group_name = azurerm_resource_group.core.name
  location            = var.location
}

# Cosmos DB (serverless) for JSON master data
resource "azurerm_cosmosdb_account" "cv_data" {
  name                = "${var.prefix}-cosmos"
  location            = var.location
  resource_group_name = azurerm_resource_group.core.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "storage_container_pdfs" {
  value = azurerm_storage_container.pdfs.name
}

output "storage_queue_cv_requests" {
  value = azurerm_storage_queue.cv_requests.name
}

output "functions_identity_id" {
  value = azurerm_user_assigned_identity.functions.id
}

output "cosmosdb_account_endpoint" {
  value = azurerm_cosmosdb_account.cv_data.endpoint
}

output "function_app_cv_api_hostname" {
  value = module.function_app_cv_api.function_app_default_hostname
}

output "function_app_cv_worker_hostname" {
  value = module.function_app_cv_worker.function_app_default_hostname
}

output "function_app_payments_hostname" {
  value = module.function_app_payments.function_app_default_hostname
}

output "function_app_notifier_hostname" {
  value = module.function_app_notifier.function_app_default_hostname
}

# Static Web App for frontend
resource "azurerm_static_web_app" "frontend" {
  count               = var.github_token != "" && var.github_repo_url != "" ? 1 : 0
  name                = "portafolio-webapp-frontend"
  resource_group_name = azurerm_resource_group.core.name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
  app_location        = "."
  api_location        = "api"
  output_location     = "dist"
  github_token        = var.github_token
  repository_url      = var.github_repo_url
  branch              = "main"
}

output "static_web_app_default_hostname" {
  value = try(azurerm_static_web_app.frontend[0].default_host_name, "Not deployed (requires github_token and github_repo_url)")
}

# Function Apps (module)
module "function_app_cv_api" {
  source                     = "../modules/function_app"
  name                       = "portafolio-cv-api"
  resource_group_name        = azurerm_resource_group.core.name
  location                   = var.location
  identity_id                = azurerm_user_assigned_identity.functions.id
  runtime                    = "node"
  storage_account_name       = module.storage.storage_account_name
  storage_account_access_key = module.storage.storage_account_primary_access_key
}

module "function_app_cv_worker" {
  source                     = "../modules/function_app"
  name                       = "portafolio-cv-worker"
  resource_group_name        = azurerm_resource_group.core.name
  location                   = var.location
  identity_id                = azurerm_user_assigned_identity.functions.id
  runtime                    = "node"
  storage_account_name       = module.storage.storage_account_name
  storage_account_access_key = module.storage.storage_account_primary_access_key
}

module "function_app_payments" {
  source                     = "../modules/function_app"
  name                       = "portafolio-payments"
  resource_group_name        = azurerm_resource_group.core.name
  location                   = var.location
  identity_id                = azurerm_user_assigned_identity.functions.id
  runtime                    = "node"
  storage_account_name       = module.storage.storage_account_name
  storage_account_access_key = module.storage.storage_account_primary_access_key
}

module "function_app_notifier" {
  source                     = "../modules/function_app"
  name                       = "portafolio-notifier"
  resource_group_name        = azurerm_resource_group.core.name
  location                   = var.location
  identity_id                = azurerm_user_assigned_identity.functions.id
  runtime                    = "node"
  storage_account_name       = module.storage.storage_account_name
  storage_account_access_key = module.storage.storage_account_primary_access_key
}
