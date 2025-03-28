#!/bin/bash

# Activar entorno virtual si no está activado
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Activando entorno virtual venv..."
    source venv/bin/activate
fi

# Navegar al directorio del script
cd "$(dirname "$0")"

# Ejecutar el script de Python
python3 src/sprites-preview.py