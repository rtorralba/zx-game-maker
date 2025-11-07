tiled.log("Script ZXSGM started...");

const roomWidth = 32
const roomHeight = 22
const forbiddenSprites = [1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 13, 14, 15, 17, 19, 21, 23, 25, 27, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47];

function setClassByShape(obj) {
    // Sprites (shape === 0)
    if (obj.shape === 0) {
        if (obj.tile.tileset.name == "tiles") {
            tiled.alert("No puedes poner un tile en la capa de sprites (objects).");
            if (obj.layer && obj.layer.removeObject) {
                obj.layer.removeObject(obj);
                tiled.log("✗ Objeto eliminado: " + (obj.name || "ID:" + obj.id));
            }
            return false;
        }
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
        map.selectedObjectsChanged.connect(function () {
            var selectedObjects = map.selectedObjects;

            selectedObjects.forEach(function (obj) {
                setClassByShape(obj);
            });
        });
    }
}

tiled.activeAssetChanged.connect(function (asset) {
    if (asset && asset.isTileMap) {
        connectToMapEvents(asset);
    }
});

if (tiled.activeAsset && tiled.activeAsset.isTileMap) {
    connectToMapEvents(tiled.activeAsset);
}

// Evento al guardar el mapa: escanea la capa 'map' y loguea tiles animados
tiled.assetSaved.connect(function (asset) {
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
            if (!tile) continue;

            var room = getRoomFromTile(x, y);
            var screen = room.col + "," + room.row;

            if (tile.tileset.name === "sprites") {
                let relativeX = x % roomWidth;
                let relativeY = y % roomHeight;
                tiled.alert(`ERROR: Sprite en la capa de mapa en:\n\nPantalla (${screen}).\nCoordenadas: (${relativeX}, ${relativeY})`);
                return;
            }
            if ((tile.className === 'animated' || tile.className === 'animated-damage')) {
                if (!animatedCountByRoom[screen]) animatedCountByRoom[screen] = 0;
                animatedCountByRoom[screen]++;
            }
        }
    }
    // Mostrar el recuento y avisar si alguna room supera el límite
    for (var screen in animatedCountByRoom) {
        var count = animatedCountByRoom[screen];
        tiled.log(`Room ${screen} tiene ${count} tiles animados (límite: ${maxAnimated}).`);
        if (count > maxAnimated) {
            tiled.alert(`La pantalla (${screen}) tiene más de ${maxAnimated} tiles animados (${count})`);
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

var countSameTileObjectsAction = tiled.registerAction("CountSameTileObjects", function (action) {
    const asset = tiled.activeAsset;
    if (!asset || !asset.isTileMap) {
        tiled.alert("No active map.");
        return;
    }

    var mapLayer = getLayerByName(asset, "map");
    if (!mapLayer || !mapLayer.isTileLayer) {
        tiled.alert("No se encontró la capa 'map'.");
        return;
    }
    const ammoTile = 187
    const keyTile = 191
    const itemTile = 190
    const doorTile = 62
    const lifeTile = 189
    const enemyDoorTile = 63

    let countByTile = {
        'ammoTile': 0,
        'keyTile': 0,
        'itemTile': 0,
        'doorTile': 0,
        'lifeTile': 0,
        'enemyDoorTile': 0
    };

    for (var y = 0; y < mapLayer.height; y++) {
        for (var x = 0; x < mapLayer.width; x++) {
            var tile = mapLayer.tileAt(x, y);
            if (!tile) continue;

            if (tile.id === ammoTile) {
                countByTile.ammoTile++;
            } else if (tile.id === keyTile) {
                countByTile.keyTile++;
            } else if (tile.id === itemTile) {
                countByTile.itemTile++;
            } else if (tile.id === doorTile) {
                countByTile.doorTile++;
            } else if (tile.id === lifeTile) {
                countByTile.lifeTile++;
            } else if (tile.id === enemyDoorTile) {
                countByTile.enemyDoorTile++;
            }
        }
    }

    let summary = 
        `keyTile (${keyTile}): ${countByTile.keyTile}\n` +
        `itemTile (${itemTile}): ${countByTile.itemTile}\n` +
        `doorTile (${doorTile}): ${countByTile.doorTile}\n` +
        `lifeTile (${lifeTile}): ${countByTile.lifeTile}\n` +
        `ammoTile (${ammoTile}): ${countByTile.ammoTile}\n` +
        `enemyDoorTile (${enemyDoorTile}): ${countByTile.enemyDoorTile}`;
    tiled.alert(summary);
});

countSameTileObjectsAction.text = "Elements summary";
countSameTileObjectsAction.iconVisibleInMenu = false;

// Add to Edit menu (adjust menu if you prefer another location)
tiled.extendMenu("Edit", [
    { action: "CountSameTileObjects" }
]);