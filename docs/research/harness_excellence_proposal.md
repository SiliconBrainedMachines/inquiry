# Propuesta concreta de Harness Excellence para Inquiry

**Tipo de documento:** propuesta estratégica y de implementación  
**Estado:** borrador de trabajo  
**Fecha:** mayo 2026

---

## 1. Propósito

Este documento propone un camino concreto para llevar **Inquiry** desde su estado actual de metodología operativa con CLI hacia un **harness excelente** para agentes de software.

No parte de cero. Parte de una constatación ya documentada en [harness_engineering.md](harness_engineering.md), [agent_engineering_taxonomy.md](agent_engineering_taxonomy.md), [../architecture.md](../architecture.md) y [../roadmap.md](../roadmap.md):

**Inquiry ya es un harness en sentido sustantivo, pero todavía no es un harness excelente.**

La diferencia entre ambas cosas no es cosmética. Un harness excelente no solo impone un proceso; también:

1. define entornos de tarea acotados y verificables
2. expone sensores útiles y ordenados por costo y criticidad
3. tiene una política explícita de contexto y memoria
4. convierte fallos recurrentes en evals reutilizables
5. produce observabilidad suficiente para mejorar el propio harness

Este documento traduce esa diferencia en workstreams, entregables, fases y criterios de éxito.

---

## 2. Tesis central

La tesis de esta propuesta es simple:

> Inquiry debe evolucionar desde “método disciplinado con FSM y Memory as Code” hacia “outer harness explícito, sensorizado, eval-backed y contract-first para trabajo agentic de software”.

Eso implica una evolución en cuatro ejes simultáneos:

1. de **proceso** a **entorno de tarea**
2. de **artefacto persistido** a **política operacional explícita**
3. de **gate manual + tests locales** a **arquitectura de sensores**
4. de **mutación doctrinal** a **mutación respaldada por evidencia estructurada**

---

## 3. Qué significa “harness excellence” en Inquiry

En el contexto de Inquiry, **harness excellence** no significa automatizarlo todo ni añadir más agentes. Significa que el sistema alcance un nivel de madurez donde:

1. el agente siempre sabe con precisión qué tarea tiene, qué puede tocar, qué debe producir y cómo validar su trabajo
2. el repo ofrece al agente una memoria, contexto y mapa de navegación suficientes sin sobrecargar su ventana de atención
3. las validaciones están ordenadas por costo, momento y autoridad, desde checks rápidos hasta gates más pesados
4. el ciclo deja trazas y métricas que sirven no solo para observar el resultado, sino para mejorar el propio método
5. la diferencia entre lo que aporta el host tool y lo que aporta Inquiry queda explícita y portable entre targets

Si estas cinco condiciones se cumplen de forma estable, Inquiry deja de ser solo una metodología desplegada por CLI y pasa a ser un harness sobresaliente.

---

## 4. Diagnóstico breve del estado actual

### 4.1 Fortalezas ya presentes

Inquiry ya tiene varias piezas que muchos sistemas agentic todavía no tienen:

- **FSM total** con transiciones explícitas y CLI-governed
- **Memory as Code** en `.inquiry/`, `cleanrooms/` y `docs/`
- **prompt assembly inspeccionable** mediante `iq ape prompt`
- **skills protocolizadas** en lugar de comportamiento implícito
- **handoffs duraderos** entre fases por medio de artefactos
- **gate humano** en transiciones críticas
- **colección inicial de métricas** vía `.inquiry/metrics.yaml`

Estas piezas justifican afirmar que Inquiry ya es un harness real.

### 4.2 Gaps principales

Los principales huecos observables hoy son estos:

1. **Task environment insuficientemente formalizado**  
   Hay contexto y paths, pero todavía no existe un contrato de tarea de primer orden con superficie editable, entradas, salidas y validaciones explícitas.

2. **Sensores poco formalizados**  
   Existen checks y gates, pero no una taxonomía nítida de sensores locales, CI, continuos y runtime.

3. **Política de contexto implícita**  
   Inquiry tiene memoria como código, pero no una policy explícita de progressive disclosure, compaction y retrieval por fase.

4. **Eval engineering parcial**  
   Hay métricas y gates, pero todavía no una disciplina robusta para convertir fallos recurrentes en benchmarks, graders y regresiones.

5. **Observabilidad insuficiente del propio harness**  
   El sistema produce artefactos, pero aún no produce trazas suficientemente ricas sobre qué hizo el agente, qué validó, dónde falló y qué reglas activó.

