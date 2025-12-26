# portafolio-iac-core-v1

**Master IAC / Infra para el proyecto Dynamic Harvard CV Engine** ✅

Portafolio de infraestructura, documentación y estándares para desplegar un ecosistema serverless en Azure que genera CVs personalizados en tiempo real.

## 📌 Propósito
Construir una arquitectura orientada a eventos y de bajo costo (Free Tier / Consumption) que permita a reclutadores generar CVs en formato Harvard (ATS-friendly) y enviarlos por correo.

## 🧭 Resumen técnico
- Frontend: Azure Static Web Apps (SWA)
- API Orquestadora: Azure Function (Java 17)
- Worker: Azure Function (Node.js 20)
- Storage: Azure Blob Storage + Storage Queues
- DB: Azure Cosmos DB (Serverless)
- Notifier: Azure Function (Java 17) + Airtable
- IaC: Terraform (modular)

## 🚀 Quickstart (sin instalar nada localmente)
Usa **Azure Cloud Shell** para validar la infra y planear:

```bash
# clona el repo y ve al folder terraform
git clone <repo-url>
cd portafolio-iac-core-v1/terraform

terraform init
terraform plan -var "prefix=iaccore" -var "location=East US" -out=tfplan
terraform show -json tfplan > plan.json
```

> Nota: si trabajas local, instala `terraform` y `az` o usa credenciales de Service Principal en variables de entorno.

## 🔁 CI/CD (Infra)
Hemos incluido plantillas de GitHub Actions para infraestructura:

- **PR**: `.github/workflows/terraform-pr.yml` — ejecuta `terraform fmt`, `validate` y `plan` y publica el plan como comentario en el PR.
- **Apply (main)**: `.github/workflows/terraform-apply.yml` — ejecuta `plan` y `apply` en `main` o por `workflow_dispatch`. El job de `apply` está ligado al `environment: production` para habilitar aprobaciones manuales y revisores.

### Secrets necesarios en GitHub
- `AZURE_CREDENTIALS`: JSON con las credenciales del Service Principal (salida de `az ad sp create-for-rbac --sdk-auth`).
- (Opcional) `TF_STATE_STORAGE_ACCOUNT`, `TF_STATE_CONTAINER`, `TF_STATE_ACCESS_KEY` — si configuras backend remoto para el state.

> Recomendación: crea un Service Principal con permisos mínimos (contributor) en la suscripción de infra y usa ese `AZURE_CREDENTIALS` para la integración de CI.

## 📁 Documentación incluida
- `ARCHITECTURE.md` — Diagrama mermaid y descripción del flujo event-driven. 🔍
- `standards/STANDARDS.md` — Estándares de nombrado, Terraform y seguridad. 🔐
- `CONTRIBUTING.md` — Guía para colaboradores y convenciones de commits. 🤝
- `docs/contract-schema.json` — Contrato JSON maestro (ejemplo y esquema de entrada). 📄

---

### 🧾 Contrato JSON (ejemplo)
```json
{
  "entidad": "experiencia",
  "titulo": "Arquitecto Cloud",
  "organizacion": "Empresa X",
  "tags": ["Azure", "Terraform", "Java", "Serverless"],
  "logros": ["Reducción de costos en un 40%", "Implementación de CI/CD"],
  "fecha": "2023 - Presente"
}
```

---

Si quieres que genere además un diagrama más detallado (por repositorio), dímelo y lo añado al `ARCHITECTURE.md`. ✨

