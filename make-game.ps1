$python = Get-Command py -ErrorAction SilentlyContinue

if ($null -eq $python) {
    Write-Host "Python no esta instalado. Por favor, instala Python antes de continuar." -ForegroundColor Red
    Read-Host "Pulse una tecla para cerrar..."
    exit 1
}

$pythonVersion = $python.Version.Major + $python.Version.Minor / 100

if ($pythonVersion -lt 3.12) {
    Write-Host "La version de Python es menor que 3.12. Por favor, instala Python 3.12 o superior." -ForegroundColor Red
    Read-Host "Pulse una tecla para cerrar..."
    exit 1
}

$venv = ".\venv\Scripts\Activate.ps1"

if (-not (Test-Path $venv)) {
    Write-Host "Creando entorno virtual venv..." -ForegroundColor Yellow
    py -m venv venv
}

if (-not $env:VIRTUAL_ENV) {
    Write-Host "Activando entorno virtual venv..." -ForegroundColor Yellow
    .\venv\Scripts\Activate.ps1
}

$requerimentsFile = ".\requeriments.txt"
if (-not (Test-Path $requerimentsFile)) {
    Write-Host "No se encontró el archivo requeriments.txt" -ForegroundColor Red
    Read-Host "Pulse una tecla para cerrar..."
    exit 1
}

$requeriments = Get-Content $requerimentsFile
$installed_packages = & pip freeze
$installed_package_names = $installed_packages -replace '==.*', ''

$all_installed = $true
foreach ($requirement in $requeriments) {
    $requirement_name = $requirement -replace '==.*', ''
    if (-not ($installed_package_names -contains $requirement_name)) {
        $all_installed = $false
    }
}

if (-not $all_installed) {
    Write-Host "Instalando requerimientos..." -ForegroundColor Yellow
    pip install -r .\requeriments.txt
}

py .\build.py $args

Read-Host "Pulse una tecla para cerrar..."