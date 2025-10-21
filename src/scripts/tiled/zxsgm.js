tiled.log("Script ZXSGM started...");

function setClassByShape(obj) {
    // Sprites (shape === 0)
    if (obj.shape === 0 && (!obj.className || obj.className === "")) {
        if (obj.tile > 15) {
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
    else if (obj.shape === 5 && (!obj.className || obj.className === "")) {
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