---

## 5. Principios de diseño propuestos

La propuesta se apoya en ocho principios.

### 5.1 Menos primitivas, más nítidas

Harness excellence no se logra añadiendo agentes ni proliferando comandos arbitrarios. Se logra con pocas primitivas muy bien definidas:

- task environment
- sensors
- context policy
- eval layer
- observability

### 5.2 Contract-first execution

Antes de ejecutar, el agente debe ver un contrato explícito de tarea. No basta con “leer el issue y arrancar”.

### 5.3 Determinismo primero, juicio después

Los sensores computacionales deben formar la columna vertebral del sistema. Los inferenciales deben complementar, no reemplazar.

### 5.4 Context is a budget

La memoria como código es buena; la memoria como código sin política explícita de uso acaba generando ruido. Inquiry debe pasar de “persistimos artefactos” a “sabemos qué artefactos entran cuándo y por qué”.

### 5.5 Repo as system of record

Toda pieza necesaria para operar el harness debe vivir en el repo o ser derivable desde él. Nada crítico debe depender de conocimiento tácito o interfaces mágicas del host.

### 5.6 Shift feedback left

Todo fallo detectable antes de un gate tardío debe detectarse antes. El harness excelente minimiza iteraciones costosas y tardías.

### 5.7 Evolución respaldada por evidencia

DARWIN debe proponer mutaciones del método, pero crecientemente sobre evidencia estructurada, no solo sobre percepción cualitativa.

### 5.8 Portabilidad explícita

Inquiry debe describir qué partes pertenecen al host harness y cuáles pertenecen al outer harness de Inquiry. Sin esa distinción, la portabilidad multi-target se vuelve confusa.

---

## 6. Modelo de madurez propuesto

Para que la conversación sea operativa, propongo modelar el progreso de Inquiry en cinco niveles.

### Nivel 1 — Prompt Pack

El sistema es esencialmente un conjunto de prompts o personas.

### Nivel 2 — Controlled Workflow

El sistema ya tiene fases, handoffs y cierto control de transición.

### Nivel 3 — Contracted Harness

El sistema ya define entornos de tarea explícitos, memoria duradera y superficies de trabajo acotadas.

### Nivel 4 — Sensorized Harness

El sistema ya tiene sensores ordenados por costo y autoridad, observabilidad estructurada y políticas de contexto explícitas.

### Nivel 5 — Eval-Backed Self-Improving Harness

El sistema convierte fallos en evals, compara variantes del harness y mejora sus componentes con evidencia acumulativa.

### Lectura actual de Inquiry

Mi lectura actual es esta:

**Inquiry está entre Nivel 2 alto y Nivel 3 temprano.**

Tiene mucho más que un workflow superficial, pero todavía no tiene del todo consolidado el task contract, la capa de sensores ni la infraestructura de eval-backed evolution que caracterizaría a un Nivel 4 o 5.

---

## 7. Objetivo de arquitectura

El objetivo no debería formularse como “agregar más features al CLI”, sino así:

> Construir una capa explícita de outer harness sobre el host agent que defina task environment, context policy, sensor stack, observability y eval-backed evolution sin perder la simplicidad actual del modelo FSM.

Esto preserva el corazón del proyecto:

- método primero
- proceso explícito
- memoria versionada
- pocos agentes, bien delimitados

pero añade lo que hoy falta para excelencia de harness.

---

## 8. Workstreams propuestos

La propuesta se organiza en seis workstreams.

### 8.1 Workstream A — Task Environment Contract

**Problema**  
Hoy `inquiry-context` ya resuelve rutas y superficies útiles, pero todavía no constituye un contrato de tarea de primer orden.

**Objetivo**  
Que cada ciclo y cada fase puedan exponer un entorno de tarea explícito, acotado y verificable.

**Entregables propuestos**

1. Especificación `task-environment-contract.md`
2. Extensión de `inquiry-context` con:
   - `project_root`
   - `task_id`
   - `input_artifacts`
   - `expected_outputs`
   - `editable_surfaces`
   - `read_only_surfaces`
   - `validation_commands`
   - `done_criteria`
   - `risk_class`
3. Reglas por fase sobre qué campos son obligatorios
4. Primer diseño de `iq task` como módulo futuro

**Issues ya cercanas**

- `#178` persistir project root en inquiry-context
- `#49` single-task-per-cycle
- `#60` cross-repo dependency chains
- `#149` workspace discovery

