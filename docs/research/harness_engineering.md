# Harness Engineering aplicado a AI

**Tipo de documento:** referencia de investigación aplicada  
**Estado:** borrador de trabajo  
**Fecha:** mayo 2026

---

## 1. Propósito

Este documento sintetiza la investigación realizada sobre **Harness Engineering** aplicado a sistemas de AI agentic, con foco especial en su utilidad para evolucionar **Inquiry CLI**.

La tesis central es simple:

**El rendimiento útil de un agente no depende solo del modelo ni del prompt. Depende del sistema completo de control que rodea al modelo.**

Ese sistema de control es el **harness**.

En términos prácticos, este documento sirve para:

1. Definir con precisión qué significa harness engineering.
2. Diferenciarlo de prompt engineering y context engineering.
3. Extraer patrones comunes observados en implementaciones reales.
4. Traducir esos patrones a decisiones concretas para Inquiry CLI.

---

## 2. Resumen ejecutivo

Harness Engineering es la disciplina de diseñar el conjunto de **guías, herramientas, memoria, entorno, restricciones, sensores de validación y lazos de feedback** que permiten que un modelo haga trabajo valioso con mayor confiabilidad y menor supervisión humana directa.

Una definición operativa útil es:

> **Agente = modelo + harness**

El modelo aporta la inteligencia base. El harness hace esa inteligencia **usable, legible, gobernable y verificable**.

En la práctica, el harness incluye al menos estas familias de componentes:

- instrucciones y guías
- contexto y memoria
- herramientas y entorno de ejecución
- orquestación y handoffs
- sensores de feedback y validación
- guardrails y políticas de escalación
- mecanismos de mejora continua

La investigación muestra además que el término **Harness Engineering** es reciente y emergente, pero ya existe convergencia sustantiva entre varios equipos fuertes de la industria:

- OpenAI
- Anthropic
- Stripe
- LangChain
- Thoughtworks / Martin Fowler

La conclusión más relevante para Inquiry es esta:

**Inquiry CLI ya contiene varias piezas de un harness serio, pero todavía puede evolucionar desde “metodología con CLI” hacia “harness explícito para agentes de software”.**

---

## 3. Qué es Harness Engineering

### 3.1 Definición general

Harness Engineering es la ingeniería del sistema que envuelve a un modelo para convertirlo en un agente útil.

Ese sistema envuelve y regula:

- qué ve el agente
- qué puede hacer
- con qué herramientas opera
- cómo persiste estado
- cómo valida su trabajo
- cómo se autocorrige
- cuándo debe parar o escalar a humano

No es una técnica puntual. Es una **disciplina de diseño del entorno operativo del agente**.

### 3.2 Definición acotada para agentes de software

En el contexto de coding agents, harness engineering es el diseño del conjunto de controles que aumentan dos probabilidades:

1. la probabilidad de que el agente produzca una buena solución en el primer intento
2. la probabilidad de que detecte y corrija sus propios errores antes de llegar a ojos humanos

Esta formulación es especialmente útil porque desplaza la conversación desde “qué prompt usamos” hacia “qué sistema de control compensa las debilidades conocidas del agente”.

### 3.3 El insight decisivo

Los LLMs no fallan solo por falta de capacidad. También fallan porque operan en entornos subespecificados.

Cuando el agente no tiene:

- contexto correcto
- herramientas adecuadas
- evidencia ejecutable
- memoria duradera
- feedback rápido
- restricciones estructurales

la respuesta natural del sistema no es confiabilidad, sino plausibilidad.

Harness Engineering existe precisamente para cerrar esa brecha entre **plausibilidad** y **trabajo confiable**.

---

## 4. Qué NO es

### 4.1 No es solo prompt engineering

Prompt engineering optimiza la redacción y estructura de instrucciones.

Harness engineering incluye prompts, pero va mucho más allá:

- define herramientas
- diseña el espacio de acción
- regula el contexto
- provee validación
- establece lazos de corrección
- decide artefactos y memoria

