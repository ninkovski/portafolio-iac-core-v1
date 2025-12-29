# portafolio-iac-core-v1

Infraestructura base en Azure para el portafolio CV: recursos serverless mínimos, Terraform modular y flujos event-driven.

## Alcance actual
- Grupo de recursos y plan de App Service (SKU F1) compartido para Functions.
- Cuenta de Storage con contenedor privado `pdfs`, cola `cv-requests` y política de lifecycle (purgado 1 día).
- Identidad administrada (User Assigned) para las Functions.
- Cosmos DB en modo Serverless (consistencia Session).
- Function Apps (Linux): `portafolio-cv-api`, `portafolio-cv-worker`, `portafolio-payments`, `portafolio-notifier` (runtime Node configurable por módulo).
- Módulos listos para extender: Storage, Function App; scaffolds: Cosmos DB, Queue, Web App.

## Quickstart (Cloud Shell o local)
```bash
git clone <repo-url>
cd portafolio-iac-core-v1/terraform

# Backend remoto (recomendado): pasa los backend-config o usa los env vars que usa el workflow
terraform init -upgrade \
  -backend-config="resource_group_name=tfstate-rg" \
  -backend-config="storage_account_name=iaccoretfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=tfstate-<repo>-dev.tfstate"

# Variables principales
terraform plan -var "prefix=iaccore" -var "location=Central US" -out=tfplan
terraform apply tfplan
```

Credenciales: usa `az login` (interactivo/MI) o exporta `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` (como hace el workflow).

## CI/CD de infra (GitHub Actions)
- `.github/workflows/terraform.yml`: ejecuta fmt/validate/apply en `develop` automáticamente; en `main` sólo aplica si se lanza por `workflow_dispatch` con `apply=true`. Provisiona el backend de state (RG, storage, container) si no existe.
- `.github/workflows/terraform-fmt.yml`: auto `terraform fmt` en pushes.

Secrets requeridos en el repo/orga:
- `AZURE_CREDENTIALS`: JSON de `az ad sp create-for-rbac --sdk-auth` (para login OIDC en el workflow principal se usa `azure/login`).
- (Opcional) `TF_VAR_LOCATION`, `TF_VAR_PREFIX`, `TF_BACKEND_*` si quieres sobreescribir los defaults del workflow.

## Estructura
- `terraform/` stack principal (RG, Storage, Queue, Cosmos, Functions) y bootstrap de backend en `terraform/bootstrap/`.
- `modules/` scaffolds y módulos reutilizables para servicios clave.
- `diagrams/` mermaid con arquitectura y componentes actualizados.
- `standards/`, `CONTRIBUTING.md`, `docs/contract-schema.json` para gobierno y ejemplos.

## Notas rápidas
- El storage usa lifecycle para purgar `pdfs/` en 1 día; no requiere SAS público.
- Cosmos DB usa capacidad Serverless y consistencia Session para minimizar costos.
- Las Function Apps heredan la identidad administrada `...-id`; conecta permisos según cada repo/app.
- Renombra `prefix` por entorno para aislar recursos (`iac-core-dev`, `iac-core-prod`, etc.).

