variable "name" {
  description = "Function app name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Region"
  type        = string
}

variable "identity_id" {
  description = "User assigned identity id (optional)"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Runtime (node|java)"
  type        = string
  default     = "node"

  validation {
    condition     = contains(["node", "python"], var.runtime)
    error_message = "runtime must be one of: node, python"
  }
}

variable "storage_account_name" {
  description = "Storage account name for Function App"
  type        = string
}

variable "storage_account_access_key" {
  description = "Primary access key of the storage account"
  type        = string
}
