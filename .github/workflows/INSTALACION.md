# Registro de arquería — instalación

## Lo importante primero

En iPhone, la app **tiene que estar instalada en la pantalla de inicio** y la
dirección web **tiene que ser siempre la misma**. Si la abrís desde una pestaña
de Safari, o desde una dirección que cambia, el teléfono puede borrar los
registros por su cuenta. Es exactamente lo que pasa con un sitio de Netlify Drop
sin cuenta: es temporal y la dirección cambia cada vez que subís la carpeta.

## Paso 1 — Subirla a una dirección fija (GitHub Pages)

1. Creá una cuenta en github.com si no tenés.
2. *New repository* → nombre `arqueria` → **Public** → *Create*.
3. *Add file → Upload files*: arrastrá todos los archivos de esta carpeta
   (no la carpeta, los archivos sueltos) → *Commit changes*.
4. *Settings → Pages* → en **Source** elegí `Deploy from a branch`,
   rama `main`, carpeta `/ (root)` → *Save*.
5. A los dos minutos queda publicada en `https://TUUSUARIO.github.io/arqueria/`.
   Esa dirección ya no cambia nunca.

Alternativa: Netlify, pero **creando cuenta** y reclamando el sitio
(*Site settings → Change site name*). Sin cuenta no sirve.

## Paso 2 — Instalarla en el iPhone

1. Abrí la dirección en **Safari** (no Chrome, en iPhone solo Safari puede instalar).
2. Asegurate de que no sea una pestaña privada: si la barra de abajo se ve oscura,
   salí de navegación privada primero.
3. Botón de compartir (el cuadrado con la flecha) → **Agregar a inicio** → *Agregar*.
4. Cerrá Safari y **abrila siempre desde el ícono nuevo**. Ahí adentro el
   almacenamiento es propio de la app y no lo toca nadie.

Si abrís la app y arriba aparece el aviso rojo "Instalala antes de tirar",
quiere decir que estás en el navegador y no en la app instalada. No cargues una
sesión así.

## Paso 3 — Respaldos

Cada tres sesiones la app te va a ofrecer bajar un respaldo. Aceptá y mandá ese
archivo `.json` a tu mail o a Drive. Con eso, aunque se pierda el teléfono,
recuperás todo con el botón **Restaurar**.

- **Guardar respaldo** — baja un `.json` con todo.
- **Restaurar** — lo vuelve a cargar; fusiona, no pisa lo que ya tengas.
- **Exportar CSV** — una fila por flecha, para Excel.

## Qué cambió en esta versión

- Los datos se guardan en dos lugares a la vez (IndexedDB y localStorage). Si uno
  se borra, la app se recupera del otro al abrirse.
- La app le pide al navegador que trate los datos como permanentes.
- Aviso visible cuando está corriendo sin instalar.
- Recordatorio de respaldo cada tres sesiones.

## Actualizarla más adelante

Si cambiás `index.html`, subilo y además cambiá en `sw.js` la línea
`const CACHE = "arqueria-v2"` a `"arqueria-v3"`. Sin eso el teléfono sigue usando
la versión vieja guardada.
