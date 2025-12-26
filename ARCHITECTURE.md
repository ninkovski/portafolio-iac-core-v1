# Arquitectura Técnica — Dynamic Harvard CV Engine (detallado)

> Diagrama actualizado con patrones de desacoplamiento, seguridad, observabilidad y bucle de optimización.

```mermaid
flowchart TB
  %% Frontline
  subgraph Internet
    U[Recruiter UI / Browser]
  end

  subgraph Edge[Edge / Ingress]
    CDN[CDN]
    WAF[WAF / App Gateway]
    CDN --> WAF
    WAF --> SWA[Azure SWA]
  end

  U --> CDN
  SWA --> API[API Orquestadora (Function Java)
    \n- Validations: input schema, auth, rate-limit
    - Managed Identity (no secrets)
    - Key Vault for secrets]

  API -->|filter(tags)| Filter[Tag Filter + Authz]
  API -->|check cache/hash| Idempotency[Idempotency Cache (Cosmos DB)]
  Idempotency -->|hit| API --> Return[Return cached result / SAS URL]

  Idempotency -->|miss| Q[Storage Queue: cv-requests]
  Filter --> Q

  Q --> Worker[Worker (Function Node.js)
    - Uses `portafolio-lib-harvard-cv-v1`
    - Retries + Exponential Backoff]
  Q --- DLQ[Dead-letter Queue]

  Worker --> Blob[Azure Blob Storage (container: pdfs)
    - Private
    - SAS 24h
    - Lifecycle purge 24h]
  Worker --> Cosmos[Cosmos DB (JSON Maestro + Metadata)]
  Worker --> Metrics[Metric events / App Insights]

  Blob --> Notifier[Notifier (Function Java)
    - Creates email with SAS
    - Persists Lead to Airtable via secure API]
  Notifier --> Email[Email Provider (SendGrid / SMTP)]
  Notifier --> Airtable

  %% Observability / Optimization
  Metrics --> LogAnalytics[Log Analytics / App Insights]
  LogAnalytics --> Alerts[Alerts / Action Groups]
  Alerts --> DevOps[Pager / Teams / Email]
  LogAnalytics --> CostInsights[Cost & RU telemetry]
  CostInsights --> OptLoop[Optimization Loop]
  OptLoop -->|adjust| Cosmos
  OptLoop -->|tune| Worker

  %% CI/CD and Security gate
  subgraph CI/CD
    Repo[GitHub - IaC repo]
    PR[PR: tflint / tfsec / terraform plan]
    MAIN[Protected apply - env approvals]
  end
  Repo --> PR --> MAIN
  PR -->|publish plan| API

  %% Security & Governance
  subgraph Governance
    AzurePolicy[Azure Policy]
    RBAC[RBAC & Managed Identities]
    KeyVault[Key Vault]
  end
  KeyVault --> API
  RBAC --> Worker
  AzurePolicy --> Blob
  AzurePolicy --> Cosmos

  style API fill:#bbf,stroke:#333,stroke-width:1px
  style Worker fill:#bfb,stroke:#333,stroke-width:1px
  style Blob fill:#ffd,stroke:#333,stroke-width:1px
  style Notifier fill:#fdd,stroke:#333,stroke-width:1px
  style CDN fill:#eef,stroke:#333,stroke-width:1px
  style DLQ fill:#fcc,stroke:#333,stroke-width:1px
  classDef infra fill:#f8f8f8,stroke:#aaa
  class Blob,Cosmos,DLQ infra
```

## Notas importantes

### Desacoplamiento y resiliencia
- Patrón event-driven: la orquestadora escribe en la cola `cv-requests` y el worker consume de forma asíncrona, lo que desacopla picos de tráfico y permite escalabilidad independiente.
- Retries y DLQ: el worker debe implementar reintentos con backoff y enviar mensajes fallidos a una Dead-Letter Queue para inspección manual.
- Idempotencia y caché: la API genera un hash del conjunto de tags y consulta un `Idempotency Cache` en Cosmos; si existe, devuelve el recurso ya creado (SAS URL) evitando reprocesos.

### Seguridad y validación
- Autenticación/Autorización: usar **Managed Identities** y **RBAC** para funciones y recursos; no hardcodear secrets.
- Secret Management: almacena claves y secretos en **Azure Key Vault** y referencia via Managed Identity.
- Validación en CI: incluye `tfsec`, `tflint` y políticas de Azure (Azure Policy) en el pipeline para detectar configuraciones inseguras antes de aplicar.
- Blobs privados + SAS expiradas (24h) y políticas de retención automáticas.

### Observability & Optimization loop
- Trazabilidad centralizada con **App Insights / Log Analytics**: logs, métricas de latencia, errores y RUs (Cosmos).
- Alertas: crea Alert Rules (metrics + log queries) y Action Groups para notificaciones y runbooks.
- Bucles de optimización: ingestar cost/usage telemetry → dashboards → reglas automatizadas (o runbook) para ajustar RUs, activar/deactivar serverless features o archivar artefactos.

### CI/CD y control de cambios
- PR pipeline (`terraform-pr.yml`): `fmt` → `validate` → `tflint`/`tfsec` → `plan` y publicar `plan` como comentario en PR.
- Protected `apply` (`terraform-apply.yml`): job en `main` protegido con `environment` y aprobaciones manuales; usar `AZURE_CREDENTIALS` secret con un Service Principal de permisos mínimos.
- Import/Drift: si un recurso se crea/edita fuera de IaC, usa `terraform import` para traerlo al state y reconciliar con `plan`.

### Storage Governance & Cost control
- Blob lifecycle: purga automática a 24 horas para PDFs temporales.
- Cosmos DB: usar serverless o autoscale y ajustar RUs basado en telemetría; guardar metadata minimalista para evitar costos.

### Recomendaciones de implementación
- Añadir DLQ resources y políticas de reintento en el worker.
- Implementar pruebas end-to-end con datos mock y `plan.json` en PRs.
- Configurar `tflint`/`tfsec` y `terraform-docs` en CI; bloquear `apply` hasta aprobación humana.

---

## Repositorios (orden de implementación recomendado)
1. `portafolio-iac-core-v1` — Infra global (Terraform)
2. `portafolio-db-cv-data-v1` — JSON maestro / esquema en Cosmos (Idempotency table)
3. `portafolio-lib-harvard-cv-v1` — Librería Node.js que genera PDFs
4. `portafolio-functionapp-cv-api-v1` — Function Java (orquestadora) con validaciones y cache
5. `portafolio-functionapp-cv-worker-v1` — Function Node.js (worker) con retries + DLQ
6. `portafolio-functionapp-notifier-v1` — Function Java (notificador) y conexión a Airtable
7. `portafolio-webapp-frontend-v1` — Frontend (Azure SWA)

---

Si quieres que genere el SVG del diagrama (`diagrams/architecture.svg`) y cree issues y templates en el repo para implementar DLQ, Key Vault, y las reglas de Azure Policy, dame el visto bueno y lo agrego.