### 4.2 No es sinónimo exacto de context engineering

Context engineering trata la pregunta:

> ¿Qué tokens conviene poner dentro del contexto del modelo en cada paso?

Harness engineering trata una pregunta más amplia:

> ¿Qué sistema completo hace que el modelo pueda trabajar bien en el mundo?

Por tanto:

- **context engineering es una parte del harness**
- **harness engineering no se reduce al contexto**

### 4.3 No es solo evaluación

Las evals son una pieza del harness, pero no el harness entero.

Un sistema puede tener buenas evals y aun así carecer de:

- memoria útil
- herramientas bien diseñadas
- handoffs robustos
- observabilidad
- control de deriva arquitectónica

### 4.4 No es autonomía ciega

Un harness bien diseñado no intenta “soltar al agente” sin límites. Hace lo contrario: **acota, instrumenta y regula**.

El objetivo no es libertad máxima. El objetivo es **autonomía gobernable**.

---

## 5. Modelo conceptual: feedforward y feedback

La formulación más clara encontrada en la investigación proviene del marco de Birgitta Böckeler / Martin Fowler.

### 5.1 Feedforward

Son controles que intentan prevenir errores antes de que ocurran.

Ejemplos:

- system prompt
- skills y how-to guides
- reglas arquitectónicas
- documentación indexada
- plantillas de planes
- convenciones de paths y artefactos
- contratos explícitos de herramientas

### 5.2 Feedback

Son sensores que observan el resultado después de actuar y devuelven señales para corregir.

Ejemplos:

- tests
- lint
- typecheck
- structural tests
- logs
- métricas
- trazas
- browser automation
- review agents
- evaluator agents

### 5.3 Por qué se necesitan ambos

Sin feedforward, el agente repite errores evitables.

Sin feedback, el agente sigue reglas pero no sabe si realmente funcionaron.

Un harness serio necesita ambos porque un agente útil debe ser capaz de:

1. empezar en una dirección sensata
2. detectar desvíos
3. iterar hasta converger o escalar

---

## 6. Controles computacionales e inferenciales

Otra distinción importante es entre controles **computacionales** e **inferenciales**.

### 6.1 Controles computacionales

Son deterministas, rápidos y baratos.

Ejemplos:

- test suites
- typecheckers
- linters
- dep-cruisers
- arch tests
- coverage
- mutation testing
- validadores de esquema

Ventajas:

- alta repetibilidad
- costo bajo
- buenos para ejecución frecuente
- ideales para mover feedback a la izquierda

### 6.2 Controles inferenciales

Son semánticos, más costosos y no deterministas.

Ejemplos:

- AI code review
- LLM-as-judge
- evaluadores de UX
- auditoría semántica de documentos
- síntesis crítica de hallazgos

Ventajas:

- capturan problemas que tests y linters no ven
- permiten juicio cualitativo
- ayudan en dominios donde la calidad no es completamente binaria

Limitaciones:

- sesgo de indulgencia
- variación entre corridas
- costo y latencia mayores

### 6.3 Regla práctica

Un harness maduro usa controles computacionales como columna vertebral y controles inferenciales como capa adicional de juicio.

No conviene invertir esta jerarquía.

---

## 7. Componentes estructurales de un harness moderno

La investigación muestra un conjunto bastante estable de primitives.

### 7.1 Instrucciones y guías

Incluye:

- system prompt
- skills
- AGENTS.md o equivalente
- docs operativas
- how-to guides
- ejemplos canónicos
- principios de diseño

No deben funcionar como enciclopedia monolítica. Los mejores resultados aparecen cuando las guías son:

- claras
- cortas en el punto de entrada
- enlazadas a fuentes de verdad más profundas
- mantenidas como artefactos versionados

### 7.2 Contexto y memoria

Incluye:

- contexto inicial mínimo pero de alta señal
- recuperación just-in-time
- notas persistentes
- planes y checklists
- compaction
- handoffs entre sesiones o agentes

La regla clave es:

