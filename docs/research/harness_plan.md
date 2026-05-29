# Harness Plan para Inquiry

**Tipo de documento:** plan de ejecución  
**Estado:** borrador de trabajo  
**Fecha:** mayo 2026

---

## 1. Objetivo

Este documento traduce [harness_excellence_proposal.md](harness_excellence_proposal.md) a un plan operativo y secuenciado.

Su propósito no es volver a justificar por qué Inquiry debe evolucionar como harness, sino responder una pregunta más concreta:

> ¿Qué debemos hacer, en qué orden, con qué entregables y con qué criterio de done para llevar Inquiry a un harness claramente mejor?

La tesis práctica del plan es esta:

**Inquiry ya es un harness suficiente para operar; el siguiente paso no es expandirlo indiscriminadamente, sino cerrar su arquitectura en torno a task contracts, sensor stack, context policy, observability y eval-backed evolution.**`

---

## 2. Resultado esperado

Al completar este plan, Inquiry debería haber pasado de un estado de **controlled workflow / early contracted harness** a un estado de **contracted harness sólido con base real para sensorized harness**.

Eso significa que, al menos, deberán quedar resueltas estas propiedades:

1. el agente recibe un entorno de tarea explícito y acotado
2. las validaciones mínimas de trabajo están ordenadas y nombradas
3. la política de contexto entre fases deja de ser implícita
4. el harness deja trazas y métricas más útiles sobre su propia operación
5. la evolución del método puede apoyarse en evidencia más estructurada

---

## 3. Alcance

### 3.1 En alcance

- task environment contract
- sensor taxonomy mínima
- policy de contexto por fase
- observabilidad básica del harness
- base inicial de eval engineering aplicada a Inquiry
- alineación documental entre arquitectura, roadmap y nueva capa de harness

### 3.2 Fuera de alcance por ahora

- reactivación multi-target completa
- base de datos de métricas como requisito inmediato
- más APEs o ampliación del roster
- automatización total sin gate humano
- reemplazo de Memory as Code por infraestructura externa

---

## 4. Principios de ejecución

### 4.1 Contract-first

No abrir sensores ni evals pesadas antes de definir mejor la tarea que el agente está intentando ejecutar.

### 4.2 Shift-left

Todo feedback barato y útil debe moverse lo más temprano posible dentro del ciclo.

### 4.3 Small-core

No introducir nuevas abstracciones si el mismo resultado puede lograrse extendiendo `inquiry-context`, skills o contratos existentes.

### 4.4 Evidence-before-doctrine

Las mutaciones del método y del harness deben apoyarse en evidencia observable, no solo en preferencia estilística.

### 4.5 Host-boundary clarity

Cada mejora debe distinguir si pertenece al host agent, al adapter, o al outer harness de Inquiry.

---

## 5. Fases del plan

El plan se divide en cuatro fases consecutivas. No recomiendo paralelizarlas salvo en trabajo documental preliminar.

## 5.1 Fase 1 — Task Contract Foundation

### Objetivo

Hacer que la tarea deje de ser una inferencia implícita y se convierta en un contrato explícito visible para el agente.

### Entregables

1. `docs/spec/task-environment-contract.md`
2. Extensión de `inquiry-context` con los siguientes campos mínimos:
   - `project_root`
   - `task_id`
   - `input_artifacts`
   - `expected_outputs`
   - `editable_surfaces`
   - `read_only_surfaces`
   - `validation_commands`
   - `done_criteria`
3. Regla de una tarea por ciclo reforzada a nivel de contrato
4. Primer diseño del módulo futuro `iq task`

### Dependencias

- ninguna fuerte previa; esta es la base del resto del plan

### Issues relacionadas

- `#178`
- `#49`
- `#60`
- `#149`

### Done

La fase está hecha cuando el agente puede saber, desde el prompt efectivo y sin interpretación adicional frágil:

- qué trabajo tiene asignado
- qué superficies puede editar
- qué debe dejar como salida
- cómo demostrar que terminó

### Riesgo principal

- sobrediseñar el contrato antes de ver una primera versión mínima funcionando

### Mitigación

- empezar por un contrato pequeño y extensible, no por una ontología completa

---

## 5.2 Fase 2 — Sensor Stack Minimum Viable Harness

