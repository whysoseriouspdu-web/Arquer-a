# Puesta en marcha de la cuenta del club

La app ya trae adentro la URL y la clave pública de tu proyecto. Faltan tres
pasos en el panel de Supabase.

## 1. Correr el esquema

Panel de Supabase → **SQL Editor** → *New query* → pegá todo el contenido de
`esquema.sql` → **Run**.

Tiene que decir *Success. No rows returned*. Si ya habías corrido el script
anterior, este lo corrige: borra las políticas viejas y crea las buenas. La
política de `profiles` del primer script se consultaba a sí misma y hacía fallar
cualquier lectura con "infinite recursion detected in policy".

## 2. Apagar la confirmación por mail

Panel → **Authentication** → *Sign In / Providers* → **Email** → desactivá
**Confirm email** → *Save*.

Para un club chico conviene: los socios crean la cuenta y entran de una. Si lo
dejás prendido, cada uno tiene que abrir un mail y hacer clic antes de poder
entrar, y en el celular eso se pierde seguido.

## 3. Probarlo vos primero

1. Abrí la app instalada, bajá hasta el pie y tocá **Entrar al club**.
2. *No tengo cuenta, crear una* → mail, contraseña de 6 o más, tu nombre.
3. Cargá una sesión corta de prueba y terminala.
4. En el panel de Supabase → **Table Editor** → `sessions` tiene que aparecer la
   fila, y en `session_archers` una fila por arquero.
5. Cerrá sesión y volvé a entrar: las sesiones tienen que bajar solas.

Si el punto 4 no aparece, tocá **Sincronizar** en la barra de cuenta: el mensaje
de error que salga abajo dice exactamente qué falló.

## Cómo funciona la sincronización

- Todo se guarda **primero en el teléfono**. La nube es una copia, no el original.
  Si no hay señal en el campo, cargás igual.
- Al terminar cada sesión intenta subir. Si falla, queda marcada como pendiente y
  se reintenta al recuperar conexión o cuando tocás Sincronizar.
- La barra de cuenta muestra el estado: verde al día, amarillo con pendientes,
  rojo sin conexión.
- Borrar una sesión la borra también en el servidor, incluso si estabas sin señal
  cuando la borraste.
- Sin cuenta, la app sigue funcionando exactamente como antes.

## Sumar a los compañeros

Por ahora cada uno crea su cuenta desde la misma dirección de la app y ve lo
suyo. Falta lo del club propiamente dicho: crear el club, que la gente se sume
con un código, y la pantalla de ranking y actividad. Eso es el próximo paso, y
antes conviene que definan lo que está al final de `PLAN-CLUB.md`: de quién son
los datos y qué ve el entrenador.

## Un detalle sobre la clave

La clave `anon` que está dentro de `index.html` es pública a propósito: sin
sesión iniciada no da acceso a nada, porque las políticas del punto 1 filtran
todo por usuario. La que nunca hay que poner en la app ni pasarle a nadie es la
`service_role`, que está en la misma pantalla del panel y saltea todas las
políticas.
