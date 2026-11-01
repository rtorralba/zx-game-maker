# Reglas y Guía de Desarrollo para Agentes - ZX Game Maker

> [!IMPORTANT]
> **REGLA FUNDAMENTAL Y OBLIGATORIA:**
> **TODO lo que hagas (modificaciones, refactorizaciones, correcciones de bugs, optimizaciones o nuevas funcionalidades) TIENE QUE DOCUMENTARSE SÍ O SÍ.**
> Cada cambio debe quedar registrado y explicado: qué se modificó, por qué, qué efectos secundarios previene y cómo interactúa con el resto del sistema.

---

## 1. Visión General del Proyecto

**ZX Game Maker** es una herramienta y motor para el desarrollo de videojuegos destinados a ordenadores **Sinclair ZX Spectrum** (modelos 48K y 128K).

- **Lenguaje del juego**: Boriel ZX Basic (`zxbc`), complementado con rutinas en ensamblador Z80 (`GuSprites.zxbas`).
- **Herramientas de tooling**: Python 3 con interfaz de usuario en Tkinter (`launcher.py` / `zxsgm.py`) y scripts de soporte.
- **Editor de niveles y HUD**: [Tiled Map Editor](https://www.mapeditor.org/) (`maps.tmx`, `hud.tmx`).
- **Entorno de ejecución / compilación**: Se ejecuta a través de un entorno virtual ubicado en `venv/`.

---

## 2. Flujo de Construcción y Compilación

1. **Punto de Entrada**:
   - `.\zxsgm.py`: Inicializa el entorno virtual (`venv`), instala dependencias de `requirements.txt` si faltan, y lanza el lanzador `src/launcher.py`.

2. **Pipeline de Build (`src/build.py`)**:
   - **`tiledBuild()`**: Ejecuta Tiled en modo CLI para exportar `hud.tmx` y `maps.tmx` a formato JSON (`output/hud.json`, `output/maps.json`). Luego ejecuta `src/bin/tiled-build.py`.
   - **`tiled-build.py`**:
     - Procesa pantallas, tiles, enemigos y el HUD.
     - Extrae coordenadas de los objetos de `hud.tmx` y genera `#DEFINE HUD_<ELEMENTO>_X` y `#DEFINE HUD_<ELEMENTO>_Y` en `output/config.bas`.
     - *Nota sobre coordenadas de Tiled*: Para tilesets/objetos en Tiled, la coordenada `Y` tiene el origen en la esquina inferior izquierda del tile, por lo que la fila se calcula como `(y // 8) - 1`. La columna `X` se calcula como `x // 8`.
   - **`buildingFilesAndConfig()` (`Builder.py`)**:
     - Prepara memoria, mapas binarios, pantallas de carga, bancos de memoria 128K, sprites y paletas.
   - **`compilingGame()`**:
     - Compila `src/boriel/main.bas` usando `zxbc` (Boriel ZX Basic Compiler) produciendo `output/main.bin`.
   - **`tapsBuild()`**:
     - Empaqueta los binarios en cintas `.tap` (`main.tap`, `hud.tap`, etc.) y crea la cinta final unificada.

---

## 3. Subsistema de HUD (Marcador)

### Ubicación y Diseño
- Archivo de mapa: `assets/screens/hud.tmx`
- Imagen de fondo: `assets/screens/hud.png` (256x192 píxeles) / `hud.scr`
- Tileset de objetos del HUD: `assets/screens/hud-tileset.png` (tiles 8x8 con iconos de vidas, munición, llaves, puntuación, ítems, mensajes, fuel, temporizador y stage).

### Reglas Críticas de Renderizado en Boriel (`src/boriel/functions.bas`)
1. **Alineación a la Izquierda (`PrintPadded`)**:
   - En `hud.tmx`, el usuario sitúa el tile del objeto indicando la posición exacta donde debe empezar el elemento.
   - `PrintPadded(value, padLength, color, x, y)` **DEBE imprimir los dígitos alineados a la izquierda**, empezando en la columna `X`, y rellenar con espacios `' '` a la derecha hasta completar `padLength`.
   - **PROHIBIDO alinear con espacios a la izquierda en `PrintPadded`**: Si un número de 1 dígito se alinea a la derecha rellenando con espacios por la izquierda (como en números formateados estándar), el dígito aparecerá desplazado 8 píxeles (1 carácter) a la derecha respecto a donde el usuario colocó el objeto en Tiled.
2. **Números con Ceros a la Izquierda (`PrintZeroPadded`)**:
   - Usado para puntuaciones de longitud fija (ej. 5 dígitos para Score / HiScore: `00150`).
   - Imprime siempre `padLength` dígitos rellenando con `'0'` desde la columna `X` hasta `X + padLength - 1`.
3. **Impresión Rápida de Caracteres (`PrintChar` / `PRINT_CHAR` en `GuSprites.zxbas`)**:
   - Toma coordenadas directas en caracteres de Spectrum: `X` de 0 a 31 y `Y` de 0 a 23.
   - `x = 0` corresponde a la columna 0 (primer carácter de la izquierda). No añade ningún offset arbitrario.
4. **Impresión de Cadenas (`PrintString` en `GuSprites.zxbas`)**:
   - Imprime los caracteres de la cadena recorriendo de `0` a `len - 1` en la posición `X + offset`.

---

## 4. Guía de Interacción y Comportamiento para Agentes

1. **Documentar Absolutamente Todo**:
   - Todo cambio de lógica, adición o modificación de funciones debe explicarse con claridad en los mensajes y actualizarse en este documento si afecta a la arquitectura o a reglas críticas.
2. **No Dejar Tareas Fantasma ni Bloqueos**:
   - No ejecutar comandos pesados o búsquedas recursivas completas de disco que bloqueen la consola indefinidamente.
   - Cancelar y limpiar cualquier proceso en background si ya no es necesario.
3. **Limpieza Rigurosa**:
   - Cualquier archivo de prueba o scratch (`scratch/`, `*.asm`, archivos temporales) creado durante el análisis debe ser eliminado inmediatamente al terminar.
   - El estado de `git status` debe quedar limpio tras cada intervención, salvo los cambios solicitados por el usuario.
4. **Validación del Entorno**:
   - Usar siempre el compilador y python del entorno virtual (`venv/Scripts/python.exe`, `venv/Scripts/zxbc.exe`).

---

## 5. Menú y Redefinición de Teclas en 128K (Banco 7)

### Motivación y Arquitectura
Para liberar memoria crítica en el **Banco 0** ($C000) y evitar restricciones de espacio en el ejecutable principal (`main.bin`), el menú principal y la pantalla de redefinición de teclas se compilan como un binario independiente (`src/boriel/menu128.bas` -> `output/menu.bin`) y se alojan en el **Banco 7** a partir de la dirección `$C000` (49152).

### Distribución de Memoria en el Banco 7 ($C000 - $FFFF):
- `$C000` - `$CFFF` (~4 KB): Código y datos del menú y redefinición (`menu.bin`).
- `$D000` - `$DFFF` (~4 KB): Textos y diálogos del juego (`texts.bin`), si `TEXTS_ENABLED` está activo.
- `$E000` - `$EFFF`: Buffer temporal de pantalla (`BUFFER_ADDR` para diálogos de texto).
- `$FFF0` - `$FFFF` (16 bytes): Zona de comunicación entre `main.bin` y `menu128.bas`.

### Comunicación entre `main.bin` y `menu128.bas`:
Al llamar al menú desde `screensFlow.bas`:
1. `main.bin` escribe en las posiciones de control del Banco 7:
   - `65520` (Uinteger): Puntero al array de teclas (`@keyArray(0)`).
   - `65522` (Ubyte): Disponibilidad de interfaz Kempston (`kempstonInterfaceAvailable`).
   - `65523` (Uinteger): Puntuación máxima (`hiScore`).
2. Conmuta con `SetBank(7)` y ejecuta `call 49152`.
3. `menu128.bas` atiende los presets de control:
   - Tecla 1: Teclado (QAOP + Espacio por defecto, o teclas personalizadas).
   - Tecla 2 / Disparo Kempston: Kempston Joystick.
   - Tecla 3: Sinclair Joystick (6, 7, 9, 8, 0).
   - Tecla 4: Redefinición interactiva tecla por tecla (Izquierda, Derecha, Arriba, Abajo, Disparo). Muestra un indicador `?` mientras espera la pulsación y, al pulsar, decodifica el scancode Z80 con `PrintKeyName()` imprimiendo el nombre textual de la tecla en verde ("SPACE", "ENTER", "CAPS", "SYM", o la letra/número correspondiente) sin iconos superfluos.
4. `menu128.bas` escribe el código de resultado en `65525` (1 = Teclado, 2 = Kempston, 0 = Teclas redefinidas / redibujar menú).
5. `main.bin` restaura `SetBank(0)` y lee el resultado:
   - Si el resultado es 0, el bucle repite (restaura pantalla de título y vuelve a invocar el menú).
   - Si el resultado es 1 o 2, inicia la partida con `playGame()`.

### Modo 48K:
En modo 48K (`#ifndef ENABLED_128k`), el menú básico y la redefinición se mantienen dentro de `screensFlow.bas` en el banco principal sin afectarle los cambios de 128K.

### Reglas Críticas de `menu128.bas` y Empaquetado de Cinta:
1. **Punto de Entrada en `menu128.bas`**:
   - Al compilar con origen en 49152 (`-S 49152`), el archivo debe iniciar obligatoriamente con un salto explícito `Goto startMenu` tras las declaraciones globales para saltar sobre las subrutinas y bloques `asm`.
   - Al finalizar el bucle del menú (`Exit Do`), el programa debe terminar simplemente alcanzando el final del código BASIC (sin incluir un `ret` en ensamblador a mano). De este modo, el runtime de Boriel ejecuta automáticamente `.core.__END_PROGRAM`, restaurando el puntero de pila (`SP`) desde `__CALL_BACK__`, recuperando los registros salvados (`HL'`, `IY`, `IX`), habilitando interrupciones (`ei`) y ejecutando el `ret` que devuelve el control con la pila balanceada a `screensFlow.bas`. (Un `ret` manual desbalanceaba la pila al saltarse el desapilado de `IX`, `IY` y `HL'`, provocando un cuelgue al seleccionar una opción).
2. **Sincronización de Bloques TAP**:
   - La lista de bloques empaquetados en `src/build.py` (`tapsBuild`) debe coincidir de forma estricta con la secuencia de órdenes `load ""` de `src/boriel/dataLoader.bas`.
   - Para pantallas opcionales (`intro.tap`, `gameover.tap`), debe comprobarse la condición `screenExists()` (que define `INTRO_SCREEN_ENABLED` / `GAMEOVER_SCREEN_ENABLED`) en lugar de únicamente la presencia de archivos temporales en disco.

---

## 6. Tiles Rompibles y Ataque con Espada (`checkSwordBreakableTiles` / `SetTileChecked`)

### Causa del Bug ("Tile en blanco que no desaparece y se redibuja al pasar por encima")
Cuando el jugador golpea un tile rompible con la espada mientras salta o se mueve:
1. **Conflicto de Buffer de Sprites (`SetTile` vs `SetTileChecked`)**:
   - `GuSprites` gestiona el borrado y restauración de fondo mediante dos listas alternas: `CURRENT_DRAW_OPS` y `CURRENT_CLEAR_OPS`.
   - Cuando la espada se dibuja (`Draw1x1Sprite`), `GuSprites` cachea en una operación de borrado (`CLEAR_OP`) la dirección gráfica del tile que estaba debajo en ese momento (el tile rompible).
   - Si en el siguiente frame la espada destruye el tile y se utilizaba `SetTile(0, BACKGROUND_ATTRIBUTE, col, lin)`, `SetTile` actualizaba directamente la memoria de pantalla (`$4000`) y `TILE_MAP`, **sin actualizar las operaciones pendientes en `CURRENT_DRAW_OPS`**.
   - En consecuencia, al llamar a `RenderFrame()`, el runtime ejecutaba la operación de restauración pendiente del frame previo, **volviendo a estampar el gráfico del tile rompible sobre la pantalla** (o dejando artefactos en blanco). En cambio, en `TILE_MAP` el tile ya valía 0, por lo que el jugador podía atravesarlo y, al caminar sobre él, el sprite del protagonista refrescaba el fondo con el valor 0 de `TILE_MAP`, haciendo que el tile "fantasma" desapareciera o se redibujara.
   - **Solución**: Usar obligatoriamente `SetTileChecked(0, BACKGROUND_ATTRIBUTE, col, lin)` en `breakTileAt`, `removeTilesFromScreen` y `replaceTileWithBackground`. `SetTileChecked` comprueba `CURRENT_DRAW_MAP` y, si hay una operación pendiente sobre esa celda, redirige su puntero de restauración a tile 0 (vacío) evitando que se sobreescriba el fondo.

2. **Cálculo de Coordenadas y Bounding Box de la Espada al Saltar**:
   - El sprite de la espada es de 1x1 caracteres (8x8 píxeles = 2 unidades de medio carácter en X y 2 unidades en Y).
   - Se dibuja en `(swordX, protaY + 1)`.
   - Cuando el protagonista está saltando o cayendo, `protaY` o `swordX` adoptan valores impares. Un sprite desplazado 4 píxeles abarca hasta 2 columnas (`col1 = swordX >> 1` y `col2 = (swordX + 1) >> 1`) y 2 filas (`lin1 = (protaY + 1) >> 1` y `lin2 = (protaY + 2) >> 1`).
   - La implementación anterior solo evaluaba `col = swordX >> 1` y las filas `protaY >> 1` (que cuando `protaY` era impar apuntaba a una fila **por encima** de la espada) y `(protaY + 2) >> 1`, ignorando la segunda columna y la fila real del impacto.
   - **Solución**: En `checkSwordBreakableTiles()` (`protaMovement.bas`), se calculan con precisión `col1`, `col2`, `lin1` y `lin2` basados en la posición real de la espada `(swordX, protaY + 1)`, testeando y rompiendo todas las celdas cubiertas por el sprite en cualquier fase del salto.

---

## 7. Optimización de Acceso a Arrays Unidimensionales (gB, gUB, gI, gUI, sB, sI)

### Motivación
En Boriel ZX Basic, el indexado estándar de arrays (`Array(i)`) genera llamadas internas al runtime (`__ARRAY`, `__ARRAY_PTR`) que realizan validaciones de dimensiones y límites. En bucles críticos de juego por frame (detección de colisiones, bucle de enemigos, comprobaciones de salto y teclado), esto consume ciclos de reloj y uso de pila en el Z80.

### Macros de Acceso Directo por Puntero (`src/boriel/definitions.bas`)
Aprovechando `arrayBasePtr(Array)` (que obtiene la dirección base de los datos saltando la cabecera del array: `PEEK(Uinteger, @x + 2)`), se definen:
- **`gB(Array, i)`**: Lectura con `PEEK(Byte, ...)` para arrays de 1 byte con signo (`Byte`).
- **`gUB(Array, i)`**: Lectura con `PEEK(UByte, ...)` para arrays de 1 byte sin signo (`UByte`).
- **`gI(Array, i)`**: Lectura con `PEEK(Integer, ...)` desplazando el índice `i << 1` para arrays de 16 bits con signo (`Integer`).
- **`gUI(Array, i)`**: Lectura con `PEEK(UInteger, ...)` desplazando el índice `i << 1` para arrays de 16 bits sin signo (`UInteger`).
- **`sB(Array, i, v)`**: Escritura con `POKE Byte ...` para elementos de 1 byte.
- **`sI(Array, i, v)`**: Escritura con `POKE Integer ...` para elementos de 2 bytes (desplazamiento `i << 1`).

### Alcance de la Sustitución
Se han migrado todos los accesos a arrays unidimensionales en:
- `bullet.bas`: `screensWon` (`gUB`, `sB`).
- `draw.bas`: `screensWon`, `attrSet`, `brokenTiles` (1D), `decompressedMap` (`gUB`).
- `enemies.bas`: `enemiesPerScreen`, `screensWon`, `resetReturnMovement` (`gUB`, `sB`).
- `enemies/enemiesShared.bas`: `enemiesPerScreen`, `skipMove`, `currentEnemyFrame`, `resetReturnMovement` (`gUB`, `sB`).
- `functions.bas`: `enemiesPerScreen`, `attrSet`, `brokenTiles` (1D) (`gUB`, `sB`).
- `protaMovement.bas`: `jumpArray` (`gB`), `keyArray` (`gUI`), `attrSet` (`gUB`).
- `screensFlow.bas`: `keyArray` (`gUI`, `sI`), `enemiesInScreenOffsets`, `screensOffsets` (`gUI`), `skipMove`, `currentEnemyFrame`, `resetReturnMovement`, `screensWon`, `brokenTiles` (1D), `musicPerScreenArray` (`gUB`, `sB`).

---

## 8. Optimización de Espacio: Eliminación del Runtime de Pantalla Sinclair (CLS, INK, PAPER, FLASH)

### Motivación
En el modelo ZX Spectrum 128K, el ejecutable principal `main.bin` reside en el Banco 0 ($5E38) y finalizaba peligrosamente cerca del límite $C000 (49152), dejando apenas ~250 bytes libres.
El uso de sentencias Sinclair como `CLS`, `INK`, `PAPER`, `FLASH` y `BRIGHT` en el código BASIC forzaba al compilador `zxbc` a enlazar librerías completas de la ROM Sinclair (`.core.CLS`, `.core.INK`, `.core.PAPER`, `.core.FLASH`, etc.), consumiendo cientos de bytes de memoria crítica.

### Solución Implementada
1. **Subrutina en Ensamblador `clsCustom(attr)`**:
   Se implementó `Sub fastcall clsCustom(attr As Ubyte)` en `functions.bas` y `menu128.bas`. Utiliza dos bloques `LDIR` de alta velocidad para limpiar los 6144 bytes de bitmap ($4000) a 0 y los 768 bytes de atributos ($5800) al atributo deseado (por defecto 7: blanco sobre negro, o el que se pase en el registro `A`).
2. **Reemplazo de sentencias Sinclair**:
   - `screensFlow.bas`: sustitución de `Ink 7: Paper 0: ...: Cls` por `clsCustom(7)`.
   - `passwordScreen()` y `redefineKeys()`: sustitución de `Cls` por `clsCustom(7)`.
   - `Flash 1` / `Flash 0` en pantalla intermedia: sustituido por el pase directo del atributo con flash (`135 = 128 + 7`) en `PrintString`.
   - Eliminación de llamadas superfluas `Ink ...: Paper ...` que no tenían efecto visual debido a que `PrintString` y `PrintPadded` aplican los atributos explícitamente.
3. **Resultado**:
   Se eliminaron completamente del binario `.core.CLS`, `.core.INK`, `.core.PAPER`, `.core.FLASH` y `.core.__SET_FLASH`, liberando espacio inmediato en el Banco 0 (`main.bin` se redujo de `$BF00` a `$BE4A`).

---

## 9. Optimización de Espacio y Velocidad: Unificación de Colisiones 2x2 (CheckCollision2x2)

### Motivación
Las funciones de detección de colisión de bounding box de 2x2 caracteres (`CheckCollisionSolid`, `CheckCollisionDamage` y `CheckCollisionLadder`) repetían de forma exacta la lógica de comprobación de 4 a 9 celdas (`col`, `lin`, offsets pares/impares), ocupando cerca de 1 KB de código duplicado en el Banco 0. Además, `isDamageTileByColLin` recorría la lista de tiles dañinos incluso en celdas vacías (`tile = 0`).

### Solución Implementada
1. **Función Centralizada de Bounding Box `CheckCollision2x2(x, y, checkType)`**:
   Se unificó el cálculo de coordenadas de colisión 2x2 en una única rutina en `src/boriel/functions.bas`, recibiendo el tipo de comprobación (`0 = Sólido`, `1 = Daño`, `2 = Escalera`).
2. **Evaluación Eficiente de Tiles `checkTileByType(col, lin, checkType)`**:
   - Lee el tile con `GetTile(col, lin)`.
   - Si `tile = 0` (aire/vacío), retorna 0 de inmediato, evitando cálculos y lecturas innecesarias en el 95% de los casos.
   - Aplica la regla correspondiente según `checkType` (sólidos `1..63` y tiles rompibles por toque, tiles de daño de `damageTiles`, o escaleras `70..73`).
3. **Compatibilidad Transparente por Macros**:
   Se definieron `#define CheckCollisionSolid(x, y) CheckCollision2x2(x, y, 0)`, `#define CheckCollisionDamage(x, y) CheckCollision2x2(x, y, 1)` y `#define CheckCollisionLadder(x, y) CheckCollision2x2(x, y, 2)`, manteniendo intactos todos los puntos de llamada del proyecto sin tocar código en `protaMovement.bas`, `enemies.bas` o `screensFlow.bas`.
4. **Resultado**:
   - Reducción de **620 bytes** adicionales en `main.bin` (de `$BE4A` a `$BBDE`).
   - El espacio libre en el Banco 0 antes del límite `$C000` (49152) aumentó de ~250 bytes a más de **1.050 bytes libres**.

---

## 10. Optimización de Espacio y Rendimiento: Cadenas, Caracteres y Reducción del Heap

### Motivación
En Boriel ZX Basic, el paso de parámetros por valor de tipo `String` y el troceado o conversión de caracteres mediante sentencias BASIC estándar (`texto(n)`, `Chr$(...)`) fuerzan la inclusión de librerías dinámicas del runtime (`.core.CHR`, `__MEM_ALLOC`, `__MEM_FREE`, `__LOADSTR`, `__STRLEN`, `__MEMCPY`). Cada troceado `texto(n)` realiza una asignación en el heap por carácter, lo que resulta lento e intensivo en memoria. Además, la función `printMessage` generaba copias duplicadas en el heap al invocarla con constantes y volverlas a copiar al llamar a `PrintString`.

### Solución Implementada
1. **Eliminación de `Chr$` en favor de `PrintChar` (`showTextDialog`)**:
   - En `showTextDialog` (`functions.bas`), se sustituyó `PrintString(Chr$(PEEK(textPtr)), ...)` por `PrintChar(PEEK(textPtr), ...)`, y `PrintString(" ", ...)` por `PrintChar(32, ...)`.
   - Esto eliminó completamente la librería `.core.CHR` y `__CHR_END` del binario compilado.
2. **Acceso Directo por Puntero en `doubleSizeTexto`**:
   - En lugar de `c = CODE texto(n)` (que reservaba y liberaba memoria en el heap por cada carácter), se lee directamente el código ASCII desde la memoria `c = PEEK(charAddr + n)` utilizando el puntero base `PEEK(UInteger, @texto) + 2`.
   - Se extrajo el cálculo de `charFontBase = PEEK(UInteger, 23606)` fuera del bucle `FOR`.
3. **Macro `printMessage`**:
   - Se sustituyó la subrutina `printMessage` por una macro directa que llama a `PrintString` con las coordenadas del HUD, evitando la creación de variables y copias intermedias de cadenas en el heap.
4. **Impresión de Caracteres Sueltos (`screensFlow.bas`) y Salvaguarda en `PrintString`**:
   - En `passwordScreen` y `redefineKeys`, los caracteres únicos (`*`, `<`, `>`, `^`, `v`) se migraron a llamadas directas `PrintChar` con sus respectivos códigos ASCII (42, 60, 62, 94, 118).
   - En `PrintString` (`src/boriel/lib/GuSprites.zxbas`), se añadió la salvaguarda `If tmpVal = 0 Then Return` para prevenir desbordamientos por debajo (`0 - 1 = 255`) al recibir cadenas vacías.
5. **Resultado**:
   - Reducción adicional de **217 bytes** en `main.bin` (de `$BBDE` a `$BB05`).
   - El espacio libre antes del límite `$C000` (49152) alcanza **1.275 bytes libres**.
   - Se redujo drásticamente la actividad sobre el heap en tiempo de ejecución.

---

## 11. Optimización de Velocidad y Espacio: Eliminación de Lecturas Redundantes de Teclado y Kempston

### Motivación
En cada frame de juego, el teclado se consultaba repetidamente a través de llamadas a `MultiKeys(gUI(keyArray, ...))` e instrucciones `IN A, (C)` del Z80:
1. En `protaMovement`: 3 lecturas redundantes para comprobar si se soltó la tecla (salto, disparo o espada) para flags de tecla no pulsada (`noKeyPressedFor...`).
2. En `keyboardListen`: 5 lecturas para ejecutar las acciones (`LEFT`, `RIGHT`, `UP`, `DOWN`, `FIRE`).
3. En `keyboardListen`: 5 lecturas más consecutivas para evaluar si ninguna tecla estaba pulsada (para el contador de Idle).
4. En `keyboardListen`: 4 lecturas más para evaluar si no había direcciones pulsadas (para resetear el sprite al primer frame).
En total se ejecutaban hasta **17 lecturas de teclado por frame**, lo que consumía cientos de ciclos de CPU Z80 leyendo puertos y accediendo a `keyArray`.

### Solución Implementada
1. **Captura Única por Frame**:
   - En `keyboardListen()` (`protaMovement.bas`), se lee cada una de las 5 teclas exactamente una vez en variables locales (`kLeft`, `kRight`, `kUp`, `kDown`, `kFire`).
   - Para Kempston Joystick, se lee el puerto 31 una única vez en `n = In(31)`.
2. **Evaluación de Flags y Acciones con Bits**:
   - Las comprobaciones de tecla soltada (`noKeyPressedForSword`, `noKeyPressedForShoot`, `noKeyPressedForJump`) se integraron en `keyboardListen()` evaluando directamente el estado ya leído (`kDown = 0`, `kFire = 0`, `kUp = 0`), eliminando los bloques duplicados en `protaMovement()`.
   - Se sintetizan `anyDir = kLeft Or kRight Or kUp Or kDown` y `anyKey = anyDir Or kFire` mediante operaciones de bits rápidas, evitando llamar a `MultiKeys` para los chequeos de reposo e Idle.
3. **Resultado**:
   - Reducción de 17 llamadas a solo **5 lecturas de teclado (o 1 lectura de puerto para Kempston)** por frame.
   - Reducción adicional de **152 bytes** de código en `main.bin` (de `$BB05` a `$BA6D`).
   - El espacio libre en el Banco 0 antes del límite `$C000` (49152) aumenta a **1.427 bytes libres**.

---

## 12. Optimización de Velocidad: Sustitución de MOD por Operaciones a Nivel de Bits y Temporizadores Delta

### Motivación
En Boriel ZX Basic, el operador `MOD` entre números enteros de 16 bits (`framec Mod 2` o `framec Mod 50`) invoca la rutina de división de 16 bits `.core.__MODU16`, la cual consume entre 150 y 200 ciclos de reloj T-states:
1. **En la rutina de interrupciones IM2 (`VortexTracker_NextNote()`)**:
   Se invoca 50 veces por segundo (cada 20 ms). Ejecutar una división de 16 bits (`framec Mod 2`) en una rutina de servicio de interrupción (ISR) penaliza el tiempo de CPU disponible para el juego principal en cada barrido de pantalla.
2. **En el bucle de pantalla intermedia (`animateProtaForIntermediateScreen()`)**:
   Un bucle cerrado ejecutaba `framec Mod 50 = 0` en cada iteración, realizando divisiones continuas.

### Solución Implementada
1. **Reemplazo por Máscara de Bits en IM2 (`128/vortexTracker.bas`)**:
   - Se sustituyó `If framec Mod 2 = 0 Then` por `If (framec bAND 1) = 0 Then`.
   - La comprobación pasa de una división por software de ~180 T-states a una simple operación `AND 1` de 7 T-states.
2. **Reemplazo por Temporizador Delta en Pantalla Intermedia (`screensFlow.bas`)**:
   - Se sustituyó `If framec mod 50 = 0 Then` por `If framec - lastIntermediateFrame >= 50 Then`, actualizando `lastIntermediateFrame = framec`.
   - Se elimina la división periódica y se alinea con el patrón delta `framec - lastFrame >= PERIOD` usado en el resto del motor (`lastFrameTiles`, `lastFrameBeep`).
3. **Resultado**:
   - Eliminación de la llamada a `__MODU16` durante la interrupción IM2 (ahorro crítico de ~170 T-states cada 20 ms en modo `HURRY_UP_SECONDS`).
   - Animación de personaje fluida sin divisiones en bucles rápidos.

---

## 13. Optimización de Velocidad y Espacio: Eliminación del Array y Rutina de `skipMove`

### Motivación
En cada frame de juego, el bucle principal invocaba obligatoriamente `calculateIfSkipMovementBySpeed()`, la cual ejecutaba de 3 a 6 escrituras en memoria mediante `sB(skipMove, ...)` para precalcular si los enemigos con velocidad 0, 1 o 2 debían omitir su movimiento. Posteriormente, en el bucle de enemigos, se volvía a leer `gUB(skipMove, enemySpeed)`.
Esto consumía ciclos de reloj en llamadas y escrituras de arrays por frame, además de reservar memoria RAM estática para el array `skipMove(2)` y compilar la subrutina entera.

### Solución Implementada
1. **Evaluación Directa por Bits en `checkShouldSkipMoveBySpeed` (`enemiesShared.bas`)**:
   - Se transformó la comprobación en `Function checkShouldSkipMoveBySpeed(enemySpeed As Ubyte) As Ubyte`.
   - Se evalúa directamente el bit correspondiente de `mainLoopCounter`:
     - Velocidad 3 (o >= 3): retorna 0 (sin pausa, se mueve en el 100% de los frames).
     - Velocidad 2: `(mainLoopCounter bAnd 1) <> 0` (omite 1 de cada 2 frames, 50% de velocidad con pausa corta).
     - Velocidad 1: `(mainLoopCounter bAnd 3) <> 0` (omite 3 de cada 4 frames, 25% de velocidad con más pausa).
     - Velocidad 0: `(mainLoopCounter bAnd 7) <> 0` (omite 7 de cada 8 frames, 12.5% de velocidad con máxima pausa).
   - *Nota crítica sobre `Fastcall`*: No debe utilizarse `Fastcall` en funciones de Boriel ZX Basic que referencian sus parámetros en expresiones BASIC sin ensamblador puro, debido a un fallo en el generador de código de `zxbc` donde el parámetro se pasa en el registro `A` pero el cuerpo intenta leerlo desde la pila en `(ix+5)` (el cual no está inicializado al no haber prólogo `push ix`), leyendo basura de memoria y corrompiendo la velocidad.
2. **Eliminación de la Subrutina y del Array**:
   - Se eliminó la llamada `calculateIfSkipMovementBySpeed()` en el bucle principal de `playGame()` en `screensFlow.bas`.
   - Se eliminó la definición de `Sub calculateIfSkipMovementBySpeed()` en `screensFlow.bas`.
   - Se eliminó la declaración `Dim skipMove(2)` en `definitions.bas`.
3. **Resultado**:
   - Ahorro de más de **300 bytes** en `main.bin` (de `$BA6D` a `$B93F`).
   - El espacio libre en el Banco 0 antes del límite `$C000` (49152) se sitúa en **1.729 bytes libres**.
   - Cero escrituras en memoria por frame para el cálculo de velocidades y comportamiento de pausas idéntico al original.

---

## 14. Optimización de Velocidad y Espacio: Rutinas Críticas (sgn8 ASM Fastcall, Inlining de incrementScore y Guardas de Colisión)

### Motivación
1. **`sgn8` y llamadas a `Sgn`**: Se utilizaban múltiples comparaciones y marcos de pila en BASIC para determinar el signo de un byte, e incluso una llamada al `Sgn` genérico del runtime en `enemies.bas:79`.
2. **`checkProtaAndBulletCollision`**: En cada frame y para cada enemigo activo, se invocaban `checkBulletProtaCollision` y `checkSwordEnemyCollision` apilando 12 parámetros en la pila, a pesar de que el 95% del tiempo no había proyectiles ni ataque de espada activos.
3. **Inversión de dirección con `* -1`**: Multiplicar por -1 invocaba rutinas de multiplicación matemática de 16 bits en el Z80 (`__FMUL16`) en lugar de usar la instrucción de negación nativa del procesador (`NEG`).
4. **`incrementScore`**: Subrutina de llamada frecuente al recoger ítems o sumar puntos que creaba marcos de pila y paso de parámetros.

### Solución Implementada
1. **`sgn8` en Ensamblador Puro `Fastcall` (`functions.bas`)**:
   - Implementado en Z80 ASM nativo con instrucción `or a`, retornando 0 si `Z`, 1 si positivo y -1 si negativo.
   - Pasa el parámetro en el registro `A` y retorna en `A` sin tocar la pila ni usar `IX`. Ocupa solo 8 bytes de código frente a los 43 bytes de la versión BASIC.
   - Se reemplazó la llamada residual a `Sgn` en `enemies.bas:79` por `sgn8`.
2. **Guardas Previas en Colisiones de Proyectil y Espada (`enemiesShared.bas`)**:
   - Se añadieron `If bulletPositionX Then` e `If swordTimer Then` antes de las llamadas a `checkBulletProtaCollision` y `checkSwordEnemyCollision`.
   - Se eliminan 2 llamadas a función y 12 pushes a la pila por cada enemigo en pantalla en casi todos los frames.
3. **Negación Unaria Nativa (`enemiesShared.bas`)**:
   - Se reemplazó `* -1` por `-enemyHorizontalDirection` y `-enemyVerticalDirection`, generando instrucciones `NEG` directas de 1 solo ciclo de reloj.
4. **Inlining de `incrementScore` (`functions.bas`)**:
   - Convertido a macro `#define incrementScore(amount) score = score + (amount) : If score > hiScore Then hiScore = score`, eliminando el salto de subrutina.
5. **Resultado**:
   - Reducción adicional de **51 bytes** en `main.bin` (de `$B93F` a `$B90C`).
   - El espacio libre en el Banco 0 antes de `$C000` (49152) aumenta a **1.780 bytes libres** (frente a los ~250 bytes originales del proyecto).
   - Ahorro masivo de ciclos de CPU en el bucle principal y bucle de enemigos.

---

## 15. Mejora del Wall Jump: Deslizamiento (Wall Slide) y Cancelación de Bloqueo en Chimeneas

### Motivación y Problemas Detectados
Al intentar concatenar rebotes sucesivos de Wall Jump entre paredes cercanas (ej. chimeneas de 2 o 3 tiles de ancho), el control resultaba extremadamente tosco y difícil por tres causas principales:
1. **Bloqueo Incondicional por `wallJumpTimer` (8 frames)**:
   - Al rebotar, `wallJumpTimer = 8` forzaba el desplazamiento hacia la pared contraria.
   - En una chimenea estrecha, el personaje alcanzaba la pared opuesta en apenas 2 o 3 frames.
   - Sin embargo, mientras `wallJumpTimer > 0`, `checkDashingOrWalljumping()` devolvía 1, **bloqueando completamente la lectura del teclado (`keyboardListen()`)**.
   - Cualquier pulsación de salto efectuada por el jugador contra la pared opuesta se ignoraba durante los 5 o 6 frames restantes. Para cuando el timer expiraba, el impulso vertical del salto había concluido y el personaje caía.
2. **Imposibilidad de Cancelar con la Cruceta (Input Override)**:
   - Si el jugador saltaba de una pared hacia otra y pulsaba instintivamente la dirección contraria para preparar el siguiente rebote, el timer ignoraba la cruceta y mantenía el empuje forzado.
3. **Caída Ultrarrápida sin Deslizamiento por la Pared (Wall Slide)**:
   - Al entrar en caída (`gravity()`), el protagonista caía a 2 unidades (8 píxeles por frame) sin importar si estaba rozando una pared vertical, dejando una ventana de reacción mínima.

### Solución Implementada
1. **Cancelación Inmediata del Timer al Contactar con la Pared Opuesta (`checkDashingOrWalljumping`)**:
   - En `src/boriel/protaMovement.bas`, se evalúa `canMoveLeft()` / `canMoveRight()` antes de aplicar el desplazamiento.
   - Si el personaje impacta contra la pared contraria (`Not canMoveLeft()` o `Not canMoveRight()`):
     - Se cancela inmediatamente `wallJumpTimer = 0`.
     - Se habilita el flag de salto `noKeyPressedForJump = 1` para permitir el re-trigger del siguiente salto.
     - Se retorna 0, devolviendo el control del teclado en ese mismo frame.
2. **Cancelación por Pulsación Contradireccional (Override Manual)**:
   - Si mientras el timer empuja al personaje en una dirección el jugador presiona activamente la dirección opuesta, el timer se cancela inmediatamente devolviendo el control manual.
3. **Deslizamiento Suave por Pared (Wall Slide en `gravity`)**:
   - En `gravity()` (`protaMovement.bas`), si el jugador está en el aire cayendo y roza una pared sólida (`CheckCollisionSolid(protaX + 1, protaY)` o `CheckCollisionSolid(protaX - 1, protaY)`):
     - La caída se reduce a la mitad de velocidad: `saveProta(protaY + 1, ...)` (4 píxeles por frame en vez de 8).
     - Proporciona una ventana de tiempo cómoda y fluida para ejecutar el siguiente rebote.
4. **Prevención de Escalada en un Solo Muro (`lastWallJumpSide`)**:
   - Con la cancelación rápida de timer, el jugador podía rebotar contra un muro, pulsar inmediatamente hacia el mismo muro en el aire y volver a saltar sobre él en bucle infinito.
   - Se añadió la variable `lastWallJumpSide` en `definitions.bas` (`1` = salto desde muro derecho, `2` = salto desde muro izquierdo, `0` = suelo/escalera).
   - En `jump()` (`functions.bas`), solo se permite saltar si el lado actual es distinto de `lastWallJumpSide`.
   - Al tocar el suelo (`landed = 1`) o agarrar una escalera, `lastWallJumpSide` se resetea a 0. Esto permite escalar chimeneas alternando paredes izquierda/derecha de forma ilimitada y fluida, pero imposibilita trepar indefinidamente por una única pared.
5. **Ajuste del Timer Base**:
   - Se ajustó el tiempo base de despegue de 8 a 6 frames en `jump()` (`functions.bas`), proporcionando una parábola más ágil y limpia.
6. **Resultado**:
   - Concatenación de Wall Jumps en chimeneas inmediata, suave y altamente reactiva.
   - Imposibilidad de escalar una pared vertical solitaria.
   - Espacio libre en el Banco 0: **1.492 bytes libres** antes de `$C000` (`main.bin` finaliza en `$BA2C`).

---

## 16. Feedback de Wall Jump: Sonido de Impulso (BeepFX_Play(2)) y Descarte de Efectos Gráficos

### Motivación y Decisión de Diseño
Inicialmente se exploraron dos alternativas para el feedback visual en el rebote de pared:
1. Un sistema de partículas dinámico (tipo MPAGD / *Cafetonic*) o sprites 1x1: requería aumentar buffers de sprites en `GuSprites`, consumiendo cientos de bytes críticos de memoria y operaciones de restauración por frame.
2. Un sprite 2x2 temporal de impacto/explosión (`BURST_SPRITE_ID = 16`): aunque funcional, la adición de llamadas a `Draw2x2Sprite`, comprobaciones de temporizador y coordenadas consumía **363 bytes** en `main.bin`, un coste desproporcionado para un efecto secundario en un sistema con memoria ajustada.

Se optó por una solución óptima y minimalista: **feedback puramente sonoro**.

### Implementación
- En `jump()` (`src/boriel/functions.bas`), al confirmarse el rebote contra el muro izquierdo o derecho en un Wall Jump válido:
  - Se ejecuta directamente `BeepFX_Play(2)` (el mismo sonido de impulso/fuerza utilizado en el Dash).
- Se descartaron por completo todas las variables de temporización (`wallJumpBurstTimer`, etc.) y llamadas a dibujo de sprites.

### Resultado y Memoria
- El coste de `BeepFX_Play(2)` en código máquina es de únicamente **10 bytes** en total (`ld a, 2; call BeepFX_Play`).
- Se recuperaron **353 bytes** de memoria respecto a la solución con sprites.
- `main.bin` finaliza en `$BA36`, conservando **1.482 bytes libres** en el Banco 0 antes del límite crítico `$C000`.

---

## 17. Tipografía Personalizada (`assets/fonts/general.ch8`)

### Motivación y Objetivo
Permitir que el juego utilice una fuente tipográfica personalizada de 8x8 píxeles si existe el archivo binario `assets/fonts/general.ch8` (768 bytes, 96 caracteres ASCII 32 a 127). Si dicho archivo no existe, el motor retrocede de forma transparente a la tipografía estándar de la ROM del ZX Spectrum ($3D00).

### Arquitectura de Memoria
Para evitar saturar el espacio de ejecución en el Banco 0 ($5E38 - $BA51, donde reside `main.bin`), la fuente de 768 bytes se empaqueta como un recurso en `files.tap` y se aloja en el **Banco 0 paged RAM** ($C000+), donde se dispone de más de **13 KB libres**.

### Pipeline de Build (`src/builder/`)
1. **Detección (`helper.py`)**:
   - `FONTS_FOLDER = ASSETS_FOLDER / "fonts"`
   - Función de consulta `fontExists(font_name="general")` que comprueba si existe `general.ch8`.
2. **Empaquetado (`BinaryFilesToTapMerger.py`)**:
   - Si `fontExists("general")` es verdadero, `general.ch8` se añade a la lista de archivos que se concatenan en `files.bin` (`files.tap`), cargándose en memoria a partir de `INITIAL_ADDRESS` ($C000).
3. **Métricas de Memoria (`Sizes.py`, `SizesGetter.py`, `ChartGenerator.py`)**:
   - Se registró `FONT_DATA` dentro de `Sizes` y se añadió a `getKeysToMemoryBank()` para su gestión explícita.
   - En `SizesGetter`, se calcula el tamaño del fichero `general.ch8`.
   - En los informes y gráficos de memoria (`ChartGenerator`), `FONT_DATA` se refleja en el Banco 0.
4. **Generación de Configuración (`ConfigWriter.py`)**:
   - Si la fuente existe, escribe en `output/config.bas`:
     ```basic
     const FONT_DATA_ADDRESS as uinteger = <address>
     #DEFINE CUSTOM_FONT_ENABLED
     #DEFINE ROM_CHARSET <address - 256>
     ```
   - Al definir `#DEFINE ROM_CHARSET <address - 256>`, la librería `src/boriel/lib/GuSprites.zxbas` omite su valor por defecto (`3C00h`) y apunta directamente a la dirección de memoria de la fuente personalizada.

### Integración en el Motor de Juego (`src/boriel/`)
1. **Inicialización de Gráficos (`graphicsInitializer.bas`)**:
   - En `initGraphics()`, si `CUSTOM_FONT_ENABLED` está activo, se actualiza la variable del sistema de Spectrum `CHARS` (dirección 23606):
     ```basic
     #ifdef CUSTOM_FONT_ENABLED
         Poke Uinteger 23606, FONT_DATA_ADDRESS - 256
     #endif
     ```
   - Esto hace que cualquier rutina que lea `CHARS` (como `doubleSizeTexto` en `functions.bas`) utilice automáticamente los glifos de `general.ch8`.
2. **Compatibilidad con `menu128.bas`**:
   - En `src/boriel/menu128.bas`, se renombró el símbolo interno de ensamblador de `ROM_CHARSET` a `MENU_ROM_CHARSET` para evitar conflictos léxicos con la macro `#DEFINE ROM_CHARSET` exportada por `config.bas`. El menú en el Banco 7 sigue utilizando de forma segura la ROM del Spectrum sin riesgo de acceder a memoria paginada incorrecta.
3. **Diálogos de Texto (`showTextDialog` en `functions.bas`)**:
   - En modo 128K, mientras se leen textos de diálogos desde el Banco 7 (`TEXTS_BANK`), las llamadas a `PrintChar` alternan temporalmente a `SetBank(0)` para consultar los glifos de `general.ch8` y regresan a `SetBank(TEXTS_BANK)`.

### Resultado
- Si `general.ch8` está presente: el juego completo (HUD, puntuaciones, vidas, munición, textos, letreros gigantes 2x2 y diálogos) se renderiza con la nueva fuente tipográfica.
- Si `general.ch8` no existe: el juego compila y se ejecuta normalmente usando la fuente clásica de la ROM.
- Impacto en `main.bin`: Mínimo (~25 bytes de código BASIC/ASM), conservando **1.455 bytes libres** antes de `$C000`.

### Atribución y Licencia de la Fuente
- La tipografía incluida de ejemplo en `assets/fonts/general.ch8` proviene de la colección **ZX Origins font collection** de **Damien Guard (DamienG)** (https://damieng.com/zx-origins).
- Se documenta la atribución completa en `assets/fonts/README.md` y en la sección de créditos y licencias de `README.md`, respetando los términos de uso libre y no redistribución como catálogo independiente fijados por el autor.


---

## 18. Frecuencia de Animación Configurable (1 a 10) para Plataformas y Tiles (animateFrequencyPlatform / animateFrequencyTile)

### Motivación y Objetivo
Originalmente se especificaban valores en "período de frames" (`animatePeriodTile` y `animatePeriodPlatform`), lo que obligaba al usuario a calcular de cabeza los 50 Hz del Spectrum (un número más largo significaba más lentitud). Además, existían propiedades en desuso (`animatePeriodMain` y `animatePeriodEnemy`).

Se reemplazan estas propiedades por una escala intuitiva de **frecuencia de 1 a 10** en Tiled:
- **1**: Muy lenta (50 frames = 1 cambio por segundo).
- **5**: Velocidad estándar / por defecto (10 frames = 5 cambios por segundo).
- **10**: Muy rápida (2 frames = 25 cambios por segundo).
- **0**: Desactivada (sin animación).

### Limpieza de Esquema y Tooling
1. **Eliminación de Campos Obsoletos**:
   - Se eliminaron `animatePeriodMain` y `animatePeriodEnemy` de `propertytypes.json`, `maps.tiled-project`, `maps.tmx`, `launcher.py` e `iL8n`.
2. **Nuevas Propiedades de Frecuencia (1..10)**:
   - `animateFrequencyPlatform`: tipo `int`, valor por defecto `5`.
   - `animateFrequencyTile`: tipo `int`, valor por defecto `5`.
   - Definidas en `src/propertytypes.json` y `assets/map/maps.tiled-project`.
3. **Conversión en Pipeline (`src/bin/tiled-build.py`)**:
   - `frequencyToPeriod(freq)` normaliza de la escala 1..10 a frames de Spectrum PAL:
     {1: 50, 2: 25, 3: 17, 4: 13, 5: 10, 6: 8, 7: 6, 8: 5, 9: 4, 10: 2}.
   - Si `freq == 0`, retorna 0 (desactivado).
   - Mantiene compatibilidad hacia atrás: si un mapa antiguo define `animatePeriodPlatform` ob `animatePeriodTile` con valor mayor a 10, lo respeta como período directo en frames.
   - Emite en `output/config.bas`:
     ```basic
     const ANIMATE_PERIOD_TILE as ubyte = <valor_periodo>
     #define ANIMATE_PERIOD_PLATFORM <valor_periodo>
     ```

### Implementación en el Motor de Juego (src/boriel/)
1. **Variables en Memoria Fija sin Crecimiento de BSS (definitions.bas)**:
   - Se evita cualquier operación MOD (conforme a la regla de la Sección 12).
   - Se declaran `lastFramePlatforms` y `platformFrame` mapeadas a direcciones absolutas en el buffer de impresora de Spectrum (%5B00 / 23296 - 23297):
     ```basic
     #if ANIMATE_PERIOD_PLATFORM > 0
         Dim lastFramePlatforms As Ubyte AT 23296
         Dim platformFrame As Ubyte AT 23297
     #endif
     ```
   - *(Regla crítica sobre BSS y ALIGN 256 en im2.bas)*: Declarar variables globales estándar (`Dim ... As Ubyte = 0`) añade bytes a la sección `.bss`. Al encontrarse la tabla de interrupciones de `im2.bas` alineada a 256 bytes (`ALIGN 256`), el crecimiento de apenas 2 bytes en `.bss` provocaba que la dirección previa pasara el límite de página, obligando a `ALIGN 256` a insertar un salto de relleno de 255 bytes vacíos hasta `8600`. El uso de `AT 23296` sitúa las variables fuera del segmento `.ss`, ocupando **0 bytes en BSS** y evitando por completo el relleno de 255 bytes en `im2.bas`.

2. **Evaluación Directa en Dibujado (enemiesShared.bas / saveAndDraw)**:
   - Se elimina cualquier lógica de animación en `moveEnemies()` (`enemies.bas`), manteniéndolo limpio y sin banderas globales.
   - En `saveAndDraw()`, la comprobación del período delta se realiza exclusivamente al momento de dibujar una plataforma:
     ```basic
     If isPlatform(tile) Then
         #if ANIMATE_PERIOD_PLATFORM > 0
             If framec - lastFramePlatforms >= ANIMATE_PERIOD_PLATFORM Then
                 platformFrame = platformFrame Xor 1
                 lastFramePlatforms = framec
             End If
             sB(currentEnemyFrame, enemyId, platformFrame)
         #endif
     End If
     ```
   - Si una pantalla contiene múltiples plataformas, la primera plataforma que se dibuja en el frame actual detecta que `framec - lastFramePlatforms >= ANIMATE_PERIOD_PLATFORM`, conmuta `platformFrame` y actualiza `lastFramePlatforms = framec`. Las siguientes plataformas evaluadas en ese mismo frame observan una diferencia de 0, por lo que adoptan el mismo valor de `platformFrame` de forma sincronizada sin conmutar de más.
   - Si no hay plataformas en la pantalla, el código no se ejecuta y el coste es cero.
   - Si `ANIMATE_PERIOD_PLATFORM = 0al preprocesador excluye el bloque completo a coste cero.

### Rendimiento y Memoria
- El impacto total en el binario es mínimo (~20 bytes de código), sin variables en BSS.
- Se recuperan los 255 bytes de alineación de `im2.bas`, manteniendo **13.259 bytes libres** en el Banco 0.
- Todas las plataformas y tiles animados disponen de configuración homogénea y sincronizada.
