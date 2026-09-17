# Qué hace la app — versión 10.3

## Navegación

Barra inferior con cuatro secciones. Desaparece mientras estás tirando, para no
tocarla sin querer con el pulgar.

- **Tirar** — sesiones, historial y detalle de cada una.
- **Estadísticas** — tus números y las sugerencias.
- **Club** — socios, roles y, si sos entrenador, las estadísticas de cada arquero.
- **Mi cuenta** — tu perfil, sincronización, respaldos, cerrar sesión y versión.

## Estadísticas

Se calculan sobre las flechas, no sobre los totales, así que sirven aunque las
sesiones tengan distinto largo.

- Promedio por flecha, dispersión, porcentaje de dieces y de nueves o más.
- **Dónde caen tus flechas**: distribución de cada valor, de 10 a M.
- **Por número de serie**: promedio de la primera serie, la segunda y así. Es lo
  que revela si arrancás frío o si te caés sobre el final.
- **Por distancia**: sesiones, flechas y promedio en cada una.
- **Entrenamiento contra competencia**, cuando hay suficientes flechas de cada uno.
- **Por posición en la serie**: promedio de la 1ª flecha, la 2ª y así hasta la última.
  Distinto de la curva por serie: acá se ve el ritmo dentro de cada tanda.
- **Mes a mes** y **récords**: mejor serie, mejor sesión, proyección a una ronda de
  60 flechas y cuánto varían tus sesiones entre sí.

## Distancias

Los botones cubren de 5 a 70 m, y con "Otra…" cargás cualquier valor entre 1 y 200.
Queda guardada como un botón más mientras dure la sesión.

## Respaldos

- **Guardar respaldo** — en el iPhone abre el menú de compartir, así lo mandás
  directo por mail o WhatsApp. En otros equipos descarga el archivo.
- **Levantar respaldo** — vuelve a cargar ese archivo, acá o en un teléfono nuevo.
  Fusiona con lo que ya haya, no lo pisa.
- **Bajar todo del servidor** — recupera tus sesiones desde tu cuenta, sin archivo.

## Sugerencias

Reglas sobre tus propios números, no consejos genéricos. Detectan arranque frío,
caída por fatiga, dispersión alta o baja, exceso de flechas perdidas, tendencia
en alza o en baja, brecha entre entrenamiento y competencia, poca frecuencia,
falta de variedad de distancias y el caso de agrupar bien sin centrar.

Con menos de 60 flechas cargadas no sugiere nada: avisa que faltan datos, que es
más honesto que inventar un patrón donde hay ruido.

Importante: todo sale del puntaje, que no dice **dónde** impactó cada flecha. Una
misma cifra puede venir de agrupar mal o de agrupar bien pero descentrado. Por eso
las sugerencias orientan, y no reemplazan el ojo del entrenador.

## Roles y qué ve cada uno

- **Arquero** — sus estadísticas y su historial.
- **Anotador** — igual, más cargar sesiones grupales.
- **Entrenador** — la lista del club con el promedio de cada arquero; toca un
  nombre y ve sus estadísticas completas con las sugerencias. Solo lectura.
- **Admin** — lo mismo, más asignar roles y sacar socios del club.
- **Superadmin** — todos los clubes y todos los arqueros.

## Tipo de sesión

Al crear una sesión elegís entrenamiento o competencia. Separarlas importa: un
promedio de competencia no se compara con uno de entrenamiento, y la diferencia
entre ambos es justamente uno de los indicadores más útiles.


## Diana táctil

Al crear la sesión elegís **cómo anotás**:

- **Teclado** — como hasta ahora, tocás el valor. Rápido, ideal para anotar a otros
  o cuando vas apurado.
- **Diana** — tocás sobre la cara del blanco dónde impactó la flecha. El puntaje lo
  calcula la app a partir del radio, así que no anotás dos veces.

Con diana elegís también el tamaño de la cara: 40, 60, 80 o 122 cm. Ese dato es el
que permite convertir todo a centímetros reales.

Se decide por sesión, no de una vez para siempre. Podés usar diana en tus
entrenamientos técnicos y teclado cuando anotás una grupal de seis personas.

### Lo que habilita

- **Dónde impactan** — todas tus flechas sobre una cara, con una cruz verde en el
  centro del grupo.
- **Centro del grupo** en centímetros respecto del medio. Si está corrido, es la
  mira, y la sugerencia te dice hacia dónde moverla.
- **Ancho del grupo**, y por separado la apertura vertical y la horizontal. Que se
  abra a lo alto o a lo ancho apunta a causas técnicas distintas: la vertical suele
  ser longitud de tiro y anclaje, la horizontal suelta o brazo de arco.
- El CSV exporta las coordenadas en centímetros, por si querés analizarlas aparte.

Las sesiones viejas anotadas con teclado se siguen leyendo igual; simplemente no
tienen coordenadas y no aparecen en el mapa.


## Mi equipo

En Mi cuenta → Mi equipo cargás cada configuración de material: nombre, tipo de
arco, potencia nominal y real a tu apertura, longitud, brace height, flechas
(marca, modelo, spine, largo, peso, plumas), visor, estabilización, cuerda y notas.

Al empezar una sesión elegís con cuál tirás. Eso habilita la tabla **Por equipo**
en estadísticas y la sugerencia que compara configuraciones: si con una promediás
mejor que con otra, te lo dice, con la cantidad de flechas de cada una para que
juzgues si la diferencia es sólida o todavía es poca muestra.

