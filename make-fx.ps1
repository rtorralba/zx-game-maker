$pasmo = Get-Command pasmo -ErrorAction SilentlyContinue

if ($null -eq $pasmo) {
    Write-Host "Pasmo no esta instalado. Por favor, instala Pasmo antes de continuar." -ForegroundColor Red
    Read-Host "Pulse una tecla para cerrar..."
    exit 1
}

pasmo --tap src/player.asm assetsfx/fx.tap

Write-Host "FX creado correctamente."

Read-Host "Pulse una tecla para cerrar..."