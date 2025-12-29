# Contribuir al proyecto

Proyecto personal: las contribuciones se realizan vía fork y PR. Esta guía puede usarse como referencia/base en otros repos.

## Flujo de trabajo
- Ramas en el fork: `feature/<algo>` o `fix/<algo>` desde `develop`; los PR se abren hacia `develop` de este repo. Los merges a `main` se realizan manualmente.
- Commits: usa Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `ci:`, `refactor:`). Ej: `feat(tf): add lifecycle to pdfs`.
- Issues/PRs: describe el objetivo, impacto y links a tickets si aplica.

## Infra: cómo validar
1) `cd terraform`
2) `terraform fmt -recursive`
3) `terraform validate`
4) `terraform plan -var "prefix=<pref>" -var "location=<region>" -out=tfplan`

Usar Cloud Shell o login con `az login`/variables ARM (`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`). En forks no se exponen secretos; no ejecutar `apply` en CI. El workflow en `.github/workflows/terraform.yml` aplica automáticamente en `develop` de este repo; en `main` requiere dispatch manual y aprobación (lo ejecuta el dueño porque usa su suscripción privada).

## Checklist de PR
- [ ] `terraform fmt` y `terraform validate` ejecutados
- [ ] Describes riesgos/impacto en recursos
- [ ] Cambios de infraestructura revisados por al menos 1 persona (en este repo)
- [ ] Se usó la plantilla de PR en `.github/pull_request_template.md`

## Estándares
- Terraform: modular, sin lógica de app; nombres con `prefix`; evita hardcodear regiones/IDs.
- Seguridad: preferir Managed Identity; no subir llaves ni cadenas de conexión; usa secrets/variables de entorno.
- Diagramas: actualiza `diagrams/*.mmd` y `architecture/ARCHITECTURE.md` si cambias flujos o componentes.

## Tests y validación funcional
- Si tocas librerías o Functions (en otros repos), agrega/ajusta pruebas unitarias y smoke tests mínimos.
- Para cambios en colas/blobs/cosmos, valida rutas felices y de error (mensajes reintentos, lifecycle de blobs).

¿Dudas? Abre un issue con el contexto y el comando/stacktrace que viste.