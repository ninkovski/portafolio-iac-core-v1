/*
 Remote state backend (azurerm). Values are provided at init time via
 -backend-config or environment variables in CI.
*/
terraform {
  backend "azurerm" {}
}
