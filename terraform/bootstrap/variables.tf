variable "resource_group_name" {
  description = "Resource group where the storage account exists"
  type        = string
  default     = "iac-core-cenus-rg"
}

variable "location" {
  description = "Azure region for the storage account"
  type        = string
  default     = "Central US"
}

variable "storage_account_name" {
  description = "Existing storage account name to host remote state"
  type        = string
  default     = "iaccorecenus"
}

variable "container_name" {
  description = "Name of the container to create for Terraform state"
  type        = string
  default     = "tfstate"
}

variable "subscription_id" {
  description = "Subscription ID (used in import instructions)"
  type        = string
  default     = "3dc34435-2831-4062-a578-8e415ebe91e8"
}
