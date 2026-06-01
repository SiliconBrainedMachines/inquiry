# The Coding Manifesto

> *Haiku clarity. Katana precision.*
> *Code that reveals its purpose.*
>
> Reglas accionables derivadas de este manifiesto: [coding-manifesto-prompt.md](coding-manifesto-prompt.md)

---

<a id="la-intención-lo-gobierna-todo"></a>
## La intención lo gobierna todo

La intención no es un detalle. Es el origen.

Antes de escribir una línea, existe una intención. Antes de nombrar una función, existe una intención. Antes de elegir una estructura, de dividir una responsabilidad, de colocar un comentario — existe una intención. Todo lo que aparece en el código es consecuencia de ella.

Cuando generes código, **la intención es el capitán**. No la convención, no la brevedad, no la elegancia por sí sola. Todo sirve a la intención. Todo se justifica ante ella.

Un código sin intención visible es ruido con sintaxis válida.

---

<a id="el-código-es-música"></a>
## El código es música

La música no se explica mientras suena. Se escucha y se comprende — o no. Pero cuando está bien compuesta, cada nota ocupa el único lugar donde podía estar.

El código es igual. Tiene ritmo: la cadencia de las funciones que se llaman entre sí. Tiene dinámica: la forma en que la complejidad sube y baja según el nivel de abstracción. Tiene silencio: los espacios, la estructura, lo que se omite deliberadamente.

Escribe código que pueda **leerse como se escucha una pieza bien interpretada** — donde el siguiente movimiento se siente inevitable.

- Los nombres tienen melodía. Un nombre torpe interrumpe el flujo de lectura como una nota disonante. Y los predicados booleanos se escriben en positivo — `isActive`, `isEnabled`, `isVisible` — porque la afirmación fluye con la lectura; la negación obliga a invertir mentalmente, como un compás en contraparte que rompe el ritmo natural. La forma negativa (`isDeprecated`, `isCancelled`, `isReadOnly`) solo es legítima cuando el dominio piensa naturalmente en esa dirección.
- La estructura tiene tiempo. El orden de las declaraciones no es arbitrario: lo que aparece primero establece el tema.
- La coherencia es armonía. Mezclar niveles de abstracción en una misma función es tocar dos canciones al mismo tiempo.

---

<a id="el-código-es-arte"></a>
## El código es arte

El arte no justifica cada decisión. Las toma con criterio, con intención y con oficio acumulado.

- **No abrevies nombres: destílalos.** El nombre correcto no es el más corto ni el más descriptivo — es el más *preciso*. El que captura la esencia sin cargar de más.
- **La estructura visual comunica.** El espaciado, el agrupamiento, la simetría o su ausencia deliberada — todo es parte del mensaje.
- **Una función, una responsabilidad.** No como límite, sino como pureza de forma: si necesita una conjunción para describirse, es dos obras distintas.
- **El orden del código es un argumento.** Lo que está junto está relacionado. Lo que aparece primero importa más. La posición es semántica.

---

<a id="el-código-es-técnica"></a>
## El código es técnica

La excelencia técnica no es opuesta al arte. Es su condición.

- **Nada implícito en los contratos.** Las entradas, salidas y efectos de una función deben ser evidentes. Los efectos ocultos son deuda técnica disfrazada de conveniencia.
- **Las estructuras de datos revelan el modelo mental.** Elegir bien entre un mapa, una lista o un objeto es una declaración sobre cómo se entiende el problema.
- **El manejo de errores es parte del diseño.** Un error silenciado es una mentira estructural. Cada error debe decir con exactitud qué salió mal, dónde y por qué importa.
- **Elimina lo especulativo.** El código que "podría servir después" contamina el código que sirve ahora. Lo que no existe hoy no debería ocupar espacio hoy.
- **Las abstracciones se ganan.** No se anticipan. Abstrae lo que ya repetiste — no lo que imaginas que repetirás.

---

<a id="el-código-es-oficio"></a>
## El código es oficio

El oficio no se improvisa. Se ejerce. Se afila. Se cuida.

El código que oculta su propósito es código que abandonó su oficio a mitad del camino. El código que revela su intención con claridad es el resultado de alguien que terminó el trabajo.

- **La lógica de negocio no se entierra.** No vive en condiciones anidadas, callbacks encadenados ni transformaciones implícitas. Vive en el nivel donde puede leerse como una decisión explícita.
- **Los nombres genéricos son incompletud.** `data`, `manager`, `helper`, `utils` — señales de que algo aún no encontró su identidad. El oficio es encontrarla.

---

<a id="el-código-es-vocación"></a>
## El código es vocación

Esto no es trabajo de producción. Es trabajo de significado.

Cada sistema que se construye es una forma de pensar hecha visible. Cada función bien nombrada es un acto de respeto hacia quien leerá después — incluyendo al propio autor. Cada comentario bien colocado es un gesto de generosidad técnica.

La vocación no exige perfección. Exige **búsqueda genuina de excelencia** — la disposición a reescribir lo que casi estuvo bien, porque casi no es suficiente cuando el oficio se ejerce con convicción.

---

<a id="los-comentarios--el-compañero"></a>
## Los comentarios — el compañero

Un buen comentario no explica **qué** hace el código. Eso ya lo dice el código.

Un buen comentario:

- **Clarifica la intención** cuando el *por qué* no es evidente en el *qué*.
- **Evita ambigüedades** en lógica que podría leerse de dos maneras correctas.
- **Recalca relaciones** entre partes del sistema que no son obvias por proximidad.
- **Advierte sobre decisiones** que parecen incorrectas pero tienen razón de ser.

> Si el código es la partitura, el comentario es la nota del compositor al intérprete.
> No reemplaza la música. La acompaña.

Nunca generes comentarios que parafraseen el código. Genera comentarios que lo profundicen.

---

<a id="lo-que-nunca-debes-hacer"></a>
## Lo que nunca debes hacer

- Generar código "defensivo" lleno de casos que nadie pidió
- Usar nombres que requieren contexto externo para tener sentido
- Escribir comentarios que repiten lo que el código ya dice
- Crear abstracciones antes de que exista una segunda instancia que las justifique
- Silenciar errores o usar manejo genérico para no interrumpir el flujo
- Mezclar niveles de abstracción dentro de una misma función
- Entregar código que funcione pero no revele su intención

---

<a id="la-prueba-final"></a>
## La prueba final

Antes de entregar código, aplica este filtro:

1. ¿La intención del sistema es legible de corrido, sin necesidad de trazar su ejecución?
2. ¿Cada nombre dice exactamente lo que es — sin más, sin menos?
3. ¿Cada función hace exactamente una cosa y podría describirse sin conjunciones?
4. ¿Cada comentario agrega algo que el código solo no puede decir?
5. ¿Qué puedo eliminar sin perder significado?

Si algo falla este filtro, reescríbelo. No lo parches.

---

*El código no es un medio para un fin.*
*Es la forma más alta de hacer visible una forma de pensar.*
*Se escribe con claridad de haiku, con precisión de katana*
*y con la convicción de quien ejerce su vocación.*
