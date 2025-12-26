# module/function_app

Terraform module scaffold for deploying an Azure Function App.

Inputs (suggested):
- `name` (string) - function app name
- `resource_group_name` (string)
- `location` (string)
- `identity_id` (string) - optional user-assigned identity
- `runtime` (string) - e.g., `node|java`
- `storage_account_name` (string) - required for function app

Outputs (suggested):
- `function_app_id`
- `function_app_default_hostname`

Note: This is a scaffold module. Implement resources as required (App Service Plan, Function App, App Settings, etc.).