> el contexto es un recurso finito y debe tratarse como presupuesto de atención

### 7.3 Herramientas y Agent-Computer Interface

Las herramientas no son solo “capabilities”; son la interfaz cognitiva del agente con el mundo.

Un buen ACI debe:

- usar formatos fáciles para el modelo
- evitar ambigüedad entre herramientas similares
- nombrar claramente parámetros y límites
- reducir errores por diseño
- documentar edge cases

En términos prácticos, la calidad de las herramientas puede importar más que la calidad del prompt.

### 7.4 Entorno de ejecución

Incluye:

- filesystem
- git
- terminal
- navegador
- runtimes
- sandboxes
- servicios efímeros
- observabilidad local

Un agente solo puede razonar sobre lo que puede ver y ejecutar. Sin entorno operativo, no hay agentic software engineering serio.

### 7.5 Orquestación

Incluye:

- loops de ejecución
- planner / generator / evaluator
- subagentes
- paralelización
- routing
- resets de contexto
- contratos de sprint o handoff
- stopping conditions

La tendencia común no es construir orquestación maximalista, sino **la mínima complejidad que produce mejora verificable**.

### 7.6 Sensores y validación

Un harness maduro expone ground truth al agente.

Los sensores típicos incluyen:

- tests de comportamiento
- validación estructural
- inspección de UI automatizada
- logs consultables
- métricas y SLOs
- traces
- fallos de CI
- review humano o AI

### 7.7 Mejora continua

Los mejores harnesses no solo ejecutan tareas. También convierten fallos en mejoras del propio sistema.

Eso requiere:

- capturar evidencia de fallos
- agrupar patrones
- convertir patrones en evals
- acotar tareas accionables
- validar fixes
- reincorporar aprendizajes a docs, reglas o tooling

---

## 8. Patrones emergentes observados en la industria

### 8.1 Repository as system of record

Patrón visible con fuerza en OpenAI y, conceptualmente, también muy cercano a Inquiry.

La idea es:

**lo que el agente no puede encontrar en el repo, no existe operativamente para el agente**.

Consecuencias:

- decisiones deben vivir en markdown versionado
- arquitectura debe ser discoverable
- planes y deuda deben quedar persistidos
- las fuentes de verdad deben estar indexadas

### 8.2 Progressive disclosure

No inundar al agente con todo al inicio. Darle un mapa y primitives de exploración.

Esto aparece en:

- AGENTS.md corto
- skills invocables bajo demanda
- glob / grep / search tools
- memory files
- subagentes especializados

### 8.3 Planner + Generator + Evaluator

Anthropic mostró con claridad que separar roles reduce dos fallos frecuentes:

- sub-scoping o implementación miope
- indulgencia del modelo al evaluar su propio trabajo

La separación de roles no tiene que ser obligatoria siempre, pero es una primitive importante cuando el task está cerca o más allá del borde de capacidad del modelo.

### 8.4 Shift feedback left

Stripe enfatiza una regla clásica de ingeniería que se vuelve todavía más importante con agentes:

**si un fallo puede detectarse localmente, no debe esperar a CI**.

Esto vale para humanos y agentes, pero con agentes el impacto es mayor porque:

- el throughput es superior
- el costo de iteración tardía escala rápido
- los loops largos consumen tokens y tiempo sin necesidad

### 8.5 Legibilidad para el agente

Los equipos más avanzados tienden a diseñar el codebase para que sea:

- navegable
- estructuralmente consistente
- fuertemente tipado cuando conviene
- con límites explícitos
- con invariantes mecánicamente verificables

Esto es una forma de diseñar para **harnessability**.

### 8.6 Production traces as improvement fuel

El caso de Tax AI muestra un patrón decisivo:

1. el experto humano corrige
2. esa corrección se preserva como evidencia estructurada
3. la evidencia se transforma en eval
4. el eval se vuelve tarea acotada para el agente
5. el fix se valida contra targeted + regression evals

Esto convierte la operación real en motor de mejora del harness.

