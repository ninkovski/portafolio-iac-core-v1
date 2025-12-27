variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "West US 2"
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "iac-core"
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}