La utilidad real aparece cuando cambiás algo: creá una configuración nueva en vez
de editar la anterior, y en unas semanas la app te dice si el cambio sirvió.

## Condiciones

Cada sesión guarda si fue bajo techo o al aire libre, y con cuánto viento. No es
decorativo: si más del 40% de tus sesiones fueron con viento, la sugerencia sobre
dispersión horizontal te avisa que parte de esa apertura puede ser del clima y no
tuya, y te propone medir bajo techo para confirmarlo.

## Lo que la app no mide, y por qué

Consistencia de suelta, expansión, postura, tiempo de anclaje. Eso necesita video
analizado cuadro a cuadro, sensores en la cuerda o un clicker con micrófono. Sin
ese equipamiento no hay dato, y un número inventado sería peor que no mostrar nada.
Todo lo que la app afirma sale de flechas registradas.


## Sesiones en vivo con marcador

Para entrenar en grupo donde cada uno anota lo suyo y el puntaje se ve en una
pantalla grande.

### Cómo se arma

1. El anotador crea una sesión grupal, carga los nombres y en **Cómo se anota**
   elige *Cada uno en su celular*.
2. La app abre la sesión y muestra un **código de cinco caracteres** y un **QR**.
3. Cada compañero entra a *Unirme a una sesión* y tiene dos caminos: tocar
   **Escanear el QR** y apuntar la cámara a la pantalla del anotador, o escribir
   el código de cinco caracteres. Después elige su nombre de la lista y ya puede
   cargar sus flechas.
4. Para la pantalla grande se abre en la tele o la laptop el link del marcador.
   **No pide cuenta**: alcanza con tener el link.
5. Cuando termina el entrenamiento, el anotador toca *Cerrar la sesión para
   todos*. Deja de aceptar cargas y se guarda completa.

### Qué muestra el marcador

Posición, nombre, promedio por flecha, serie en curso y puntaje, ordenado por
puntaje y con el líder destacado. Se actualiza solo cada cinco segundos y la
tipografía crece en pantallas grandes.

### Cosas a tener en cuenta

- Cada arquero solo puede escribir en su propia planilla. La base lo impide, no
  es una cuestión de confianza.
- Quien se une necesita cuenta y conexión. Sin señal en el campo, conviene la
  modalidad de siempre, con el anotador cargando a todos.
- El marcador es legible por cualquiera que tenga el link. Son puntajes de
  entrenamiento, pero conviene saberlo antes de compartirlo.
- La sesión le queda en el historial a cada participante, con sus propias
  estadísticas, sin que nadie tenga que cargar nada dos veces.
- El QR se genera con un servicio externo, así que necesita internet en el
  momento de mostrarlo. El código de cinco caracteres siempre funciona igual.


## Lector de QR

Está dentro de *Unirme a una sesión*. Conviene usar ese, y no la cámara del
sistema: el scanner del iPhone abre el link en Safari, fuera de la app instalada,
y ahí la sesión iniciada es otra.

Usa el lector nativo del navegador cuando existe, y si no, uno propio incluido en
la app (jsQR, licencia Apache 2.0), así funciona igual en iPhone. Reconoce tanto
el link completo como el código suelto. Si no hay permiso de cámara, lo dice y
siempre queda la opción de escribir los cinco caracteres a mano.

La cámara se apaga sola al salir de la pantalla o al encontrar el código.


## Orden de carga de las flechas

En arquería la planilla se llena de mayor a menor. Con ese orden, la "primera"
flecha de la serie es siempre la mejor y la "última" siempre la peor, por
definición y no por cómo tiraste. Cualquier análisis del ritmo dentro de la serie
basado en ese orden es un espejismo.

La app ahora lo detecta sola: si la mayoría de tus series vienen en orden
decreciente, desactiva el gráfico "Por posición en la serie" y las dos sugerencias
que dependían de él, y explica por qué en la pantalla de estadísticas.

En Mi cuenta podés forzarlo:

- **Automático** (recomendado) — lo decide según tus datos.
- **Como las tiro** — si cargás en el orden real de tiro; habilita el análisis.
- **De mayor a menor** — si siempre usás la convención de planilla.

El análisis **por número de serie** no está afectado: comparar la primera serie
con la última sigue siendo válido, porque ahí el orden sí es el real.


## Dentro de la serie

Reemplaza al análisis por posición, y es mejor: usa el conjunto de valores de cada
serie, no la secuencia, así que vale igual con planilla de mayor a menor.

- **Techo y piso** — promedio de las mejores flechas de cada serie contra el de las
  peores. El techo es lo que tu técnica ya puede hacer; la diferencia con el piso
  es margen disponible sin aprender nada nuevo.
- **Amplitud media** — cuántos puntos hay entre tu mejor y tu peor flecha de cada
  serie. Mide repetición del gesto.
- **Series con una flecha caída** y su **costo por ronda** — cuántas veces una sola
  flecha arruina la tanda, y cuántos puntos ganarías por ronda de 60 si esa flecha
  se acercara apenas al resto. Suele ser el número más grande y el más fácil de
  corregir, porque no es técnica sino saber cortar el tiro.
- **Series limpias** y mejor racha — porcentaje de series sin nada por debajo de 7.
- **Variación entre series** — qué parte de tu dispersión ocurre entre tandas y qué
  parte dentro de cada una. Mucha variación entre series apunta a foco y rutina;
  mucha dentro, a ejecución flecha a flecha. Son problemas distintos con soluciones
  distintas, y hasta ahora la app no los distinguía.
