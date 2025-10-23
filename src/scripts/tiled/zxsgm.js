tiled.log("Script ZXSGM started...");

const roomWidth = 32
const roomHeight = 22
const forbiddenSprites = [1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 13, 14, 15, 17, 19, 21, 23, 25, 27, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47];

function setClassByShape(obj) {
    // Sprites (shape === 0)
    if (obj.shape === 0) {
        // Si las propiedades x o y del objeto no son multiplos de 8 poner el valor multible de 8 más proximo
        if (obj.x % 8 !== 0 || obj.y % 8 !== 0) {
            obj.x = Math.round(obj.x / 8) * 8;
            obj.y = Math.round(obj.y / 8) * 8;
        }
        if (forbiddenSprites.includes(obj.tile.id)) {
            tiled.alert("Sprite no permitido.");
            if (obj.layer && obj.layer.removeObject) {
                obj.layer.removeObject(obj);
                tiled.log("✗ Objeto eliminado: " + (obj.name || "ID:" + obj.id));
            }
            return false;
        }
        if (obj.tile.id === 0) {
            obj.className = "mainCharacter";
            tiled.log("✓ Class 'mainCharacter' assigned to sprite: " + (obj.name || "ID:" + obj.id));
            return true;
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

        if (obj.tile.class === 'animated' || obj.tile.class === 'animatedDamage') {
            tiled.log(getRoomFromTile(obj.x / 8, obj.y / 8));
            return true;
        }
    }
    // Pointers (shape === 5)
    else if (obj.shape === 5 && obj.className === "") {
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

// Evento al guardar el mapa: escanea la capa 'map' y loguea tiles animados
tiled.assetSaved.connect(function(asset) {
    tiled.log("Mapa guardado, comprobando tiles animados por room...");
    if (!asset || !asset.isTileMap) return;
    var mapLayer = getLayerByName(asset, "map");
    if (!mapLayer || !mapLayer.isTileLayer) return;
    // Leer el límite desde la propiedad personalizada del mapa
    var maxAnimated = 5;
    if (typeof asset.property === 'function') {
        var prop = asset.property('maxAnimatedTilesPerScreen');
        if (typeof prop === 'number') maxAnimated = prop;
        else if (typeof prop === 'string' && !isNaN(parseInt(prop))) maxAnimated = parseInt(prop);
    }

    tiled.log(`Límite de tiles animados por room: ${maxAnimated}`);
    // Diccionario para contar tiles animados por room (clave: "col,row")
    var animatedCountByRoom = {};
    for (var y = 0; y < mapLayer.height; y++) {
        for (var x = 0; x < mapLayer.width; x++) {
            var tile = mapLayer.tileAt(x, y);
            if (tile && (tile.className === 'animated' || tile.className === 'animated-damage')) {
                var room = getRoomFromTile(x, y);
                var key = room.col + "," + room.row;
                if (!animatedCountByRoom[key]) animatedCountByRoom[key] = 0;
                animatedCountByRoom[key]++;
            }
        }
    }
    // Mostrar el recuento y avisar si alguna room supera el límite
    for (var key in animatedCountByRoom) {
        var count = animatedCountByRoom[key];
        tiled.log(`Room ${key} tiene ${count} tiles animados (límite: ${maxAnimated}).`);
        if (count > maxAnimated) {
            tiled.alert(`La pantalla (${key}) tiene más de ${maxAnimated} tiles animados (${count})`);
        }
    }
});

function debugObject(obj) {
    tiled.log("Debugging object properties:");
    try {
        for (const [key, value] of Object.entries(obj)) {
            tiled.log(` - ${key}: ${value}`);
        }
    } catch (error) {
        tiled.log("Error debugging object:", error);
    }
}

function getRoomFromTile(x, y) {
    // x, y: coordenadas del tile (en tiles, no en píxeles)
    // roomWidth, roomHeight: tamaño de la habitación en tiles
    var roomCol = Math.floor(x / roomWidth) + 1;
    var roomRow = Math.floor(y / roomHeight) + 1;
    return { col: roomCol, row: roomRow };
}

function getLayerByName(map, name) {
    for (var i = 0; i < map.layerCount; i++) {
        var layer = map.layerAt(i);
        if (layer.name === name) return layer;
    }
    return null;
}