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
  free_tier_enabled   = true

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