### 8.7 Simplify when models improve

Anthropic enfatiza otra lección crítica: el harness no debe volverse dogma.

Cada pieza del harness codifica una hipótesis del tipo:

> el modelo no puede hacer bien esto por sí solo

Cuando el modelo mejora, esas hipótesis deben re-auditarse. Si una pieza dejó de ser load-bearing, debe simplificarse o eliminarse.

---

## 9. Riesgos, límites y anti-patrones

### 9.1 Over-harnessing

Un harness demasiado complejo puede:

- elevar latencia
- aumentar costo
- ocultar la causa real de los fallos
- volverse más difícil de mantener que el sistema que gobierna

La complejidad solo se justifica cuando mejora outcomes medibles.

### 9.2 Monolito de instrucciones

Un único archivo enorme con todas las reglas suele degradar performance por:

- ruido contextual
- instrucciones stale
- imposibilidad de verificación mecánica
- falta de priorización

### 9.3 Tooling ambiguo

Si dos herramientas parecen hacer casi lo mismo, el agente se equivoca más. La ambigüedad en el ACI es un bug de harness.

### 9.4 Evaluadores indulgentes

Un mismo modelo tiende a ser poco crítico con su propia salida. Si hay evaluator loops, deben calibrarse explícitamente y, cuando sea posible, separarse del generador.

### 9.5 Test suites falsas como ground truth

Especialmente en coding, un gran riesgo es confiar demasiado en tests generados por el mismo agente sin garantías adicionales sobre su calidad.

### 9.6 Falta de trazabilidad de fallos

Si los errores reales no se conservan como evidencia estructurada, el sistema no puede convertirse en self-improving harness. Solo repite correcciones ad hoc.

### 9.7 Confundir autonomía con eliminación del humano

El rol del humano no desaparece. Cambia de capa:

- define calidad
- revisa trade-offs no formalizados
- arbitra ambigüedades
- decide dónde vale la pena automatizar

---

## 10. Relación entre Harness Engineering e Inquiry

### 10.1 Lectura fuerte

Inquiry puede entenderse como una propuesta de harness engineering metodológico.

Su aporte distintivo no es “otro prompt para coding agents”, sino una combinación de:

- proceso explícito
- FSM
- división por fases cognitivas
- artefactos persistentes
- memoria como código
- transición formal entre estados
- CLI como ensamblador de contexto y restricciones

Dicho en términos del nuevo vocabulario:

**Inquiry ya diseña un harness; solo que hoy lo formula principalmente como metodología y runtime de proceso.**

### 10.2 Correspondencias directas

| Harness Engineering | Inquiry actual |
|---|---|
| Guías y feedforward | prompts de APE, skills, contratos de fase |
| Memoria persistente | cleanrooms, .inquiry, markdown versionado |
| Orquestación | FSM Analyze → Plan → Execute → End → Evolution |
| Progressive disclosure | skill delivery y contexto resuelto por CLI |
| Handoffs | diagnosis.md, plan.md, artifacts por fase |
| Human steering | issue selection, PR review, evolución metodológica |

### 10.3 La diferencia clave

Inquiry ha enfatizado más el **método epistemológico** que el **plano operativo completo de observación y validación**.

Eso no es un defecto. Es una elección fundacional. Pero si el objetivo es aumentar la capacidad real de Inquiry CLI como infraestructura agentic, el siguiente paso natural es fortalecer explícitamente las piezas de harness que hoy están menos desarrolladas:

- sensores
- observabilidad
- evaluadores
- loops de autocorrección
- templates de harness por topología
- trazas y evals como sustrato de evolución

---

## 11. Implicaciones concretas para Inquiry CLI

Esta sección traduce la investigación a trabajo práctico.

### 11.1 Inquiry CLI debería asumirse explícitamente como harness builder

Hoy Inquiry se presenta como metodología + CLI.

Una formulación más potente sería:

> Inquiry CLI es el runtime que instala y gobierna el harness operativo de un agente de software.

