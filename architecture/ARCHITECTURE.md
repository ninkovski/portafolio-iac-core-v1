# Arquitectura Técnica — Dynamic Harvard CV Engine

## Resumen
Arquitectura event-driven en Azure orientada a coste mínimo y alta escalabilidad. Flujo principal: el frontend envía una petición con las tags seleccionadas → función orquestadora filtra el JSON maestro → inserta un mensaje en `cv-requests` (Storage Queue) → worker genera PDF y sube a Blob Storage → notificador envía el email con el link y registra el lead en Airtable.

## Diagrama (Mermaid)
```mermaid
flowchart LR
  subgraph Frontend
    A[Azure SWA - Selector de tags] --> B[API Orquestadora (Function Java)]
  end

  B --> C[Storage Queue: cv-requests]
  C --> D[Worker (Function Node.js) : Genera PDF con portafolio-lib-harvard-cv-v1]
  D --> E[Azure Blob Storage (container: pdfs)]
  D --> F[Cosmos DB (JSON Maestro)]
  E --> G[Notifier (Function Java) -> Envia email y escribe Airtable]
  B --> F

  style A fill:#f9f,stroke:#333,stroke-width:1px
  style B fill:#bbf,stroke:#333,stroke-width:1px
  style D fill:#bfb,stroke:#333,stroke-width:1px
  style E fill:#ffd,stroke:#333,stroke-width:1px
  style G fill:#fdd,stroke:#333,stroke-width:1px
```

## Notas importantes
- Idempotencia: el API debe generar un hash por set de tags y almacenarlo (Cosmos) para evitar reprocesos.
- Seguridad: usar Managed Identities para las fonctions y usar SAS o URLs temporales para los blobs (expiración 24h).
- Storage Governance: política de lifecycle del Blob para purgado a 24 horas.

## Repositorios (orden implementación)
1. `portafolio-iac-core-v1` — Infra global (Terraform)
2. `portafolio-db-cv-data-v1` — JSON maestro / esquema en Cosmos
3. `portafolio-lib-harvard-cv-v1` — Librería Node.js que genera PDFs
4. `portafolio-functionapp-cv-api-v1` — Function Java (orquestadora)
5. `portafolio-functionapp-cv-worker-v1` — Function Node.js (worker)
6. `portafolio-functionapp-notifier-v1` — Function Java (notificador)
7. `portafolio-webapp-frontend-v1` — Frontend (Azure SWA)

---

Si quieres, genero SVG/PNG del diagrama y lo añado al repo; dime si prefieres mermaid embebido o archivo visual. 
