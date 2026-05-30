# Taxonomía formal de Prompt Engineering, Context Engineering, Harness Engineering y Eval Engineering

**Tipo de documento:** referencia de investigación aplicada  
**Estado:** borrador de trabajo  
**Fecha:** mayo 2026

---

## 1. Propósito

Este documento formaliza una taxonomía para cuatro disciplinas que hoy suelen mezclarse en la conversación sobre agentes AI:

1. **Prompt Engineering**
2. **Context Engineering**
3. **Harness Engineering**
4. **Eval Engineering**

El problema que intenta resolver es terminológico y arquitectónico a la vez. En muchas discusiones, estas cuatro capas aparecen como si fueran sinónimos o variantes menores de una misma práctica. No lo son. Operan sobre objetos distintos, optimizan preguntas distintas y dejan artefactos distintos.

El objetivo secundario del documento es aplicar esta taxonomía a **Inquiry** para responder dos preguntas:

1. ¿Dónde cae Inquiry dentro de esta taxonomía?
2. ¿En qué sentido este repositorio ya es un harness?

---

## 2. Tesis central

Las cuatro disciplinas pueden entenderse como niveles distintos de intervención sobre un sistema agentic.

- **Prompt Engineering** diseña instrucciones.
- **Context Engineering** diseña el contenido accesible al modelo en el momento de inferencia.
- **Eval Engineering** diseña la medición y los criterios de éxito o fallo.
- **Harness Engineering** diseña el sistema operativo completo que integra instrucciones, contexto, herramientas, validación, memoria, restricciones y lazos de control.

La relación correcta entre ellas no es de rivalidad sino de anidación parcial:

- Prompt Engineering es una parte del problema.
- Context Engineering amplía el problema desde el prompt hacia el estado de inferencia.
- Eval Engineering regula cómo se mide el comportamiento deseado.
- Harness Engineering integra esas capas dentro de un sistema ejecutable y gobernable.

Por tanto, la afirmación más útil es esta:

> **Todo harness serio contiene decisiones de prompt, contexto y evaluación, pero ninguna de esas capas por sí sola constituye un harness.**

---

## 3. Definiciones formales

### 3.1 Prompt Engineering

**Definición:** disciplina que diseña la forma, estructura, contenido y estilo de las instrucciones dadas al modelo para inducir un comportamiento deseado.

**Objeto de diseño:** el prompt o conjunto de prompts.

**Pregunta central:**

> ¿Cómo debo formular las instrucciones para aumentar la probabilidad de que el modelo responda de la manera deseada?

**Unidad mínima típica:**

- system prompt
- template de prompt
- secciones de instrucción
- ejemplos few-shot
- formato de salida pedido

**Superficie de control principal:** lenguaje natural y estructura textual.

**Horizonte temporal:** una inferencia o una familia homogénea de inferencias.

**Artefactos típicos:**

- prompts versionados
- bibliotecas de prompts
- few-shot sets
- plantillas por tarea

**Éxito típico:** mejor adherencia de salida a instrucciones explícitas.

**Fallo típico:**

- prompts demasiado vagos
- prompts demasiado rígidos
- sobreajuste a ejemplos
- instrucciones contradictorias
- formato difícil para el modelo

### 3.2 Context Engineering

**Definición:** disciplina que diseña qué información entra, permanece, sale o se recupera del contexto del modelo en cada paso de inferencia.

**Objeto de diseño:** el estado de contexto disponible en runtime.

**Pregunta central:**

> ¿Qué conjunto mínimo de tokens de alta señal debe estar disponible para maximizar la probabilidad del comportamiento deseado?

**Unidad mínima típica:**

- system prompt cargado
- historial de mensajes
- documentos recuperados
- archivos recientes
- memoria persistida reinyectada
- tool outputs resumidos u offloaded

**Superficie de control principal:** curación, compaction, retrieval y persistencia.

**Horizonte temporal:** secuencias de inferencia, sesiones largas y trabajo multi-turn.

**Artefactos típicos:**

- memory files
- resúmenes de compaction
- índices y maps del repo
- retrieval policies
- handoff artifacts

**Éxito típico:** mantener coherencia y foco sin saturar el presupuesto de atención.

**Fallo típico:**

