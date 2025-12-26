# Terraform core (scaffold)

Este directorio contiene la configuración Terraform inicial para `portafolio-iac-core-v1`.

- `providers.tf`: proveedores y versión requerida.
- `backend.tf`: backend local por defecto (reemplazar por `azurerm` remote state cuando esté listo).
- `variables.tf`: variables globales.
- `main.tf`: recursos core (Resource Group de ejemplo).
- `modules/`: módulos reutilizables (ej. storage).
