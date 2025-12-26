/*
 Local backend by default to allow immediate usage. Replace with an Azure remote
 state backend (azurerm) once a storage account and container are provisioned.
*/
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
