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
}
