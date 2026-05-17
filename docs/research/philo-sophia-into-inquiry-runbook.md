# Runbook — Migración de Philo SophIA hacia Inquiry

**Estado:** Active / in execution  
**Tipo:** Runbook de migración  
**Objetivo:** absorber el contenido del repo `philo_sophia` dentro de Inquiry sin perder historia, sin mezclar la migración con un rediseño editorial y sin dejar múltiples fuentes doctrinales compitiendo entre sí.

---

## 1. Decisiones ya fijadas

Estas decisiones se consideran resueltas y este runbook no las reabre:

1. Inquiry, el libro, el CLI y el site son un solo producto.
2. El hogar canónico del libro debe pasar a ser el repo Inquiry.
3. La fuente editorial canónica del libro será Markdown, no HTML.
4. El traslado no debe convertirse en una reescritura del stack editorial.
5. `code/book` será la superficie editorial del libro dentro de Inquiry.
6. El libro será canon doctrinal largo; las superficies operativas del producto seguirán viviendo en la documentación y assets del runtime.

---

## 2. Resultado esperado

Al terminar esta migración, debe cumplirse todo lo siguiente:

- El contenido editorial de `philo_sophia` vive dentro de Inquiry.
- La historia del repo fuente quedó preservada.
- El libro compila desde Inquiry en su nuevo hogar.
- El libro no interfiere con el release del CLI ni con el deploy del site.
- No existe ambigüedad sobre dónde vive el libro: vive en Inquiry.
- No existe ambigüedad sobre qué superficie gobierna qué tipo de verdad.

---

## 3. Mapa de autoridad del producto

Antes de cualquier importación, la autoridad conceptual del repo debe quedar así:

### 3.1 Canon doctrinal largo

- `code/book/`
- Aquí vive el manuscrito publicable del libro.
- Es la forma más desarrollada, curada y larga de la doctrina.

### 3.2 Canon operativo del producto

- `docs/architecture.md`
- `docs/thinking-tools.md`
- `docs/roadmap.md`
- `docs/spec/**`
- `code/cli/assets/**`
- `code/cli/test/**`

Estas superficies siguen gobernando comportamiento, contratos, runtime y validación.

### 3.3 Investigación y archivo

- `docs/research/inquiry/**`
- `docs/research/book/**` si la migración separa material de apoyo no publicado

Esta capa conserva bibliografía, investigación, borradores y material de soporte. No compite con el manuscrito final.

### 3.4 Síntesis pública

- `README.md`
- `code/site/**`

Esta capa explica, presenta y resume. No reemplaza al libro ni a la documentación operativa.

---

## 4. Restricciones del ciclo

### 4.1 Lo que este ciclo SÍ hace

- Importa el repo fuente dentro de Inquiry.
- Ubica cada superficie en su destino correcto.
- Deja el libro compilando en `code/book`.
- Reconciliará autoridad documental donde sea necesario.
- Deja el repo viejo deprecado como hogar secundario.

### 4.2 Lo que este ciclo NO hace

- No convierte el libro a HTML-first.
- No migra el handbook en paralelo.
- No unifica el versionado del libro con el CLI.
- No reescribe el contenido del libro como parte del traslado.
- No vuelve al libro fuente única del runtime.
- No replica capítulos enteros dentro del site.

### 4.3 Regla de desviación

Si cualquier fase obliga a escoger entre:

1. preservar historia y migrar limpio, o
2. rediseñar el pipeline editorial,

se elige la opción 1 y el rediseño se difiere a otro ciclo.

---

## 5. Destino recomendado por superficie

### 5.1 A `code/book/`

- manuscrito por idioma
- templates
- covers
- assets compartidos
- metadata editorial
- build scripts del libro
- lint/config local del libro
- README editorial del libro

### 5.2 A `docs/research/book/`

- notas argumentales no publicadas
- ideas sueltas
- análisis de títulos
- bibliografía de trabajo que no pertenezca ya a `docs/research/inquiry/`
- documentos auxiliares de desarrollo del libro

### 5.3 A documentación raíz de Inquiry

- navegación y mensajes sobre el libro en `README.md`
- mapa del libro en `docs/index.md`
- actualización histórica en `docs/timeline.md`

