variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "Central US"
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "iac-core-cenus"
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}