- context bloat
- contexto stale
- pérdida de información crítica en compaction
- recuperación tardía o irrelevante
- mezcla de señales de distinta prioridad

### 3.3 Eval Engineering

**Definición:** disciplina que diseña cómo medir el comportamiento del sistema, cómo transformar fallos en señales útiles y cómo establecer criterios de aceptación o rechazo.

**Objeto de diseño:** el sistema de evaluación.

**Pregunta central:**

> ¿Cómo sabremos, de forma repetible y útil, si el sistema está funcionando mejor o peor?

**Unidad mínima típica:**

- benchmark
- caso de prueba
- grader
- métrica
- threshold
- suite de regresión

**Superficie de control principal:** datasets, criterios, graders, scoring, comparaciones de baseline.

**Horizonte temporal:** iteración de sistema, regresión, mejora continua y validación de cambios.

**Artefactos típicos:**

- eval suites
- datasets etiquetados
- graders
- scorecards
- dashboards de accuracy, precision, recall o task success

**Éxito típico:** producir señales fiables para distinguir mejora real de ilusión anecdótica.

**Fallo típico:**

- métricas mal elegidas
- graders indulgentes
- evals fáciles de “hackear”
- desalineación entre benchmark y valor real
- cobertura pobre de fallos importantes

### 3.4 Harness Engineering

**Definición:** disciplina que diseña el sistema completo que rodea al modelo para convertirlo en un agente útil, legible, gobernable y verificable.

**Objeto de diseño:** el entorno operativo integral del agente.

**Pregunta central:**

> ¿Qué sistema de guías, contexto, memoria, herramientas, restricciones, sensores, validaciones y lazos de control hace posible que el modelo realice trabajo valioso de forma confiable?

**Unidad mínima típica:**

- entorno de tarea
- conjunto de herramientas
- memory substrate
- política de contexto
- guardrails
- loop de ejecución
- handoff protocol
- feedback sensors
- reglas de escalación

**Superficie de control principal:** arquitectura operativa del agente.

**Horizonte temporal:** ejecución completa de tareas, ciclos largos, operación repetida y evolución del sistema.

**Artefactos típicos:**

- runtime de agente
- skills y herramientas
- FSMs y contratos de transición
- docs operativas e índices
- task environments
- pipelines de validación
- observabilidad local y continua

**Éxito típico:** aumentar confiabilidad, autonomía útil, auditabilidad y capacidad de autocorrección.

**Fallo típico:**

- entorno subespecificado
- herramientas ambiguas
- falta de sensores
- loops de feedback lentos
- deriva arquitectónica
- sobrecomplejidad del sistema de control

---

## 4. Cuadro comparativo formal

| Disciplina | Objeto de diseño | Pregunta central | Artefacto principal | Horizonte típico | Señal de éxito |
|---|---|---|---|---|---|
| Prompt Engineering | Instrucciones | ¿Cómo digo esto? | Prompt | Una llamada o clase de llamadas | Mejor obediencia al mandato |
| Context Engineering | Estado de inferencia | ¿Qué debe ver el modelo ahora? | Contexto curado | Multi-turn / tareas largas | Más coherencia con menos ruido |
| Eval Engineering | Medición | ¿Cómo sé si mejoró o empeoró? | Eval suite / grader | Iteración de sistema | Señales comparables y útiles |
| Harness Engineering | Entorno operativo total | ¿Qué sistema hace útil al modelo? | Harness / runtime | Ejecución end-to-end | Trabajo confiable con menor supervisión |

---

## 5. Relaciones de inclusión y dependencia

### 5.1 Prompt Engineering es necesario pero insuficiente

Un sistema sin buenos prompts falla pronto. Pero un sistema con prompts excelentes puede seguir fallando por:

- mal contexto
- malas herramientas
- nula observabilidad
- inexistencia de feedback ejecutable
- falta de memoria útil

Por eso Prompt Engineering es necesario, pero no suficiente.

### 5.2 Context Engineering amplía el foco desde la instrucción hacia el estado

Context Engineering aparece cuando el problema ya no es “qué instrucciones dar” sino “qué universo de información debe acompañar la instrucción en cada paso”.

Es una ampliación clara respecto a Prompt Engineering, pero todavía no diseña por sí sola el sistema externo de acción y validación.