### 5.4 No mover directamente al site

- capítulos completos
- fuentes canónicas del libro
- assets editoriales acoplados al build del manuscrito

El site solo debe recibir puertas de entrada, extractos o enlaces.

---

## 6. Fases del runbook

## Phase 0 — Congelar autoridad antes de importar

**Entry criteria**

- Existe decisión explícita de unificar el libro dentro de Inquiry.
- Aún no se ha importado el repo fuente.

**Produces**

- Una política explícita de autoridad entre libro, docs, research y site.

**Steps**

- [x] Redactar una nota de migración que declare que `code/book/` será el hogar canónico del libro.
- [x] Declarar que `docs/research/inquiry/` permanece como base investigativa, no como libro alterno.
- [x] Declarar que `docs/architecture.md`, `docs/thinking-tools.md` y `docs/spec/**` siguen siendo la verdad operativa del producto.
- [ ] Declarar que `code/site/**` es síntesis pública, no manuscrito.
- [x] Enumerar qué contenido del repo fuente es editorial, qué contenido es investigativo y qué contenido es puramente operativo del build.

**Verification gate**

- [ ] Cualquier revisor puede responder dónde vive el canon doctrinal largo, dónde vive la verdad operativa y dónde vive la investigación.
- [ ] No hay dos superficies presentadas como hogar canónico del libro.

**Risk**

- Alto. Importar sin esta claridad produce conflicto doctrinal inmediatamente.

**Suggested commit**

- `docs: declare authority map for book migration`

---

## Phase 1 — Importar el repo fuente con historia preservada

**Entry criteria**

- Phase 0 aprobada.
- El repo fuente tiene un commit o tag elegido como punto de importación.

**Produces**

- El contenido completo de `philo_sophia` existe dentro de Inquiry con historia trazable.

**Steps**

- [x] Elegir el commit o tag exacto del repo `philo_sophia` que se importará.
- [ ] Congelar temporalmente cambios concurrentes en el repo fuente durante la importación.
- [ ] Importar el repo completo a un namespace temporal dentro de Inquiry.
- [x] Verificar que autoría, commits y estructura fueron preservados.
- [ ] Confirmar que la importación no aplasta rutas existentes del repo Inquiry.

**Verification gate**

- [x] La historia del libro se puede inspeccionar desde Inquiry.
- [ ] El namespace temporal contiene manuscrito, templates, covers, configuración y docs asociados.
- [ ] No hubo pérdida de superficies relevantes del repo fuente.

**Risk**

- Muy alto. Un copy-paste plano destruye arqueología editorial y trazabilidad doctrinal.

**Suggested commit**

- `chore(book): import philo_sophia history into inquiry`

---

## Phase 2 — Reubicar cada superficie al destino final

**Entry criteria**

- Phase 1 completada.
- El repo fuente ya existe dentro de Inquiry bajo namespace temporal.

**Produces**

- Estructura final limpia: editorial en `code/book`, investigación en `docs/research/book`, navegación en docs raíz.

**Steps**

- [x] Mover el manuscrito y su estructura multilengua a `code/book/`.
- [x] Mover templates, covers, metadata, assets y scripts editoriales a `code/book/`.
- [x] Mover el README editorial del libro a `code/book/README.md`.
- [x] Separar ideas, notas y material auxiliar no publicable del manuscrito.
- [x] Reubicar ese material a `docs/research/book/`.
- [ ] Limpiar el namespace temporal una vez verificado que no quedan activos sin destino.

**Verification gate**

- [x] `code/book/` contiene solo la superficie editorial del libro.
- [x] `docs/research/book/` contiene solo material investigativo y auxiliar.
- [ ] No quedaron duplicados accidentales del mismo contenido en dos hogares activos.

**Risk**

- Alto. Reubicar sin clasificar mezclaría manuscrito, archivo y tooling en un mismo subárbol.

**Suggested commit**

- `refactor(book): place imported surfaces in final inquiry locations`

---

## Phase 3 — Dejar el libro compilando dentro de Inquiry

**Entry criteria**

- La estructura final del libro ya existe en `code/book/`.

**Produces**

- Un pipeline editorial funcional dentro de Inquiry, sin cambiar aún el modelo editorial.

