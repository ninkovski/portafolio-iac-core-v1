# Estándares del proyecto

## Naming
- Recursos: usar `prefix` definido por Terraform (ej. `iaccore-rg`, `iaccore-stg`)
- Storage account: minúsculas, 3-24 caracteres alfanuméricos.

## Terraform
- Usa módulos por recurso (db, storage, functions)
- `terraform fmt` y `terraform validate` en CI
- `tflint` y `tfsec` en pipeline para seguridad/lint
- Mantén el state remoto en `azurerm` Storage Account para colaboración
- CI Pattern:
  - **PR**: `fmt` → `validate` → `plan` (publicar plan en PR como comentario)
  - **Main**: `apply` debe ejecutarse en un job separado y protegido por `environment` con revisores (aprobación manual) 
  - Usa Service Principal con permisos mínimos para el job de `apply` (almacena credenciales en `AZURE_CREDENTIALS` secret)

## Seguridad
- Managed Identities para Functions (NO hardcodear keys)
- Blobs privados, servir con SAS expirado (24h)
- Cosmos DB en serverless con RU ajustadas según pruebas

## Docs
- Actualiza `ARCHITECTURE.md` cuando cambie el flujo
- Ejemplos de contract/schema en `docs/contract-schema.json`

---
Si quieres que convierta estas directrices en GitHub Actions para checks automáticos lo puedo añadir.