Esto aclara mejor su valor frente a herramientas centradas solo en prompts, skills aisladas o automation scripts.

### 11.2 La unidad principal no debe ser solo el prompt, sino el task environment

La investigación apunta a que el agente rinde mejor cuando recibe un entorno de tarea bien acotado:

- paths claros
- artefactos de entrada definidos
- outputs esperados
- comandos de validación
- límites de edición
- criterios de done

Inquiry ya apunta en esa dirección con `inquiry-context`, pero podría reforzarlo hasta volverlo un **contrato de entorno de tarea** más explícito.

### 11.3 Los artefactos de fase son una gran ventaja competitiva

El patrón de:

- `confirmed.md`
- `diagnosis.md`
- `plan.md`

es una implementación fuerte de durable state y handoff artifact.

Inquiry debería profundizar esto, no reducirlo.

La oportunidad está en volver esos artefactos no solo legibles para humanos, sino también más útiles como substrates de:

- recuperación selectiva
- evaluación automática
- compaction controlada
- transición segura entre agentes y sesiones

### 11.4 Falta explicitar una capa de sensores

Hoy Inquiry define bien el pensamiento disciplinado. Menos claro está el catálogo de sensores que el runtime debe exponer o recomendar.

Una evolución natural sería modelar formalmente una taxonomía de sensores:

- sensores locales rápidos
- sensores de CI
- sensores continuos de deriva
- sensores de runtime
- sensores inferenciales opcionales

Esto permitiría integrar la idea de “keep quality left” dentro del propio contrato metodológico.

### 11.5 Las skills de Inquiry pueden entenderse como guías del harness

Esto ayuda a distinguir mejor dos familias:

- **skills feedforward**: explican cómo actuar
- **skills feedback**: explican cómo auditar, criticar o revisar

Esa distinción podría volverse explícita en el diseño de skills, su metadata y su momento de invocación.

### 11.6 Inquiry necesita una postura más explícita sobre context engineering

La investigación contemporánea muestra que el contexto debe gestionarse activamente mediante:

- progressive disclosure
- just-in-time retrieval
- compaction
- note-taking
- subagentes
- resets cuando aplique

Inquiry ya tiene piezas cercanas, pero podría beneficiar de una capa más formal de política contextual por fase.

### 11.7 La evolución metodológica debería alimentarse de evidencia estructurada

DARWIN hoy propone mutaciones metodológicas. El siguiente salto sería que esas mutaciones no dependan solo de reflexión cualitativa, sino también de evidencia estructurada como:

- fallos recurrentes del agente
- tipos de desviación por fase
- skills más invocadas
- puntos de bloqueo repetidos
- paths o herramientas que generan más fricción
- defectos detectados por sensores

Eso convertiría EVOLUTION en una forma de harness tuning respaldada por trazas.

---

## 12. Recomendaciones de diseño para Inquiry CLI

### 12.1 Corto plazo

1. **Nombrar el problema correctamente.** Incorporar explícitamente el lenguaje de harness engineering en la arquitectura y posicionamiento interno del proyecto.
2. **Formalizar el task environment.** Hacer que cada tarea tenga inputs, outputs, comandos de validación y límites de edición explícitos.
3. **Clasificar skills por función de harness.** Distinguir entre skills de guía, skills de lectura, skills de auditoría y skills de ejecución.
4. **Definir taxonomía de sensores.** Documentar qué controles deben correrse localmente, en CI y de forma continua.
5. **Fortalecer contract-first execution.** Cada fase debería dejar no solo documentos, sino también criterios verificables para la siguiente.

### 12.2 Medio plazo

1. **Context policy por fase.** Diseñar reglas explícitas de cuánto contexto entra, qué se recupera bajo demanda y qué debe persistirse fuera del contexto.
2. **Compaction consciente de artefactos.** Usar los documentos de Inquiry como soporte para resets o resumidos de alta fidelidad.
3. **Feedback loops más estructurados en EXECUTE.** Convertir validaciones y fallos en entradas normalizadas para iteración del agente.
4. **Harness templates por topología.** Definir perfiles reutilizables según tipo de proyecto: CLI, web app, library, migration, docs-heavy, etc.
5. **Metadata de harnessability.** Señalar características del repo que facilitan o dificultan el trabajo del agente.

