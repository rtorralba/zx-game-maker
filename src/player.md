# Uso del reproductor

El reproductor tiene dos funciones, una en la que se le dice que sonido se quiere reproducir, y otra en la que se reproduce el siguiente bloque.

El reproductor que genera BeepFX reproduce todo el efecto, lo que hace que el juego se pare ya que un efecto que sea algo más de un simple clic, dura demasiado tiempo.

Los efectos que se generan con BeepFX tienen uno o más bloques, lo cual permite que el reproductor pueda reproducir un bloque, guardar en memoria la dirección del siguiente bloque y cuándo se llame a NextNote reproducir ese bloque guardado.

## A tener en cuenta

El reproductor únicamente reproduce tonos, ruido y pausas (las pausas no son más que tonos con ciertos parámetros a 0).

Pese a que esta versión del reproductor sólo reproduce un bloque del efecto a cada vez, la duración del mismo puede seguir parando el juego. Si pruebas el tono de que por defecto te muestra BeepFX al abrir (Frames = 1, Frames length = 10000), si reproduces el tono, ese el tiempo que tu juego se parará.

Un bloque con una duración de un segundo aproximadamente, se consigue con un frame y una logitud del mismo de 32768, la duración del bloque resulta de multiplicar los frames por la longitud de los mismos.

## Como configurar los sonidos

Lo primero es ver que es cada parámetro:

### Parámetros del tono

* Frames: número de fracciones, no confundir con FPS ni nada por el estilo, es literalmente fracciones. Admite valores de 1 a 65536.
* Frame length: longitud de cada uno de los frames. Admite valores de 1 a 65536. 1 segundo es aproximadamente 32768.
* Pitch: frecuencia, este valor indica la nota. Admite valores de 1 a 65536.
* Pitch slide: deslizamiento de la frecuencia. Se aplica a cada frame, por lo que no tiene efecto si sólo hay un frame. Es el valor que se suma a la frecuencia. Admite valores de -32767 a 32768.
* Duty: servicio. En base a este valor se va a activar o desactivar el EAR y el altavor interno. El valor medio es 128, valor con el que las notas suenan más claras. Cambiando este valor se distorsiona el sonido. Admite valores de 0  a 255. Con 0 no se escucha nada.
* Duty slide: igual que Pitch Slide pero para Duty. En este caso parece que BeepFX tiene un bug, debería admitir valores entre -127 y 128, pero deja meter más rango.

**Ahora veamos como funcionan estos parámetros:**

Si configuro un bloque con 1 frame, 32768 de longitud, 440 de pitch, 0 de pitch slide, 128 de duty y 0 de duty slide, oiremos una LA de la escala media.
Si ahora pones 10 frames con una logitud de 3276 y pitch slide de 100, verás como el efecto dura el mismo tiempo, pero se escuchan 10 notas distintas. El primer frame empieza en la frecuencia 440 y va sumando 100 a la frecuencia en los siguientes.