### Objetivo

Definir una arquitectura de sensores mínima pero explícita, empezando por los puntos donde Inquiry ya tiene gates o obligaciones claras.

### Entregables

1. `docs/spec/sensor-taxonomy.md`
2. Clasificación inicial:
   - `local_fast`
   - `pre_transition`
   - `pre_pr`
   - `ci_required`
   - `continuous_drift`
   - `runtime`
   - `inferential_optional`
3. Formalización del gate pre-PR en END
4. Reglas para checks obligatorios de EXECUTE y END
5. Primer diseño de `iq task check` o primitive equivalente

### Dependencias

- Fase 1, porque los sensores deben correr contra un task contract más claro

### Issues relacionadas

- `#163`
- `#127`
- `#167`

### Done

La fase está hecha cuando:

1. existe una taxonomía de sensores escrita y estable
2. END ya no depende solo de “crear PR” como ritual de cierre
3. el camino de validación del ciclo es legible para humano y agente

### Riesgo principal

- convertir “sensor” en un nombre rimbombante para checks ya existentes sin cambiar el sistema real

### Mitigación

- para cada sensor, definir momento, autoridad, costo y efecto operativo

---

## 5.3 Fase 3 — Context Policy and Memory Operations

### Objetivo

Pasar de Memory as Code como intuición correcta a Memory as Code como policy operacional explícita.

### Entregables

1. `docs/spec/context-policy.md`
2. Política de progressive disclosure por fase
3. Política de handoff entre ANALYZE, PLAN y EXECUTE
4. Diseño detallado de `iq memory`
5. Revisión de `doc-read` y skills relacionadas bajo la lógica de retrieval policy

### Dependencias

- Fase 1, para saber qué parte del task contract debe entrar al contexto
- idealmente Fase 2, para saber qué sensores deben ser visibles antes y después de actuar

### Issues relacionadas

- `#147`
- bloque mid-term de `iq memory`

### Done

La fase está hecha cuando:

1. queda explícito qué entra al contexto por fase
2. queda explícito qué se recupera on-demand
3. queda explícito qué artefactos son handoff authority
4. la política puede explicarse sin apelar a “el agente ya sabrá leer el repo”

### Riesgo principal

- documentar demasiado y terminar con una policy inmanejable

### Mitigación

- preferir políticas breves, con ejemplos y defaults antes que listas exhaustivas de excepciones

---

## 5.4 Fase 4 — Harness Observability and Eval Foundation

### Objetivo

Dar al proyecto una capa mínima de observabilidad del harness y una base inicial para eval engineering aplicada al propio sistema.

### Entregables

1. `docs/spec/harness-observability.md`
2. `docs/spec/eval-model.md`
3. Extensión de la evidencia actual para capturar, al menos:
   - transiciones ejecutadas
   - sensores corridos
   - fallos detectados
   - retries
   - duración por fase
4. Taxonomía inicial de fallos del harness
5. Primer conjunto de evals mínimas del propio harness

### Dependencias

- Fases 1 a 3, porque sin task contract, sensor stack y context policy la observabilidad carece de semántica suficientemente estable

### Issues relacionadas

- `#156`
- `#141`

### Done

La fase está hecha cuando:

1. podemos explicar con evidencia dónde se bloquea el sistema
2. podemos distinguir mejor entre fallo del modelo, del host o del harness de Inquiry
3. DARWIN dispone de señales más fuertes que la pura lectura narrativa del ciclo

### Riesgo principal

- introducir una capa de medición demasiado grande demasiado pronto

### Mitigación

- comenzar con pocas métricas de alta señal y pocos failure classes, no con un dashboard maximalista

---

## 6. Orden de ejecución sugerido

El orden recomendado es estricto:

1. **Fase 1** — Task Contract Foundation
2. **Fase 2** — Sensor Stack Minimum Viable Harness
3. **Fase 3** — Context Policy and Memory Operations
4. **Fase 4** — Harness Observability and Eval Foundation

La razón es simple:

- primero se acota la tarea
- luego se ordena la validación
- luego se optimiza la política de contexto
- finalmente se mide y se compara el propio harness

---

## 7. Backlog mínimo inicial

Este es el backlog mínimo que yo abriría o re-ordenaría inmediatamente.

