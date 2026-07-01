# Especificación de Requerimiento

> **Todos los campos de este documento son obligatorios.**
> Historias de usuario según *User Stories Applied* (Mike Cohn, 2004).
> Acceptance Criteria en formato *Given-When-Then* — BDD (Dan North, 2006).
> Estrategia de testing alineada con *TDD* (Kent Beck, 2002).
> Las decisiones se sustentan en **evidencia de experimentos, no en inferencia**.

## Metadatos

| Campo          | Valor                                |
| -------------- | ------------------------------------ |
| ID             | REQ-{{DATE}}-XXX                     |
| Sistema        | <!-- Valor del catálogo oficial -->  |
| Proyecto       | <!-- Nombre del proyecto -->         |
| Solicitante    | <!-- Área de Procesos -->            |
| Prioridad      | <!-- Alta / Media / Baja -->         |
| Analista QA    | <!-- Nombre Apellido -->             |
| Analista Dev   | <!-- Nombre Apellido -->             |
| Fecha          | {{DATE}}                             |

## 1. Historias de Usuario

### HU-1: <!-- Título descriptivo -->

**As a (Como)** <!-- rol del usuario -->,
**I want (Quiero)** <!-- acción que desea realizar -->,
**So that (Para)** <!-- beneficio o valor que obtiene -->.

#### Acceptance Criteria

<!-- La columna AC lleva SOLO el número (1, 2, …); el id es AC-<número>. Mantén
     los guiones del separador moderados — no los amplíes al ancho del texto, o
     la exportación a PDF parte la columna. -->

| AC  | Given (Dado que)        | When (Cuando)        | Then (Entonces)        |
| --- | ----------------------- | -------------------- | ---------------------- |
| 1   | <!-- Contexto/precondición --> | <!-- Acción que ocurre --> | <!-- Resultado esperado --> |

<!-- Duplicar el bloque HU-N para más historias. -->

## 2. Estrategia de Testing

Definir **qué tipos de tests** se necesitan y **qué validan**, sin entrar en nombres de funciones ni código.

| Tipo        | Qué debe validar                                            | AC asociados   |
| ----------- | ----------------------------------------------------------- | -------------- |
| Unit        | <!-- Ej. Validación de campos, regla de no-duplicados -->   | <!-- AC-1 -->  |
| Integration | <!-- Ej. Persistencia correcta en base de datos -->         | <!-- AC-2 -->  |
| E2E         | <!-- Ej. Flujo completo desde la UI — o N/A -->             | <!-- AC-1 -->  |

## 3. Alcance Explícito

### Incluye

- <!-- Qué SÍ abarca este requerimiento -->

### NO incluye

- <!-- Qué queda fuera explícitamente -->

## 4. Decisiones (evidencia)

> Cada decisión clave debe citar el experimento que la sustenta (una sonda
> desechable: una consulta a BD, correr un contenedor, llamar un API), con un
> handle re-verificable — no una suposición.

- **Decisión**: <!-- la decisión tomada -->. **Evidencia**: <!-- experimento + resultado, con handle re-verificable: una consulta, un comando, `inline-code`, o un archivo:línea -->.

## Anexos

<!-- Diagramas, mockups, notas técnicas, referencias o cualquier material de apoyo. -->
