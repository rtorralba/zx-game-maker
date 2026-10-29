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

