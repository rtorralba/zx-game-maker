$python = Get-Command py -ErrorAction SilentlyContinue

py .\build.py $args

Read-Host "Pulse una tecla para cerrar..."