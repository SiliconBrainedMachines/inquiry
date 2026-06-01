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

Eso implica una evolución en cinco ejes simultáneos:

1. de **proceso** a **entorno de tarea**
2. de **interrogación reactiva** a **adquisición evidence-first antes de preguntar**
3. de **artefacto persistido** a **política operacional explícita**
4. de **gate manual + tests locales** a **arquitectura de sensores**
5. de **mutación doctrinal** a **mutación respaldada por evidencia estructurada**

---

## 3. Qué significa “harness excellence” en Inquiry

En el contexto de Inquiry, **harness excellence** no significa automatizarlo todo ni añadir más agentes. Significa que el sistema alcance un nivel de madurez donde:

1. el agente siempre sabe con precisión qué tarea tiene, qué puede tocar, qué debe producir y cómo validar su trabajo
2. ANALYZE adquiere evidencia suficiente antes de preguntar al usuario
3. el repo ofrece al agente una memoria, contexto y mapa de navegación suficientes sin sobrecargar su ventana de atención
4. las validaciones están ordenadas por costo, momento y autoridad, desde checks rápidos hasta gates más pesados
5. el ciclo deja trazas y métricas que sirven no solo para observar el resultado, sino para mejorar el propio método
6. la diferencia entre lo que aporta el host tool y lo que aporta Inquiry queda explícita y portable entre targets

Si estas seis condiciones se cumplen de forma estable, Inquiry deja de ser solo una metodología desplegada por CLI y pasa a ser un harness sobresaliente.

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

2. **ANALYZE todavía demasiado implícito o interrogativo**  
   Hay evidencia disponible en repo, artefactos, docs y tests, pero el sistema todavía no expresa con suficiente claridad el orden evidence-first antes de preguntar al usuario.

3. **Sensores poco formalizados**  
   Existen checks y gates, pero no una taxonomía nítida de sensores locales, CI, continuos y runtime.

4. **Política de contexto implícita**  
   Inquiry tiene memoria como código, pero no una policy explícita de progressive disclosure, compaction y retrieval por fase.

5. **Eval engineering parcial**  
   Hay métricas y gates, pero todavía no una disciplina robusta para convertir fallos recurrentes en benchmarks, graders y regresiones.

6. **Observabilidad insuficiente del propio harness**  
   El sistema produce artefactos, pero aún no produce trazas suficientemente ricas sobre qué hizo el agente, qué validó, dónde falló y qué reglas activó.

---

## 5. Principios de diseño propuestos

La propuesta se apoya en nueve principios.

### 5.1 Menos primitivas, más nítidas

Harness excellence no se logra añadiendo agentes ni proliferando comandos arbitrarios. Se logra con pocas primitivas muy bien definidas:

- task environment
- evidence-first analyze
- context policy
- sensors
- eval layer
- observability

### 5.2 Contract-first execution

Antes de ejecutar, el agente debe ver un contrato explícito de tarea. No basta con leer una consigna informal y arrancar.

### 5.3 Research before interrogation

Antes de preguntar al usuario, el sistema debe explotar repo, artefactos, docs, tests y research acotado cuando aplique.

### 5.4 Determinismo primero, juicio después

Los sensores computacionales deben formar la columna vertebral del sistema. Los inferenciales deben complementar, no reemplazar.

### 5.5 Context is a budget

La memoria como código es buena; la memoria como código sin política explícita de uso acaba generando ruido. Inquiry debe pasar de “persistimos artefactos” a “sabemos qué artefactos entran cuándo y por qué”.

### 5.6 Repo as system of record

Toda pieza necesaria para operar el harness debe vivir en el repo o ser derivable desde él. Nada crítico debe depender de conocimiento tácito o interfaces mágicas del host.

### 5.7 Shift feedback left

Todo fallo detectable antes de un gate tardío debe detectarse antes. El harness excelente minimiza iteraciones costosas y tardías.

### 5.8 Evolución respaldada por evidencia

DARWIN debe proponer mutaciones del método, pero crecientemente sobre evidencia estructurada, no solo sobre percepción cualitativa.

### 5.9 Portabilidad explícita

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

La propuesta se organiza en seis workstreams. Los primeros cinco forman el núcleo canónico de `0.6.x`; el sexto extiende la propuesta hacia portabilidad comparativa posterior.

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

**Superficies actuales relacionadas**

- `inquiry-context`
- resolución de `project_root`
- regla single-task-per-cycle
- workspace discovery y layouts complejos

**Criterio de éxito**