### 5.3 Eval Engineering es ortogonal pero indispensable

Eval Engineering no es una subparte trivial del prompt ni del contexto. Es una disciplina transversal que responde al problema de medición.

Puede existir:

- para prompts
- para retrieval
- para herramientas
- para agentes completos
- para producción real

Sin evals, el sistema no distingue mejora real de impresión subjetiva.

### 5.4 Harness Engineering integra las otras capas

Harness Engineering contiene decisiones sobre:

- prompts
- contexto
- herramientas
- validación
- memoria
- ejecución
- observabilidad
- escalación

Por tanto, su nivel de integración es superior. No porque sea “más importante” por definición, sino porque es la capa donde todas las demás deben convivir sin contradecirse.

---

## 6. Taxonomía por eje de control

Otra forma de ver la diferencia es por el eje sobre el que cada disciplina actúa.

### 6.1 Eje lingüístico

Aquí domina Prompt Engineering.

Se decide:

- tono
- estructura
- ejemplos
- mandatos
- formato de salida

### 6.2 Eje atencional

Aquí domina Context Engineering.

Se decide:

- qué entra al contexto
- qué se resume
- qué se recupera más tarde
- qué se deja fuera

### 6.3 Eje epistemométrico

Aquí domina Eval Engineering.

Se decide:

- qué cuenta como evidencia de calidad
- cómo se califica
- cómo se compara contra baseline
- qué regresiones importan

### 6.4 Eje operativo y cibernético

Aquí domina Harness Engineering.

Se decide:

- cómo actúa el agente
- con qué herramientas
- bajo qué restricciones
- con qué sensores
- cómo corrige errores
- cuándo escala a humano
- cómo persiste y reutiliza conocimiento

---

## 7. Taxonomía por tipo de artefacto

| Disciplina | Artefactos dominantes |
|---|---|
| Prompt Engineering | prompts, templates, examples, output schemas |
| Context Engineering | memory files, compactions, retrieval policies, handoff docs |
| Eval Engineering | datasets, graders, scorecards, regression suites |
| Harness Engineering | runtimes, tools, skills, FSMs, task environments, sensor pipelines |

Esta tabla es importante porque evita un error común: llamar “harness” a cualquier colección de prompts o llamar “eval system” a cualquier conjunto de tests.

---

## 8. Taxonomía por momento de intervención

### 8.1 Antes de inferir

Predominan:

- Prompt Engineering
- parte de Context Engineering
- parte de Harness Engineering

### 8.2 Durante la inferencia y ejecución

Predominan:

- Context Engineering
- Harness Engineering

### 8.3 Después de actuar

Predominan:

- Eval Engineering
- parte de Harness Engineering

### 8.4 En la evolución del sistema

Predominan:

- Eval Engineering
- Harness Engineering

La razón es que el harness no es solo lo que ocurre “antes”; también gobierna la respuesta del sistema al error y su evolución futura.

---

## 9. Anti-patrones taxonómicos

### 9.1 Llamar “prompt engineering” a todo

Esto subestima el peso de:

- herramientas
- memoria
- contexto dinámico
- feedback loops
- diseño del entorno

### 9.2 Llamar “context engineering” a cualquier retrieval

El retrieval es solo una técnica dentro del problema más general de gestionar el estado de atención del modelo.

### 9.3 Confundir tests con eval engineering completo

Una suite de tests locales es útil, pero eval engineering incluye también:

- selección de métricas
- datasets curados
- graders
- thresholds
- comparación interversión
- análisis de cobertura del fallo

### 9.4 Llamar “harness” a una carpeta de prompts

Un harness real requiere al menos algún diseño explícito de:

- acción
- contexto
- validación
- memoria o estado
- control del flujo

---

## 10. Aplicación de la taxonomía a Inquiry

Inquiry no cae en una sola casilla. Eso es precisamente lo interesante.

### 10.1 Inquiry tiene Prompt Engineering

Inquiry contiene trabajo real de Prompt Engineering en:

- identidades de los APEs
- prompts de skills
- estructura de `inquiry.agent.md`
- mandato filosófico por fase

En este nivel, Inquiry diseña cómo deben formularse las instrucciones para que el agente adopte una conducta disciplinada.

