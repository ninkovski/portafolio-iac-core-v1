# Terraform Backend Bootstrap

Creates (or imports) a dedicated Azure Storage Account and the `tfstate` container to host Terraform remote state. Uses a local backend to avoid the chicken-and-egg problem.

## Defaults
- Resource Group: `iac-core-cenus-rg`
- Location: `Central US`
- Storage Account: `iaccorecenus`
- Container: `tfstate`

Override via variables if needed.

## If the Storage Account Already Exists
Import it into the bootstrap state before applying, so Terraform won't try to recreate:

```bash
cd terraform/bootstrap
terraform init
terraform import azurerm_storage_account.state \
  /subscriptions/3dc34435-2831-4062-a578-8e415ebe91e8/resourceGroups/iac-core-cenus-rg/providers/Microsoft.Storage/storageAccounts/iaccorecenus
terraform apply
```

## First-Time Create (New Storage Account)
Let Terraform create the storage account and container:

```bash
cd terraform/bootstrap
terraform init
terraform apply -var "resource_group_name=<rg>" -var "storage_account_name=<newunique>" -var "location=<region>"
```

## Use the Remote Backend in the Main Stack

```bash
cd ../
terraform init -upgrade \
  -backend-config="resource_group_name=iac-core-cenus-rg" \
  -backend-config="storage_account_name=iaccorecenus" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=terraform-dev.tfstate"
```

Then run plan/apply as usual.
