#!/bin/bash

# Crear entorno virtual si no existe
if [ ! -d "venv" ]; then
    echo "Creando entorno virtual venv..."
    python -m venv venv
fi

# Activar entorno virtual si no está activado
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Activando entorno virtual venv..."
    source venv/bin/activate
fi

python ./build.py $@