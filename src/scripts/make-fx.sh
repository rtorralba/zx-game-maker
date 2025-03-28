#!/bin/bash

if ! command -v pasmo &> /dev/null
then
    echo "Pasmo no está instalado. Por favor, instala Pasmo antes de continuar."
    read -p "Pulse una tecla para cerrar..."
    exit 1
fi

pasmo --name "sound code" --tap player.asm ../assets/fx/fx.tap

pwd

echo "FX creado correctamente."