**Criterio de éxito**

Un agente puede recibir una tarea y saber, sin inferencia ambigua adicional, qué puede tocar, qué debe producir y cómo demostrar que terminó.

### 8.2 Workstream B — Sensor Architecture

**Problema**  
El sistema tiene checks y gates, pero no una arquitectura explícita de sensores.

**Objetivo**  
Definir una taxonomía formal de sensores y mover feedback útil hacia las partes más tempranas del ciclo.

**Entregables propuestos**

1. Especificación `sensor-taxonomy.md`
2. Clasificación mínima:
   - local-fast
   - pre-transition
   - pre-PR
   - CI-required
   - continuous-drift
   - runtime
   - inferential-optional
3. Declaración por fase de sensores mínimos esperados
4. Diseño de una primitive futura tipo `iq task check` o equivalente
5. Integración explícita del gate pre-PR dentro de END

**Issues ya cercanas**

- `#163` formal pre-PR inspection gate
- `#127` version bump / release proposal antes de completion
- `#167` simplificación de EXECUTE una vez revalidados límites

**Criterio de éxito**

Todo cambio pasa por un camino de validación legible, ordenado por costo y sin depender de criterio informal del agente o del humano en cada corrida.

### 8.3 Workstream C — Context Policy and Memory Operations

**Problema**  
Memory as Code existe, pero la política de uso del contexto sigue siendo más emergente que especificada.

**Objetivo**  
Formalizar qué entra al contexto, qué se recupera on-demand, qué se resume y qué debe persistirse fuera de la ventana de contexto.

**Entregables propuestos**

1. Especificación `context-policy.md`
2. Política de progressive disclosure por fase
3. Reglas de handoff entre ANALYZE → PLAN → EXECUTE
4. Diseño del módulo futuro `iq memory`
5. Revisión de `doc-read` bajo la óptica de retrieval policy

**Issues ya cercanas**

- `iq memory` ya aparece como mid-term en roadmap
- `#147` extender source gathering más allá de `research`

**Criterio de éxito**

El sistema logra más foco y menos ruido sin sacrificar continuidad entre sesiones o fases.

### 8.4 Workstream D — Eval Engineering for Inquiry Itself

**Problema**  
Inquiry ya tiene gates y `metrics.yaml`, pero todavía no tiene una capa fuerte de eval engineering aplicada al propio harness.

**Objetivo**  
Que los fallos recurrentes puedan convertirse en pruebas comparables del método y del runtime, no solo en intuiciones o tickets aislados.

**Entregables propuestos**

1. Especificación `eval-model.md`
2. Taxonomía de fallos del harness
3. Conversión de fallos repetidos en datasets o suites mínimas
4. Graders sencillos para outputs no binarios donde aplique
5. Política para distinguir:
   - fallo del modelo
   - fallo del host harness
   - fallo del Inquiry harness

**Issues ya cercanas**

- `#156` GitHub platform usage metrics
- `#141` centralización de métricas cuando el archivo deje de alcanzar

**Criterio de éxito**

Las mutaciones del método pueden compararse con evidencia, aunque sea inicialmente modesta, en lugar de depender solo de lectura narrativa de los ciclos.

### 8.5 Workstream E — Harness Observability

**Problema**  
Hoy sabemos bastante del resultado del ciclo, pero poco del comportamiento interno del harness durante la ejecución.

**Objetivo**  
Hacer observable el comportamiento operativo de Inquiry como sistema de control.

**Entregables propuestos**

1. Especificación `harness-observability.md`
2. Registro estructurado por ciclo de:
   - transiciones
   - skills invocadas
   - sensores corridos
   - fallos detectados
   - retries
   - tiempo por fase
3. Diferenciación entre `metrics.yaml` de resultado y trazas de ejecución
4. Primer esquema de `run trace` por ciclo

**Criterio de éxito**

El maintainer puede responder con evidencia preguntas del tipo:

- ¿Dónde se bloquea más el sistema?
- ¿Qué gates detectan más problemas?
- ¿Qué skill produce más valor real?
- ¿Qué tipos de retrabajo son recurrentes?

### 8.6 Workstream F — Host Boundary and Multi-Target Portability

**Problema**  
Inquiry ya funciona como outer harness, pero la frontera entre lo que aporta el host y lo que aporta Inquiry todavía no está descrita de forma completamente formal.

