Juan Antonio Rubio García.

Modificación del reproductor de BeepFX para que reproduzca bloque a bloque.

# Uso del reproductor

El reproductor tiene dos funciones, una en la que se le dice qué sonido se quiere reproducir, y otra en la que se reproduce el siguiente bloque.

El reproductor que genera BeepFX reproduce todo el efecto, lo que hace que el juego se pare, pues un efecto que sea algo más de un simple clic dura demasiado tiempo.

Los efectos que se generan con BeepFX tienen uno o más bloques, lo cual permite que el reproductor pueda reproducir un bloque, guardar en memoria la dirección del siguiente bloque y cuándo se llame a NextNote reproducir ese bloque guardado.

## A tener en cuenta

El reproductor únicamente reproduce tonos, ruido y pausas (las pausas no son más que tonos con ciertos parámetros a 0).

Pese a que esta versión del reproductor sólo reproduce un bloque del efecto acada vez, la duración del mismo puede seguir parando el juego. Si pruebas el tono que por defecto te muestra BeepFX al abrir (Frames = 1, Frames length = 10000), si reproduces el tono, ese el tiempo que tu juego se parará.

Un bloque con una duración de un segundo aproximadamente, se consigue con un frame y una logitud del mismo de 32768, la duración del bloque resulta de multiplicar los frames por la longitud de los mismos. Mi recomendación es que no configures bloques en los que la multiplicación de frames por longitud sea mayor a 500, aunque te aconsejo probar y ajustar a tu gusto y necesidades.

## Uso de las funciones

Antes de llamar a la función Play, en la dirección de memoria siguiente a la que se haya cargado el reproductor hay que poner el número del sonido a reproducir, de 0 a 127. Cada efecto puede tener un máximo de 128 bloques. Una vez puesto en Play+1 el sonido a reproducir, llama a la función Play.

Cada vez que quieras reproducir un bloque, ya sea nota, ruido o pausa, llama a NextNote (si lo haces desde ensamblador) o a Play+17 si lo haces desde Boriel Basic. Si al llamar 

## Cómo configurar los sonidos

Cada sonido se configura de manera distinta, aunque semejante, por lo que lo vamos a ver por separado, tantos sus parámetros como su uso.

### Parámetros del tono

* Frames: número de fracciones, no confundir con los típicos cincuenta frames por segundo (o sesenta) del ZX-Spectrum. Admite valores de 1 a 65536.
* Frame length: longitud de cada uno de los frames. Admite valores de 1 a 65536. 1 segundo es aproximadamente 32768.
* Pitch: frecuencia, este valor indica la nota. Admite valores de 1 a 65536.
* Pitch slide: deslizamiento de la frecuencia. Se aplica a cada frame, por lo que no tiene efecto si sólo hay un frame. Es el valor que se suma a la frecuencia. Admite valores de -32767 a 32768.
* Duty: servicio. En base a este valor se va a activar o desactivar el EAR y el altavor interno. El valor medio es 128, valor con el que las notas suenan más claras. Cambiando este valor se distorsiona el sonido. Admite valores de 0  a 255. Con 0 no se escucha nada.
* Duty slide: igual que Pitch Slide pero para Duty. En este caso parece que BeepFX tiene un bug, debería admitir valores entre -127 y 128, pero deja meter más rango.


**Ahora veamos como funcionan estos parámetros:**

Si configuras un bloque con 1 frame, 32768 de longitud, 440 de pitch, 0 de pitch slide, 128 de duty y 0 de duty slide, oiras el LA de la escala media. Si ahora pones 10 frames con una logitud de 3276 y pitch slide de 100, verás como el efecto dura el mismo tiempo, pero se escuchan 10 notas distintas. El primer frame empieza en la frecuencia 440 y va sumando 100 a la frecuencia en los siguientes.

Las frecuencias de la escala media son las siguientes:

| Nota |   | Frecuencia | |
| - | - | - | - |
| DO | C | | 261,60 |
| DO# | C# | | 277,20 |
| RE | D | | 293,70 |
| RE# | D# | | 311,10 |
| MI | E | | 329,60 |
| FA | F | | 349,20 |
| FA# | F# | | 370,00 |
| SOL | G | | 392,00 |
| SOL# | G# | | 415,30 |
| LA | A | | 440,00 |
| LA# | A# | | 466,20 |
| SI | B | | 493,90 |

Aunque las frecuencias tienen decimales, tú siempre especificarás los valores enteros. Para subir una escala debes multiplicar el valor de la nota por dos y para bajar una escala dividirlo entre dos, de ahí que se reflejen los valores decimales, si subes cuatro escalas, al multiplicar por ocho el SI sin tener en cuenta los decimales da tres mil novecientos cuarenta y cuatro, pero teniendo en cuenta los decimales da tres mil novecientos cincuenta y uno sin tener en cuenta los decimales del resultado, una diferencia de siete aunque no creo que se llegue a notar.

### Parámetros del ruído

* Frames: igual que Frames en los parámetros del tono.
* Frame length: igual que Frame length en los parámetros del tono.
* Pitch: parecido a Pitch en los parámetros del tono, pero admite valores de 1 a 256. Usar los valores que hay en los primeros 8Kb de la ROM para generar el ruido.
* Pitch slide: igual que Pitch slide en los parámetros del tono.

### Parámetros de la pausa

* Frames: igual que Frames en los parámetros del tono.
* Frame length: igual que Frame length en los parámetros del tono.

Si te fijas en el código ensamblador generado que genera BeepFX la pausa es identica al tono (incluso se identifica como tal), pero con los parámetros Pitch, Pitch slide, Duty y Duty slide a cero.

Esto es algo que tienes que tener muy en cuenta. Si tu sonido (o quizá música) va a reproducir un bloque en cada interrupción, pero para conseguir el compás correcto necesitas incluir pausas (notas que no suenan), estas pausas debes configurarlas con Frames = 1 y Frame length = 1. Durante esa interrupción, o en el blucle del programa, lo único que interesa es que la nota que suena no suene, cuánto menos dure mucho mejor.