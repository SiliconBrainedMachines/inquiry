---
kind: iq-issue
lang: es
title: "[repo] Título corto de la issue"
repo: "{{REPO}}"
labels: []
spec: "{{SPEC}}"
covers: []
---

<!-- "Issue as code": este .md es la fuente de verdad. Edítalo y revísalo aquí;
     `iq issue publish <slug> <nombre> --plan` muestra el `gh issue create` que
     armaría con el front-matter; `--apply` lo crea. El cuerpo (todo lo que sigue
     al segundo `---`) es lo que se publica; el front-matter NO se publica.
     `covers:` debe listar los AC que cubre esta issue — el gate lo exige. -->

# [repo] Título corto de la issue

## Contexto

<!-- Qué existe hoy y qué falta, con handles re-verificables (archivo:línea). -->

## Alcance

- <!-- Qué construye esta issue -->

## Decisiones técnicas (evidencia)

- **Decisión**: <!-- la decisión -->. **Evidencia**: <!-- handle re-verificable: una consulta, un comando, `inline-code`, o archivo:línea -->.

## Criterios de aceptación cubiertos

<!-- Repite aquí, para lectura humana, los AC listados en el front-matter `covers:`. La trazabilidad del gate se toma del `covers:`, no de este texto. -->