**Objetivo**  
Definir un adapter contract claro para que la portabilidad multi-target se apoye en una interfaz estable y no en comportamiento incidental de un host concreto.

**Entregables propuestos**

1. Documento `host-adapter-contract.md`
2. Lista de capabilities mínimas exigidas a un target
3. Lista de garantías que Inquiry espera del host
4. Lista de garantías que Inquiry debe aportar por sí mismo
5. Harness comparativo multi-target en fase posterior

**Issues ya cercanas**

- Reactivación multi-target en roadmap
- `#181` dispatch correcto de identidad esperada por el host

**Criterio de éxito**

La misma metodología y outer harness pueden migrar entre hosts con cambios acotados en el adapter, no en el corazón del sistema.

---

## 9. Fases de implementación recomendadas

No recomiendo atacar los seis workstreams a la vez. El orden importa.

### Fase 0 — Nombrar y cerrar el modelo

**Objetivo**  
Consolidar el vocabulario para que el equipo deje de pensar en Inquiry como solo metodología o solo prompt packaging.

**Estado**  
Parcialmente hecho con:

- actualización de `architecture.md`
- actualización de `roadmap.md`
- `harness_engineering.md`
- `agent_engineering_taxonomy.md`

**Salida esperada**  
Lenguaje común y tesis estable sobre Inquiry como outer harness.

### Fase 1 — Task Contract mínimo viable

**Objetivo**  
Formalizar el task environment con el menor cambio posible en el runtime actual.

**Contenido**

1. resolver `project_root`
2. extender `inquiry-context`
3. definir `done_criteria`
4. explicitar superficies editables y read-only

**Por qué va primero**  
Porque todo lo demás depende de que la tarea esté bien acotada.

### Fase 2 — Sensor stack mínimo viable

**Objetivo**  
Definir y empezar a aplicar una arquitectura de sensores.

**Contenido**

1. taxonomía de sensores
2. pre-PR gate formal
3. version/release gate visible
4. checks locales rápidos claramente nombrados

**Por qué va segundo**  
Porque sin sensores explícitos el harness no puede autocorregirse con disciplina.

### Fase 3 — Context policy mínima viable

**Objetivo**  
Hacer explícita la política de memoria, retrieval y handoff.

**Contenido**

1. `iq memory` spec
2. retrieval policy por fase
3. compaction / summarization guidance
4. fortalecimiento de handoff artifacts

**Por qué va tercero**  
Porque con task contract y sensores ya definidos, la política de contexto puede optimizarse contra un objetivo operacional concreto.

### Fase 4 — Observability + Eval foundation

**Objetivo**  
Hacer visible el comportamiento del harness y convertir fallos en señales reutilizables.

**Contenido**

1. trazas por ciclo
2. extensión del modelo de métricas
3. catálogo de fallos recurrentes
4. primeras suites o graders del propio harness

**Por qué va cuarto**  
Porque sin las fases previas, la observabilidad generaría datos antes de que el sistema tenga una semántica suficientemente limpia.

### Fase 5 — Comparative antifragility harness

**Objetivo**  
Comparar hosts y variantes del harness con evidencia acumulada.

**Contenido**

1. harness comparativo multi-target
2. experimentos controlados de metodología vs host
3. evolución respaldada por datos de varias corridas

**Por qué va último**  
Porque sólo vale la pena cuando el núcleo del harness ya está mínimamente bien especificado.

---

## 10. Mapa a issues existentes

Esta propuesta no ignora el backlog actual; lo reorganiza.

### Críticos para Fase 1

- `#178` project root en inquiry-context
- `#49` single-task-per-cycle
- `#149` workspace discovery

### Críticos para Fase 2

- `#163` pre-PR inspection gate
- `#127` version bump y release proposal antes del cierre
- `#167` simplificar EXECUTE si el contrato resultante lo permite

### Críticos para Fase 3

- `#185` `iq skill` para gobernar mejor skills privadas
- `#147` ampliar source-gathering capability

### Críticos para Fase 4

- `#156` métricas de uso GitHub
- `#141` store más robusto cuando file-based evidence no baste

### Críticos para Fase 5

- reactivación multi-target del roadmap
- `#181` corrección de dispatch esperado por el host

---

## 11. Cambios documentales y técnicos sugeridos

### 11.1 Nuevos documentos sugeridos

