$filePath = "..\pasmo.exe"

if (-not (Test-Path $filePath)) {
    Write-Host "El fichero $filePath existe."
    Write-Host "Descarga de https://pasmo.speccy.org/ y pon el fichero pasmo.exe en la raiz del proyecto"
    Read-Host "Pulse una tecla para cerrar..."
    exit 1
}

.\pasmo.exe --tap ..\boriel\player.asm ..\assets\fx\fx.tap

Write-Host "FX creado correctamente."

Read-Host "Pulse una tecla para cerrar..."