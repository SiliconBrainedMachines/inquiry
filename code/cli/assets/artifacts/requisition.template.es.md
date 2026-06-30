# Solicitud de Requerimiento

> **Todos los campos de esta solicitud son obligatorios.**
> Estructura basada en *Gap Analysis* — BABOK® v3 (IIBA), cap. 8.
> Terminología de dominio alineada con *Ubiquitous Language* — Domain-Driven Design (Eric Evans, 2003).

## Metadatos

| Campo       | Valor                                          |
| ----------- | ---------------------------------------------- |
| Sistema     | <!-- Valor del catálogo oficial -->            |
| Proyecto    | <!-- Ej. Motores Fase 2 -->                    |
| Solicitante | <!-- Nombre — Área de Procesos -->             |
| Fecha       | {{DATE}}                                       |
| Contacto    | <!-- Nombre y medio de contacto -->            |

**Urgencia:**

- [ ] Crítica
- [ ] Alta
- [ ] Normal

## 1. Estado Actual (AS-IS)

<!-- BABOK® — Current State Description -->

Describa cómo se hace **hoy** lo que quiere cambiar. Si es algo nuevo que no existe, escriba: *"No existe actualmente"*.

> **Ejemplo:** *"Actualmente el registro de facturas se realiza en una hoja de Excel compartida. Cada analista abre el archivo, localiza la última fila e ingresa los datos manualmente. En ocasiones dos personas editan simultáneamente y se pierden registros."*

<!-- Usar el lenguaje ubicuo del dominio (Ubiquitous Language — DDD). -->

## 2. Estado Deseado (TO-BE)

<!-- BABOK® — Future State Description -->

Describa cómo **quiere que funcione** en el futuro. No necesita dar la solución técnica, solo el resultado esperado.

> **Ejemplo:** *"El sistema debe contar con un formulario de registro de facturas con los campos: número, monto, proveedor y fecha. No debe permitir registros duplicados. Al guardar, la información debe quedar disponible para todos los usuarios sin riesgo de pérdida."*

<!-- Usar el lenguaje ubicuo del dominio (Ubiquitous Language — DDD). -->

## Anexos

<!-- Capturas, documentos, ejemplos, mockups, diagramas, correos previos o cualquier material de apoyo. -->