### 12.3 Largo plazo

1. **Eval-backed evolution.** Hacer que cambios metodológicos en Inquiry se justifiquen con datos, no solo con doctrina.
2. **Research loop sobre fallos reales.** Convertir errores recurrentes en corpus analizable y en propuestas de mutación del harness.
3. **Observabilidad del agente.** Exponer trazas, decisiones, validaciones y puntos de fallo como artefactos legibles.
4. **Outer harness explícito.** Hacer visible la diferencia entre el harness provisto por el target agent y el harness adicional provisto por Inquiry.

---

## 13. Propuesta de tesis para Inquiry

Una formulación estratégica posible sería:

> Inquiry no compite por tener el mejor prompt ni el agente más “inteligente”. Inquiry diseña el harness epistemológico y operativo que hace confiable a un agente dentro del trabajo de software.

Esa tesis conecta bien con convicciones ya presentes en el proyecto:

- el valor está en el proceso, no en el modelo
- la memoria debe vivir como código
- los agentes necesitan constraints explícitas
- la confiabilidad viene de thinking tools y artefactos, no de improvisación

Harness Engineering ofrece un vocabulario contemporáneo y técnicamente creíble para expresar esa intuición en términos de ingeniería aplicada.

---

## 14. Preguntas abiertas útiles para investigación futura

1. ¿Cómo medir la calidad de un harness de manera análoga a cobertura de tests?
2. ¿Qué piezas del harness de Inquiry son realmente load-bearing y cuáles son solo herencia doctrinal?
3. ¿Qué sensores son más valiosos por fase del FSM?
4. ¿Cómo representar fallos metodológicos para que DARWIN pueda razonar sobre ellos?
5. ¿Cuándo conviene invocar evaluator agents y cuándo basta con controles computacionales?
6. ¿Qué topologías de proyecto justifican harness templates propios?
7. ¿Cómo hacer que `iq` construya task environments acotados sin volverse invasivo ni pesado?
8. ¿Cómo distinguir de forma verificable entre mejora del modelo y mejora del harness?

---

## 15. Conclusión

La investigación converge en una idea fuerte:

**la frontera práctica de los agentes no está solo en el modelo; está en el diseño del entorno que regula al modelo.**

Harness Engineering es el nombre emergente para esa disciplina.

Para Inquiry CLI, esto no exige abandonar su identidad. Al contrario: permite reinterpretar con mayor precisión lo que Inquiry ya venía afirmando.

Inquiry no es simplemente una metodología con archivos markdown ni un empaquetador de prompts. Es un intento serio de imponer estructura epistemológica y operativa sobre agentes de software.

El siguiente paso natural es volver esa intuición más explícita, más instrumentada y más verificable.

En otras palabras:

**Inquiry ya tiene forma de harness. Ahora le conviene asumirse, diseñarse y evolucionar como tal.**

---

## 16. Fuentes principales

Las ideas de este documento fueron sintetizadas a partir de las siguientes fuentes públicas revisadas durante la investigación:

1. OpenAI, *Harness engineering: leveraging Codex in an agent-first world*.
2. OpenAI, *Building self-improving tax agents with Codex*.
3. Anthropic, *Harness design for long-running application development*.
4. Anthropic, *Building effective agents*.
5. Anthropic, *Effective context engineering for AI agents*.
6. Birgitta Böckeler / Martin Fowler, *Harness engineering for coding agent users*.
7. LangChain, *The Anatomy of an Agent Harness*.
8. Stripe, *Minions: Stripe's one-shot, end-to-end coding agents*.

Estas fuentes coinciden en un punto central: la ingeniería de agentes está migrando desde la optimización de prompts hacia el diseño integral de entornos, controles y lazos de validación.