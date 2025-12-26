# Contribuir al proyecto

Gracias por querer contribuir a `portafolio-iac-core-v1`. Sigue estas pautas para facilitar revisiones y mantener calidad:

## Flujo de trabajo
- Usa **GitHub Flow**: ramas por feature/bugfix `feature/xyz` o `fix/abc` y PR hacia `main`.
- Commits: sigue **Conventional Commits** (ej. `feat(api): add tag filter`, `fix(tf): correct storage name`).

## PR Checklist
- [ ] `terraform fmt` pasó y `terraform validate` localmente
- [ ] PR descrito con intención y screenshots/plan.json si aplica
- [ ] Revisiones (2 reviewers si es cambio infra)

## Estándares de codificación
- Para Terraform: modulariza por recurso, no embebas lógica de aplicación.
- Para Functions: paquetes ligeros, evita dependencias grandes en el worker.

## Tests y Validación
- Añade unit tests a `portafolio-lib-harvard-cv-v1` para la lógica de rendering.
- Para infra: añade `plan.json` en PRs cuando cambien recursos críticos.

---
Si necesitas ayuda para inicializar un entorno local o Cloud Shell, abre un issue y te asistimos.