Un agente puede recibir una tarea y saber, sin inferencia ambigua adicional, qué puede tocar, qué debe producir y cómo demostrar que terminó.

### 8.2 Workstream B — Evidence-First ANALYZE

**Problema**  
Hay evidencia disponible en repo, artefactos, docs y tests, pero el sistema todavía no expresa con suficiente claridad que ANALYZE debe investigar antes de preguntar al usuario.

**Objetivo**  
Hacer que ANALYZE adquiera evidencia primero y que la interrogación al usuario quede reservada para incertidumbres reales no resueltas por información disponible.

**Entregables propuestos**

1. Política explícita de adquisición de evidencia para ANALYZE
2. Orden claro entre repo, artefactos de ciclo, docs, tests, runtime evidence, web research y preguntas al usuario
3. Reglas de relevancia para preguntas de SOCRATES
4. Fortalecimiento de `diagnosis.md` como artefacto que separa observación, hipótesis y dudas abiertas
5. Source gathering suficientemente amplio para no depender del usuario como primera fuente por defecto

**Superficies actuales relacionadas**

- prompts e instrucciones de ANALYZE
- `diagnosis.md`
- source gathering y research
- artefactos de cleanroom y evidencia ejecutable

**Criterio de éxito**

ANALYZE logra resolver una parte significativa de los ciclos sin interrogación innecesaria, y las preguntas remanentes reducen incertidumbre real en vez de repetir trabajo que el repo ya podía responder.

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

**Superficies actuales relacionadas**

- `diagnosis.md`
- `plan.md`
- `doc-read`
- convenciones actuales de Memory as Code
- módulo futuro `iq memory`

**Criterio de éxito**

El sistema logra más foco y menos ruido sin sacrificar continuidad entre sesiones o fases.

### 8.4 Workstream D — Sensor Architecture and END Discipline

**Problema**  
El sistema tiene checks y gates, pero no una arquitectura explícita de sensores ni una disciplina suficientemente visible de cierre para EXECUTE y END.

**Objetivo**  
Definir una taxonomía formal de sensores y mover feedback útil hacia las partes más tempranas del ciclo, empezando por los puntos donde Inquiry ya tiene obligaciones claras.

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
6. Gate documental o linter inicial para bloquear transiciones con pendientes relevantes aún abiertos

**Superficies actuales relacionadas**

- `pre_pr_inspection`
- `inquiry-end`
- salida de transición y summaries operativas
- release closure visible antes de END
- validaciones documentales y linter de pendientes

**Criterio de éxito**

Todo cambio pasa por un camino de validación legible, ordenado por costo y sin depender de criterio informal del agente o del humano en cada corrida.

### 8.5 Workstream E — Harness Observability and Eval Foundation

**Problema**  
Inquiry ya tiene gates y `metrics.yaml`, pero todavía no ofrece suficiente visibilidad del comportamiento interno del harness ni una base suficientemente clara para comparar mutaciones del método.

**Objetivo**  
Hacer observable el comportamiento operativo de Inquiry como sistema de control y convertir fallos recurrentes en señales reutilizables para evolución del propio harness.

**Entregables propuestos**

1. Especificación `harness-observability.md`
2. Especificación `eval-model.md`
3. Registro estructurado por ciclo de:
   - transiciones
   - skills invocadas
   - sensores corridos
   - fallos detectados
   - retries
   - tiempo por fase
4. Diferenciación entre `metrics.yaml` de resultado y trazas de ejecución
5. Taxonomía inicial de fallos del harness
6. Primer esquema de evals mínimas o graders del propio harness

**Superficies actuales relacionadas**

- `.inquiry/metrics.yaml`
- artefactos de ciclo y retrospectives
- entradas de EVOLUTION
- failure taxonomy
- `run trace` o primitive equivalente futura

**Criterio de éxito**

Las mutaciones del método pueden compararse con evidencia, aunque sea inicialmente modesta, y el maintainer puede responder con datos dónde se bloquea el sistema, qué gates detectan más problemas y qué retrabajo es recurrente.

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

**Superficies actuales relacionadas**

- `architecture.md`
- `roadmap.md`
- documentación de harness engineering y taxonomy
- futuro `host-adapter-contract`

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

### Fase 2 — Evidence-First ANALYZE

**Objetivo**  
Hacer visible el orden operativo de adquisición de evidencia antes de preguntar al usuario.

**Contenido**

1. policy de adquisición de evidencia para ANALYZE
2. reglas de relevancia para preguntas
3. fortalecimiento de `diagnosis.md`
4. ampliación de source gathering cuando el caso lo requiera