### 10.2 Inquiry tiene Context Engineering

Inquiry también contiene trabajo real de Context Engineering en:

- `iq ape prompt` como ensamblador explícito del prompt efectivo
- `inquiry-context` con paths resueltos
- `cleanrooms/` como memoria duradera del ciclo
- `.inquiry/` como estado persistido y consultable
- `doc-read` como retrieval protocol estructurado
- artefactos de handoff como `diagnosis.md` y `plan.md`

En este nivel, Inquiry ya opera sobre el problema de qué información entra al contexto del agente y cuándo.

### 10.3 Inquiry tiene Eval Engineering, pero parcial

Inquiry toca Eval Engineering en varios puntos:

- PR gate en END
- obligación de pruebas y validación en EXECUTE
- artefactos verificables por fase
- lógica de cierre disciplinado

Pero todavía no parece tener una capa plenamente formalizada de eval engineering comparable a:

- suites de métricas por task type
- graders explícitos para outputs no binarios
- scorecards de rendimiento del sistema metodológico
- datasets de fallos recurrentes convertidos en evals

Por eso la afirmación más precisa no es “Inquiry no tiene eval engineering”, sino:

> **Inquiry sí tiene intuiciones y prácticas evaluativas, pero todavía no ha cristalizado una disciplina de eval engineering de primer orden.**

### 10.4 Inquiry es, sobre todo, Harness Engineering

Inquiry destaca principalmente como trabajo de Harness Engineering porque diseña un sistema integral de control alrededor del agente.

Ese sistema incluye:

- orquestación por FSM
- estado persistente
- protocolos de transición
- skills como guías operativas
- artefactos de handoff
- separación por fases cognitivas
- CLI que despliega y hace cumplir el entorno
- gate humano para transición y cierre

En otras palabras:

**Inquiry no es solo una biblioteca de prompts ni solo una filosofía. Es un runtime de trabajo agentic con memoria, restricciones, protocolos y control de flujo.**

---

## 11. En qué sentido el repositorio ya es un harness

Esta es la pregunta central.

La respuesta corta es:

**tu repositorio ya es un harness porque ya externaliza y gobierna parte sustantiva de la cognición operativa del agente.**

La respuesta larga requiere descomposición.

### 11.1 El repo ya actúa como sistema de record operativo

Un rasgo central de los harnesses maduros es que la información útil para el agente vive en el repositorio, no en conocimiento tácito, chats perdidos o documentos externos inaccesibles.

Inquiry cumple esto de forma fuerte mediante:

- `docs/`
- `docs/spec/`
- `cleanrooms/`
- `.inquiry/`
- skills y agentes versionados

Eso significa que el repo ya funciona como **memoria legible por humano y por agente**.

### 11.2 El repo ya impone feedforward

El agente no arranca en vacío. Arranca con:

- mandato por fase
- metodología explícita
- skills protocolizadas
- límites de transición
- artefactos esperados
- rutas resueltas por CLI

Eso es feedforward claro. El sistema ya intenta prevenir errores antes de que ocurran.

### 11.3 El repo ya organiza handoffs de alta fidelidad

Los artifacts como:

- `confirmed.md`
- `diagnosis.md`
- `plan.md`
- `mutations.md`

funcionan como handoff artifacts entre fases, sesiones y potencialmente agentes. Esto es una primitive central de harness engineering.

### 11.4 El repo ya contiene una política de control de flujo

La FSM no es decoración doctrinal. Es una restricción operativa real.

El sistema ya define:

- estados válidos
- eventos válidos
- transiciones permitidas o ilegales
- prechecks
- efectos
- artefactos esperados

Eso convierte al repo en algo más que documentación. Lo convierte en parte del sistema de control del agente.

### 11.5 El repo ya define el entorno cognitivo del agente

`inquiry.agent.md`, las skills y los assets del FSM no son simples textos de ayuda. Son componentes del entorno operativo que configuran:

- qué rol asume el agente
- qué fase está activa
- qué procedimientos debe seguir
- qué outputs debe dejar
- qué capacidades puede invocar

Eso es exactamente lenguaje de harness.

### 11.6 El repo ya desacopla identidad cognitiva y enforcement operativo

