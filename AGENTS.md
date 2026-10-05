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
