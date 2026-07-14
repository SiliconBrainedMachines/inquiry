# Especificación

<!-- iq:lang=es · Idioma de esta especificación y de TODOS sus artefactos derivados (issues, requirements, planes). Mantener consistente. No se renderiza en el PDF/DOCX. -->

<!--
  Historias de usuario: User Stories Applied (Cohn, 2004).
  Acceptance Criteria: Given-When-Then — BDD (North, 2006).
  Lenguaje del dominio: Domain-Driven Design (Evans, 2003).
-->

_Esta especificación es el **acuerdo de negocio** —a la manera de un project charter— entre el Product Owner y el equipo. Se escribe en el **lenguaje del dominio (DDD)**: negocio y comportamiento, no implementación (lo técnico vive en los issues)._

## Metadatos

| Campo            | Valor                                |
| ---------------- | ------------------------------------ |
| ID               | REQ-{{DATE}}-XXX                     |
| Sistema          | <!-- Valor del catálogo oficial -->  |
| Proyecto         | <!-- Nombre del proyecto -->         |
| Solicitante      | <!-- Área de Procesos -->            |
| Prioridad        | <!-- Alta / Media / Baja -->         |
| Analista QA      | <!-- Nombre Apellido -->             |
| Analista Dev     | <!-- Nombre Apellido -->             |
| Fecha de emisión | {{DATE}}                             |
| Fuentes          | <!-- PPT, mockups, correos, enlaces --> |

## 1. Fecha de compromiso

<!-- Fecha comprometida de entrega, en ISO AAAA-MM-DD. Obligatoria: el gate la
     exige. Puede crecer a un mini-cronograma (hitos + fechas). -->

| Hito                 | Fecha (AAAA-MM-DD)   |
| -------------------- | -------------------- |
| Entrega comprometida | <!-- AAAA-MM-DD -->  |

## 2. Historias de Usuario

### HU-1: <!-- Título descriptivo -->

**As a (Como)** <!-- rol del usuario -->,
**I want (Quiero)** <!-- acción que desea realizar -->,
**So that (Para)** <!-- beneficio o valor que obtiene -->.

#### Acceptance Criteria

<!-- La columna AC lleva SOLO el número (1, 2, …). La numeración reinicia en cada
     historia, así que el id se califica con ella: el 3er AC de la HU-2 es
     US2-AC3 — eso es lo que debe listar el `covers:` de una issue. Mantén los
     guiones del separador moderados — no los amplíes al ancho del texto, o la
     exportación a PDF parte la columna. Cada AC es, además, su test de
     aceptación (los tests se escriben en desarrollo). -->

| AC  | Given (Dado que)        | When (Cuando)        | Then (Entonces)        |
| --- | ----------------------- | -------------------- | ---------------------- |
| 1   | <!-- Contexto/precondición --> | <!-- Acción que ocurre --> | <!-- Resultado esperado --> |

<!-- Duplicar el bloque HU-N para más historias. -->

## 3. Alcance Explícito

### Incluye

- <!-- Qué SÍ abarca esta especificación -->

### NO incluye

- <!-- Qué queda fuera explícitamente -->

## 4. Dominio y reglas de negocio

<!-- Lenguaje ubicuo (DDD): glosario del dominio, reglas de negocio transversales
     y actores/permisos que aplican a las historias. Solo negocio — la
     implementación va en los issues. -->

- **Actores / permisos:** <!-- quién puede hacer qué -->
- **Glosario:** <!-- término del dominio: definición (cada término una sola vez) -->
- **Reglas:** <!-- regla de negocio transversal que comparten las historias -->