Uno de los rasgos más interesantes de Inquiry es que no se limita a personificar agentes; también separa:

- identidad metodológica del APE
- contrato operativo de la fase
- contexto resuelto por CLI

Ese ensamblaje explícito es una forma bastante sofisticada de harness composition.

### 11.7 El repo ya conserva al humano como governor

Los harnesses serios no eliminan al humano; lo recolocan.

Inquiry ya hace eso cuando deja al humano en el rol de:

- autorizar transiciones
- iniciar protocolos críticos
- revisar resultados
- escribir mutaciones
- decidir cierre

Eso no es falta de autonomía. Es gobernanza del sistema.

---

## 12. En qué sentido el repositorio todavía no es un harness completo

Decir que el repo ya es un harness no significa que esté terminado.

Las capas que todavía parecen menos maduras, comparadas con los casos industriales estudiados, son estas.

### 12.1 Sensores explícitos

Inquiry describe muy bien el proceso, pero menos explícitamente el catálogo de sensores que deben usarse para:

- validación local rápida
- CI
- deriva continua
- runtime feedback
- evaluación inferencial

### 12.2 Eval Engineering formal

Falta convertir más fallos recurrentes en:

- datasets
- suites
- graders
- scorecards
- criterios de comparación sistemática

### 12.3 Observabilidad del agente

El repo conserva artefactos de razonamiento y handoff, pero parece menos maduro en trazas sistemáticas del tipo:

- qué validaciones corrió el agente
- qué falló y cuántas veces
- dónde se bloqueó
- qué reglas o skills se invocaron más

### 12.4 Policy explícita de contexto

Inquiry ya tiene buenas primitives de memoria como código, pero puede formalizar más su política de:

- progressive disclosure
- compaction
- retrieval por fase
- resets y handoffs en tareas largas

### 12.5 Harness templates

Todavía parece haber más metodología general que perfiles operativos específicos por topología de proyecto.

---

## 13. Diagnóstico formal de Inquiry dentro de la taxonomía

La formulación más precisa que deja esta investigación es la siguiente:

> **Inquiry es un sistema predominantemente de Harness Engineering, apoyado por Prompt Engineering y Context Engineering ya bastante desarrollados, con una capa de Eval Engineering todavía más implícita que formal.**

Si hubiera que expresarlo de manera todavía más sintética:

- no es principalmente una biblioteca de prompts
- no es principalmente un retrieval system
- no es todavía principalmente un eval platform
- sí es claramente un diseño de harness metodológico y operativo

---

## 14. Tesis práctica para el proyecto

Si quisieras nombrar el posicionamiento técnico de Inquiry con precisión contemporánea, una tesis razonable sería esta:

> Inquiry CLI construye y gobierna el harness epistemológico y operativo de un coding agent.

Eso recoge varias verdades a la vez:

- el proyecto no reduce el problema al prompt
- el proyecto entiende el contexto como algo ensamblado, no improvisado
- el proyecto externaliza memoria y procedimiento en el repo
- el proyecto impone restricciones y handoffs
- el proyecto mantiene al humano como autoridad de transición

Ese lenguaje también ayuda a ubicar mejor lo que falta: si el repositorio ya es un harness, entonces el trabajo siguiente no es “inventar otro marco”, sino **completar, instrumentar y medir mejor el harness existente**.

---

## 15. Conclusión

La taxonomía formal propuesta aquí permite separar cuatro problemas que suelen confundirse.

- **Prompt Engineering** diseña instrucciones.
- **Context Engineering** diseña el estado de atención del modelo.
- **Eval Engineering** diseña la medición.
- **Harness Engineering** diseña el sistema total de operación y control.

Aplicada a Inquiry, esta taxonomía muestra algo importante:

**tu repositorio ya es mucho más que documentación o prompting. Ya funciona como una parte sustantiva del harness del agente.**

Lo hace porque ya contiene:

- memoria versionada
- protocolos explícitos
- control de flujo por FSM
- handoffs persistentes
- ensamblaje de contexto
- skills como guías operativas
- autoridad humana como governor

La evolución natural del proyecto, entonces, no es preguntarse si Inquiry debería convertirse en un harness.

La pregunta correcta es:

**¿cómo hacer más explícito, más medible y más completo el harness que Inquiry ya es?**