1. `docs/spec/task-environment-contract.md`
2. `docs/spec/sensor-taxonomy.md`
3. `docs/spec/context-policy.md`
4. `docs/spec/eval-model.md`
5. `docs/spec/harness-observability.md`
6. `docs/spec/host-adapter-contract.md`

### 11.2 Nuevos módulos futuros del CLI

1. `iq task`
2. `iq memory`
3. posible superficie de checks o validation orchestration asociada a `task`

### 11.3 Cambios operativos de bajo riesgo

1. extender `inquiry-context` antes de inventar nuevos comandos
2. introducir sensores primero como contrato documental, luego como ejecución
3. enriquecer `.inquiry/metrics.yaml` y luego decidir si hace falta mover a store externo

---

## 12. Non-goals explícitos

Esta propuesta no recomienda:

1. Añadir más APEs como respuesta por defecto a los huecos del harness.
2. Convertir Inquiry en una plataforma generalista de agentes sin foco en software.
3. Introducir una base vectorial externa como memoria primaria.
4. Reemplazar el gate humano en transiciones de riesgo con autonomía ciega.
5. Construir una capa de eval engineering complejísima antes de tener task contracts y sensores mínimos.

---

## 13. Riesgos y mitigaciones

### 13.1 Riesgo: over-harnessing

**Descripción**  
El sistema puede volverse más complejo de lo que el problema exige.

**Mitigación**  
Cada workstream debe demostrar valor incremental y no solo sofisticación teórica.

### 13.2 Riesgo: documentos mejores que el runtime

**Descripción**  
La doctrina puede adelantarse demasiado a la implementación.

**Mitigación**  
Toda nueva spec debe mapear a una issue, comando, asset o protocolo concreto.

### 13.3 Riesgo: sensores sin autoridad real

**Descripción**  
Puede aparecer una capa de sensores más decorativa que efectiva.

**Mitigación**  
Distinguir explícitamente entre sensores informativos y sensores bloqueantes.

### 13.4 Riesgo: eval engineering prematura

**Descripción**  
Intentar medir demasiado pronto sin semántica estable del harness.

**Mitigación**  
Introducir evals del propio harness sólo después de cerrar mínimamente task contract, sensor stack y context policy.

### 13.5 Riesgo: lock-in al host actual

**Descripción**  
Que decisiones locales para Copilot contaminen el diseño del outer harness.

**Mitigación**  
Formalizar el adapter contract antes de reactivar multi-target.

---

## 14. Secuencia mínima recomendada

Si hubiera que reducir esta propuesta a una secuencia mínima de trabajo, yo haría esto:

1. cerrar `project_root` y task contract mínimo en `inquiry-context`
2. añadir el gate pre-PR formal en END
3. publicar una taxonomía de sensores y aplicarla al runtime actual
4. diseñar `iq memory` y la context policy por fase
5. enriquecer observabilidad y métricas del harness
6. recién entonces abrir el frente fuerte de eval engineering comparativa

Esta secuencia respeta la lógica del sistema: primero se acota la tarea, luego se ordena la validación, luego se optimiza el contexto, luego se mide la mejora.

---

## 15. Definición de éxito a 90 días

Una versión creíble de éxito en el corto plazo sería esta:

1. `inquiry-context` ya expone project root, outputs esperados y validaciones mínimas
2. END tiene un pre-PR inspection gate explícito
3. existe una taxonomía formal de sensores y está conectada al menos a EXECUTE y END
4. hay una policy inicial de contexto por fase, aunque sea austera
5. `metrics.yaml` o un artefacto hermano ya captura algo más que cierre de ciclo: también evidencia de validación o fallo

Si eso se logra, Inquiry pasaría de un Nivel 2 alto / Nivel 3 temprano a un **Nivel 3 sólido**, con base real para un salto posterior a harness sensorizado.

---

## 16. Conclusión

Inquiry no necesita reinventarse para llegar a harness excellence. Necesita **cerrar lo que ya insinuó correctamente**.

Ya tiene:

- método
- FSM
- Memory as Code
- handoffs
- skills
- gate humano

Lo que falta es completar la arquitectura alrededor de esas piezas para que formen un sistema de control más explícito, más observable y más medible.

La propuesta de este documento es precisamente esa: no añadir complejidad gratuita, sino convertir la disciplina ya existente en un harness de primera clase.

En una frase:

> **Harness excellence para Inquiry significa pasar de “proceso disciplinado” a “sistema disciplinado de task contracts, sensors, context policy, observability y eval-backed evolution”.**
