/* Script para Tiled: Asigna clase automáticamente a objetos según su tipo */

tiled.log("Script ZXSGM iniciado...");

// Función para asignar clase a un objeto según su shape
function asignarClaseSegunShape(obj) {
    // Sprites (shape === 0)
    if (obj.shape === 0 && (!obj.className || obj.className === "")) {
        obj.className = "ZXSpectrumGameMakerEnemies";
        obj.setProperty("enemy", null);
        tiled.log("✓ Clase 'ZXSpectrumGameMakerEnemies' asignada al sprite: " + (obj.name || "ID:" + obj.id));
        return true;
    }
    // Punteros (shape === 5)
    else if (obj.shape === 5 && (!obj.className || obj.className === "")) {
        obj.className = "ZXSGMPointers";
        tiled.log("✓ Clase 'ZXSGMPointers' asignada al puntero: " + (obj.name || "ID:" + obj.id));
        return true;
    }
    return false;
}

// Conectar eventos del mapa
function conectarEventosMapa(map) {
    if (!map || !map.isTileMap) return;
    
    tiled.log("Conectando eventos al mapa: " + (map.fileName || "sin nombre"));
    
    // Conectar a selectedObjectsChanged
    if (map.selectedObjectsChanged && typeof map.selectedObjectsChanged.connect === 'function') {
        map.selectedObjectsChanged.connect(function() {
            var selectedObjects = map.selectedObjects;
            
            // Procesar cada objeto seleccionado
            selectedObjects.forEach(function(obj) {
                asignarClaseSegunShape(obj);
            });
        });
        tiled.log("✓ Conectado a: selectedObjectsChanged");
    }
}

// Conectar cuando cambia el asset
tiled.activeAssetChanged.connect(function(asset) {
    if (asset && asset.isTileMap) {
        conectarEventosMapa(asset);
    }
});

// Conectar al mapa actual si existe
if (tiled.activeAsset && tiled.activeAsset.isTileMap) {
    conectarEventosMapa(tiled.activeAsset);
}

tiled.log("Script ZXSGM listo. Las clases se asignarán automáticamente al seleccionar objetos.");