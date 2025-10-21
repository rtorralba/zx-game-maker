tiled.log("Script ZXSGM started...");

const forbiddenTiles = [1, 2, 3, 4, 5, 6, 7, 12, 13, 14, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47];

function setClassByShape(obj) {
    // Sprites (shape === 0)
    if (obj.shape === 0) {
        if (forbiddenTiles.includes(obj.tile.id)) {
            tiled.alert("⚠️ Sprite no permitido.");
            if (obj.layer && obj.layer.removeObject) {
                obj.layer.removeObject(obj);
                tiled.log("✗ Objeto eliminado: " + (obj.name || "ID:" + obj.id));
            }
            return false;
        }
        if (obj.tile.id > 15) {
            obj.className = "ZXSGMEnemy";
            tiled.log("✓ Class 'ZXSGMEnemy' assigned to sprite: " + (obj.name || "ID:" + obj.id));
            return true;
        }

        if (obj.tile.id === 8 || obj.tile.id === 10) {
            obj.className = "platform";
            tiled.log("✓ Class 'platform' assigned to sprite: " + (obj.name || "ID:" + obj.id));
            return true;
        }
    }
    // Pointers (shape === 5)
    else if (obj.shape === 5) {
        obj.className = "ZXSGMPointer";
        tiled.log("✓ Class 'ZXSGMPointer' assigned to pointer: " + (obj.name || "ID:" + obj.id));
        return true;
    }
    return false;
}

function connectToMapEvents(map) {
    if (!map || !map.isTileMap) return;
    // Connect to selectedObjectsChanged
    if (map.selectedObjectsChanged && typeof map.selectedObjectsChanged.connect === 'function') {
        map.selectedObjectsChanged.connect(function() {
            var selectedObjects = map.selectedObjects;
            
            selectedObjects.forEach(function(obj) {
                setClassByShape(obj);
            });
        });
    }
}

tiled.activeAssetChanged.connect(function(asset) {
    if (asset && asset.isTileMap) {
        connectToMapEvents(asset);
    }
});

if (tiled.activeAsset && tiled.activeAsset.isTileMap) {
    connectToMapEvents(tiled.activeAsset);
}

function debugObject(obj) {
    tiled.log("Debugging object properties:");
    for (const [key, value] of Object.entries(obj)) {
        tiled.log(` - ${key}: ${value}`);
    }
}