**Por qué va segundo**  
Porque antes de optimizar contexto o sensores conviene ordenar cómo se produce el diagnóstico.

### Fase 3 — Context policy mínima viable

**Objetivo**  
Hacer explícita la política de memoria, retrieval y handoff.

**Contenido**

1. `iq memory` spec
2. retrieval policy por fase
3. compaction / summarization guidance
4. fortalecimiento de handoff artifacts

**Por qué va tercero**  
Porque con task contract y ANALYZE mejor fundado, la política de contexto puede optimizarse contra un objetivo operacional concreto.

### Fase 4 — Sensor stack y END discipline

**Objetivo**  
Definir y empezar a aplicar una arquitectura de sensores y cierre explícito.

**Contenido**

1. taxonomía de sensores
2. pre-PR gate formal
3. version/release gate visible
4. checks locales rápidos claramente nombrados
5. gate documental para pendientes detectables

**Por qué va cuarto**  
Porque sin task contract, mejor análisis y handoffs claros, los sensores se apoyan en semántica todavía inestable.

### Fase 5 — Observability + Eval foundation

**Objetivo**  
Hacer visible el comportamiento del harness y convertir fallos en señales reutilizables.

**Contenido**

1. trazas por ciclo
2. extensión del modelo de métricas
3. catálogo de fallos recurrentes
4. primeras suites o graders del propio harness

**Por qué va quinto**  
Porque sin las fases previas, la observabilidad generaría datos antes de que el sistema tenga una semántica suficientemente limpia.

### Fase 6 — Comparative antifragility y host boundary

**Objetivo**  
Comparar hosts y variantes del harness con evidencia acumulada y una frontera más explícita entre host y outer harness.

**Contenido**

1. adapter contract claro
2. harness comparativo multi-target
3. experimentos controlados de metodología vs host
4. evolución respaldada por datos de varias corridas

**Por qué va último**  
Porque sólo vale la pena cuando el núcleo del harness ya está mínimamente bien especificado.

---

## 10. Mapa a superficies actuales del sistema

Esta propuesta no depende del issue tracker; se apoya en superficies reales del sistema que ya existen o que el repo ya insinúa con claridad.

### Superficies clave para Fase 1

- `inquiry-context`
- resolución de `project_root`
- regla single-task-per-cycle
- workspace discovery y layouts complejos

### Superficies clave para Fase 2

- prompts e instrucciones de ANALYZE
- `diagnosis.md`
- source gathering y research
- artefactos de cleanroom y evidencia ejecutable

### Superficies clave para Fase 3

- `diagnosis.md`
- `plan.md`
- `doc-read`
- convenciones de Memory as Code
- módulo futuro `iq memory`

### Superficies clave para Fase 4

- `sensor-taxonomy.md`
- `pre_pr_inspection`
- `inquiry-end`
- salida de transición y summaries
- release closure visible
- validaciones documentales

### Superficies clave para Fase 5

- `.inquiry/metrics.yaml`
- trazas o artefactos por ciclo
- EVOLUTION y retrospectives
- failure taxonomy
- `eval-model`

### Superficies clave para Fase 6

- `architecture.md`
- `roadmap.md`
- documentación de harness engineering
- futuro `host-adapter-contract`

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
Toda nueva spec debe mapear a una surface real del sistema: comando, asset, prompt, artefacto, contrato o protocolo concreto.

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
2. hacer explícito ANALYZE evidence-first y fortalecer `diagnosis.md`
3. diseñar `iq memory` y la context policy por fase
4. publicar una taxonomía de sensores y aplicarla al runtime actual
5. enriquecer observabilidad y métricas del harness con una base mínima de evals
6. recién entonces abrir el frente fuerte de host boundary comparativo y antifragilidad multi-target

Esta secuencia respeta la lógica del sistema: primero se acota la tarea, luego se ordena cómo se adquiere evidencia, después se optimiza el contexto, luego se consolida la validación y finalmente se mide la mejora.

---

## 15. Definición de éxito a 90 días

Una versión creíble de éxito en el corto plazo sería esta:

1. `inquiry-context` ya expone project root, outputs esperados y validaciones mínimas
2. ANALYZE sigue un orden evidence-first explícito y sólo pregunta cuando persiste incertidumbre real
3. hay una policy inicial de contexto por fase y handoffs con autoridad más explícita
4. END tiene un pre-PR inspection gate explícito y sensores mínimos visibles en el cierre
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
