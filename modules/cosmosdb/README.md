# module/cosmosdb

Module scaffold for Cosmos DB account and containers.

Inputs (suggested):
- `name` (string)
- `resource_group_name` (string)
- `location` (string)
- `enable_serverless` (bool)
- `throughput` (number, optional)

Outputs (suggested):
- `endpoint`
- `primary_master_key` (sensitive)

Note: Fill with actual resources (azurerm_cosmosdb_account, containers) when ready to enable DB provisioning.
