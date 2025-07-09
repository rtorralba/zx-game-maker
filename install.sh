#!/bin/bash

if command -v python &> /dev/null; then
    echo "Python está instalado."
else
    echo "Python no está instalado. Por favor, instala Python antes de continuar."
    read -p "Pulse una tecla para cerrar..."
    exit 1
fi

# Moverse a la carpeta src
cd "$(dirname "$0")/src" || exit 1

# Comprobar si no existe el entorno virtual
if [ ! -d "venv" ]; then
    python -m venv venv
fi

# Activar el entorno virtual
source venv/bin/activate

# Comprobar si el archivo requeriments.txt existe
if [ ! -f "requeriments.txt" ]; then
    echo "No se encontró el archivo requeriments.txt"
    read -p "Pulse una tecla para cerrar..."
    exit 1
fi

# instalar las dependencias
pip install -r requeriments.txt

rm -f venv/bin/bin2tap.py

# Remplazar la dependencia opencv-python por opencv-python-headless
pip uninstall -y opencv-python
pip install opencv-python-headless