### Bloque A — contrato de tarea

1. Persistir `project_root` en `inquiry-context`
2. Diseñar `task-environment-contract.md`
3. Definir campos mínimos obligatorios por fase
4. Revisar single-task-per-cycle como invariante de contrato

### Bloque B — sensores

1. Diseñar `sensor-taxonomy.md`
2. Formalizar `pre-pr` como gate de END
3. Hacer visible el gate de version bump / release proposal en EXECUTE → END
4. Declarar sensores mínimos por fase

### Bloque C — contexto y memoria

1. Diseñar `context-policy.md`
2. Definir handoff authority de `diagnosis.md` y `plan.md`
3. Diseñar `iq memory`
4. Revisar `doc-read` bajo retrieval policy

### Bloque D — observabilidad y evals

1. Diseñar `harness-observability.md`
2. Diseñar `eval-model.md`
3. Extender estructura de métricas / trazas
4. Catalogar fallos recurrentes del harness

---

## 8. Hitos sugeridos

### Hito 1 — Contracted Harness MVP

Se alcanza cuando:

- existe task contract mínimo
- `project_root` y outputs esperados están en `inquiry-context`
- existe una definición breve de done por fase

### Hito 2 — Sensorized END

Se alcanza cuando:

- END incluye un gate pre-PR explícito
- EXECUTE y END tienen sensores mínimos documentados
- el ciclo ya no depende solo de revisión informal antes del PR

### Hito 3 — Context Policy MVP

Se alcanza cuando:

- existe policy de contexto por fase
- está claro qué entra upfront y qué entra on-demand
- los handoffs entre fases tienen autoridad explícita

### Hito 4 — Observable Harness MVP

Se alcanza cuando:

- el harness deja trazas mínimas sobre cómo operó
- hay taxonomía inicial de fallos
- las mutaciones de DARWIN pueden anclarse mejor en evidencia

---

## 9. Definición de done global del plan

El plan completo puede considerarse sustancialmente cumplido cuando se den estas condiciones simultáneas:

1. Inquiry tiene un task environment contract legible y usado por el runtime
2. Inquiry tiene una taxonomía de sensores aplicada al menos en EXECUTE y END
3. Inquiry tiene una context policy por fase escrita y coherente con Memory as Code
4. Inquiry registra suficiente evidencia para observar comportamiento del harness y no sólo resultados finales
5. Inquiry puede empezar a convertir fallos recurrentes en primitive evals del propio sistema

Si esas cinco condiciones se cumplen, Inquiry habrá dejado atrás el estado de harness implícito temprano y entrado en una etapa de harness deliberado y claramente superior.

---

## 10. Qué NO hacer todavía

Para proteger el foco del plan, recomiendo no hacer todavía lo siguiente:

1. abrir el frente multi-target como prioridad principal
2. crear nuevos agentes para tapar problemas del harness
3. introducir bases externas de memoria como solución prematura
4. construir una capa de eval engineering demasiado sofisticada antes de cerrar task contract y sensor stack
5. convertir toda mejora metodológica en nueva surface area del CLI sin pasar por una spec mínima

---

## 11. Próximas acciones inmediatas

Si hay que empezar mañana, yo haría esto en este orden:

1. abrir o actualizar la issue de `project_root` como parte explícita de Task Contract Foundation
2. redactar `docs/spec/task-environment-contract.md`
3. abrir la spec `docs/spec/sensor-taxonomy.md`
4. bajar `#163` a una definición concreta de gate pre-PR
5. preparar un primer borrador de `docs/spec/context-policy.md`

Eso ya crearía una columna vertebral real para el plan, sin esperar a tener toda la infraestructura futura del CLI lista.

---

## 12. Conclusión

`harness_plan.md` existe para reducir ambigüedad ejecutiva.

La dirección ya está clara: Inquiry debe consolidarse como outer harness excelente para trabajo agentic de software. Lo que faltaba era una secuencia corta, comprensible y disciplinada para avanzar hacia ese estado sin dispersión.

En una frase:

> **primero task contract, luego sensor stack, luego context policy, y sólo después observability + eval foundation.**

Ese orden protege la simplicidad actual del proyecto y, al mismo tiempo, abre el camino correcto para llevarlo a un harness significativamente mejor.
