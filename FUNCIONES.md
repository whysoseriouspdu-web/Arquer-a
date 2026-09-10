# Qué hace la app — versión 8

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
