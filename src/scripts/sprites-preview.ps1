if (-not $env:VIRTUAL_ENV) {
    Write-Host "Activando entorno virtual venv..." -ForegroundColor Yellow
    .\venv\Scripts\Activate.ps1
}

# Navegar al directorio del script
Set-Location -Path $PSScriptRoot

# Ejecutar el script de Python
py src/sprites-preview.py