**Steps**

- [x] Ajustar rutas internas del build a la nueva ubicación.
- [ ] Ajustar includes, templates, covers y assets compartidos.
- [x] Ajustar rutas de salida de build para que permanezcan bajo `code/book/`.
- [x] Mantener el modelo editorial actual del libro durante esta fase.
- [x] Confirmar que la configuración de lint y validación del libro sigue siendo local al subárbol editorial.
- [ ] Confirmar que el build del libro no depende de supuestos de repo raíz heredados del repo fuente.

**Verification gate**

- [ ] El libro compila en PDF desde su nuevo hogar.
- [x] El libro compila en EPUB desde su nuevo hogar.
- [ ] Las lenguas existentes siguen compilando.
- [x] El build del libro no modifica ni depende del release del CLI.
- [x] El build del libro no modifica ni depende del deploy del site.

**Risk**

- Muy alto. Aquí es fácil mezclar adaptación de paths con rediseño completo del stack.

**Suggested commit**

- `build(book): make book pipeline work inside inquiry`

---

## Phase 4 — Reconciliar autoridad con la documentación viva de Inquiry

**Entry criteria**

- El libro ya vive en Inquiry y compila.

**Produces**

- Un mapa documental sin competencia entre libro, research, docs operativas y site.

**Steps**

- [ ] Auditar solapamientos doctrinales entre el libro y `docs/philosophy.md`.
- [ ] Auditar solapamientos doctrinales entre el libro y `docs/thinking-tools.md`.
- [ ] Auditar solapamientos doctrinales entre el libro y `docs/research/inquiry/index.md`.
- [ ] Auditar solapamientos doctrinales entre el libro y `docs/roadmap.md`.
- [x] Reescribir esos documentos solo en lo necesario para aclarar función y autoridad.
- [x] Eliminar wording que siga tratando al libro como proyecto paralelo.

**Verification gate**

- [ ] `docs/index.md` describe correctamente la nueva cartografía canónica.
- [ ] `docs/timeline.md` deja de presentar al libro como pista externa.
- [ ] Ningún documento canónico compite con `code/book/` por el rol de canon doctrinal largo.

**Risk**

- Muy alto. Esta fase corrige el riesgo conceptual más importante de toda la migración.

**Suggested commit**

- `docs: align inquiry canon around integrated book`

---

## Phase 5 — Integrar navegación y descubribilidad

**Entry criteria**

- La autoridad del libro ya está resuelta internamente.

**Produces**

- El libro es descubrible desde la entrada pública y documental del producto.

**Steps**

- [x] Añadir el libro al `README.md` raíz como superficie oficial del producto.
- [x] Añadir el libro a `docs/index.md`.
- [x] Ajustar `docs/timeline.md` para relatar correctamente la integración.
- [ ] Decidir una puerta de entrada al libro desde `code/site/**` sin duplicar capítulos completos.
- [x] Añadir un breve texto que explique la relación entre libro, docs operativas, research y site.

**Verification gate**

- [x] Un usuario nuevo puede descubrir el libro desde la raíz del repo.
- [x] Un usuario nuevo entiende qué relación tiene el libro con Inquiry sin leer historia externa.

**Risk**

- Medio. El libro puede quedar técnicamente integrado pero culturalmente invisible.

**Suggested commit**

- `docs(site): expose integrated book surface`

---

## Phase 6 — Aislar CI, build y publicación del libro

**Entry criteria**

- El libro ya está integrado conceptualmente y es navegable.

**Produces**

- Un carril editorial autónomo dentro del monorepo.

**Steps**

- [x] Crear un workflow propio del libro, path-scoped a `code/book/**` y lo que toque estrictamente su publicación.
- [x] Verificar que el workflow del libro no toca el release del CLI.
- [x] Verificar que el workflow del libro no toca el deploy de Pages salvo una integración explícita posterior.
- [x] Definir artefactos editoriales de salida y su lugar de publicación.
- [ ] Mantener por ahora versionado editorial separado del binario.
- [ ] Añadir lint y validaciones mínimas del libro en ese carril.

**Verification gate**

