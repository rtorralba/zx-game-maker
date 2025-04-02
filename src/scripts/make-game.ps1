$python = Get-Command py -ErrorAction SilentlyContinue

$venv = ".\venv\Scripts\Activate.ps1"

if (-not (Test-Path $venv)) {
    Write-Host "Creando entorno virtual venv..." -ForegroundColor Yellow
    py -m venv venv
}

if (-not $env:VIRTUAL_ENV) {
    Write-Host "Activando entorno virtual venv..." -ForegroundColor Yellow
    .\venv\Scripts\Activate.ps1
}

py .\build.py $args

Read-Host "Pulse una tecla para cerrar..."