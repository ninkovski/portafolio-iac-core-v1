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

variable "github_token" {
  description = "GitHub personal access token for Static Web App deployment (set via TF_VAR_github_token or secret)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "github_repo_url" {
  description = "GitHub repository URL for Static Web App (e.g., https://github.com/owner/repo)"
  type        = string
  default     = ""
}