- [x] Cambios en el libro disparan solo el pipeline editorial.
- [x] Cambios en CLI no reconstruyen el libro salvo cuando el cambio lo requiera explícitamente.
- [x] Cambios en site no reconstruyen el libro salvo cuando el cambio lo requiera explícitamente.
- [ ] El libro produce artefactos reproducibles desde Inquiry.

**Risk**

- Alto. Sin aislamiento, el libro se convierte en una fuente de fricción para el producto operativo.

**Suggested commit**

- `ci(book): isolate editorial pipeline from cli and site`

---

## Phase 7 — Deprecar el hogar viejo y cerrar el corte

**Entry criteria**

- El libro ya vive, compila, se descubre y puede publicarse desde Inquiry.

**Produces**

- Un único hogar canónico del libro.

**Steps**

- [x] Actualizar el README del repo fuente para apuntar al nuevo hogar en Inquiry.
- [x] Declarar el repo fuente como deprecado o read-only.
- [x] Cortar cualquier mensaje que todavía presente al repo viejo como hogar vivo.
- [ ] Confirmar que navegación y documentación internas de Inquiry ya no dependen del repo viejo como superficie primaria.

**Verification gate**

- [x] La respuesta a “¿dónde vive el libro?” es única: Inquiry.
- [ ] El repo viejo ya no recibe trabajo nuevo.
- [ ] No quedan referencias activas al repo viejo como hogar canónico.

**Risk**

- Medio. Si el repo viejo queda semi-activo, aparece split brain rápidamente.

**Suggested commit**

- `docs: deprecate philo_sophia repository after inquiry cutover`

---

## Phase 8 — Gate final de validación

**Entry criteria**

- Todas las fases previas están completas.

**Produces**

- Evidencia final de que la migración fue real, estable y auditable.

**Steps**

- [ ] Ejecutar build completo del libro dentro de Inquiry.
- [ ] Ejecutar validaciones del producto no relacionadas para confirmar no regresión colateral.
- [ ] Revisar la estructura final del repo y el diff acumulado.
- [ ] Verificar navegación desde `README.md` y `docs/index.md`.
- [ ] Verificar que la historia del libro quedó preservada.
- [ ] Verificar que el repo viejo quedó inequívocamente deprecado.
- [ ] Registrar evidencia final de compilación, canonicidad y corte.

**Verification gate**

- [ ] El libro compila y vive dentro de Inquiry.
- [ ] CLI y site no sufrieron regresiones colaterales.
- [ ] No existen dos hogares doctrinales activos.
- [ ] La migración es trazable desde git y desde la documentación del producto.

**Risk**

- Alto. Sin este gate, una migración grande puede “parecer terminada” sin estarlo.

**Suggested commit**

- `chore(book): finalize philo_sophia migration into inquiry`

---

## 7. Orden recomendado de PRs

### PR 1 — Importación con historia

- importa el repo fuente a namespace temporal
- no reordena canonicidad
- no toca el stack editorial

### PR 2 — Reubicación y build verde

- mueve el libro a `code/book/`
- mueve investigación asociada a `docs/research/book/`
- deja el build del libro funcionando dentro de Inquiry

### PR 3 — Reconciliación doctrinal

- alinea `README.md`, `docs/index.md`, `docs/timeline.md` y docs canónicas con el nuevo hogar del libro

### PR 4 — CI y deprecación del repo fuente

- introduce pipeline editorial separado
- define publicación de artefactos
- depreca formalmente el repo viejo

---

## 8. Criterios de aprobación del runbook

- [ ] Preserva historia; no hace copy-paste plano.
- [ ] No mezcla migración con replatform editorial.
- [ ] Da destino a todo el contenido del repo fuente, no solo al manuscrito.
- [ ] Deja una sola autoridad doctrinal larga.
- [ ] Mantiene separadas las verdades operativa, investigativa, editorial y pública.
- [ ] No contamina release del CLI ni deploy del site.
- [ ] Deja el repo viejo en un estado inequívoco de transición o cierre.

---

## 9. Nota final

Este runbook está diseñado para una **absorción controlada de canonicidad**, no para un simple traslado de archivos. La prioridad del ciclo es que el libro deje de vivir fuera del producto sin perder su historia ni degradar la arquitectura editorial que ya tiene.