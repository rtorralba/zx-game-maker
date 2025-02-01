#!/usr/bin/env python3

import array
import json
import math
from collections import defaultdict
import os
from pprint import pprint
import subprocess
import sys
import numpy as np

def exitWithErrorMessage(message):
    print('\n\n=====================================================================================')
    sys.exit('ERROR: ' + message + '\n=====================================================================================\n\n')

outputDir = 'output/'

f = open(outputDir + 'maps.json')

data = json.load(f)

# Screens count per row
screenWidth = data['editorsettings']['chunksize']['width']
screenHeight = data['editorsettings']['chunksize']['height']
cellsPerScreen = screenWidth * screenHeight

tileHeight = data['tileheight']
tileWidth = data['tilewidth']

screenPixelsWidth = screenWidth * tileWidth
screenPixelsHeight = screenHeight * tileHeight

spriteTileOffset = 0

maxEnemiesPerScreen = 3
maxAnimatedTilesPerScreen = 3

damageTiles = []
animatedTilesIds = []
screenAnimatedTiles = defaultdict(dict)
ammoTile = 0
keyTile = 0
itemTile = 0
doorTile = 0
lifeTile = 0

for tileset in data['tilesets']:
    if tileset['name'] == 'tiles':
        for tile in tileset['tiles']:
            if tile['type'] == 'ammo':
                ammoTile = str(tile['id'])
            if tile['type'] == 'key':
                keyTile = str(tile['id'])
            if tile['type'] == 'item':
                itemTile = str(tile['id'])
            if tile['type'] == 'door':
                doorTile = str(tile['id'])
            if tile['type'] == 'life':
                lifeTile = str(tile['id'])
            if tile['type'] == 'animated':
                animatedTilesIds.append(tile['id'])
            if tile['type'] == 'damage':
                damageTiles.append(tile['id'])
            if tile['type'] == 'animated-damage':
                animatedTilesIds.append(tile['id'])
                damageTiles.append(tile['id'])
    elif tileset['name'] == 'sprites':
        spriteTileOffset = tileset['firstgid']

if spriteTileOffset == 0:
    print('ERROR: Sprite tileset should be called "sprites"')
    exit

# Global properties

gameName = 'Game Name'
initialLife = 40
goalItems = 2
damageAmount = 5
lifeAmount = 5
bulletDistance = 0
enemiesRespawn = 0
shooting = 1
shouldKillEnemies = 0
enabled128K = 0
hiScore = 0

vtplayerInit = 'EFAD'
vtplayerMute = 'EFB5'
vtplayerNextNote = 'EFB2'

initialScreen = 2
initialMainCharacterX = 8
initialMainCharacterY = 8

spritesMergeModeXor = 0
spritesWithColors = 0

initTexts = ""

backgroundAttribute = 7

animatePeriodMain = 3
animatePeriodEnemy = 3
animatePeriodTile = 10

password = ""

gameView = 'side'

killJumpingOnTop = 0

ammo = -1
ammoIncrement = 10

musicEnabled = 0

ink = 7
paper = 0
border = 0

keysEnabled = 1
itemsEnabled = 1

itemsCountdown = 0

useBreakableTile = 0

waitPressKeyAfterLoad = 0

if 'properties' in data:
    for property in data['properties']:
        if property['name'] == 'gameName':
            gameName = property['value']
        elif property['name'] == 'goalItems':
            goalItems = property['value']
        elif property['name'] == 'damageAmount':
            damageAmount = property['value']
        elif property['name'] == 'lifeAmount':
            lifeAmount = property['value']
        elif property['name'] == 'initialLife':
            initialLife = property['value']
        elif property['name'] == 'bulletDistance':
            bulletDistance = property['value']
        elif property['name'] == 'enemiesRespawn':
            enemiesRespawn = 1 if property['value'] else 0
        elif property['name'] == 'shooting':
            shooting = 1 if property['value'] else 0
        elif property['name'] == 'shouldKillEnemies':
            shouldKillEnemies = 1 if property['value'] else 0
        elif property['name'] == '128Kenabled':
            enabled128K = 1 if property['value'] else 0
        elif property['name'] == 'hiScore':
            hiScore = 1 if property['value'] else 0
        elif property['name'] == 'VTPLAYER_INIT':
            vtplayerInit = property['value']
        elif property['name'] == 'VTPLAYER_MUTE':
            vtplayerMute = property['value']
        elif property['name'] == 'VTPLAYER_NEXTNOTE':
            vtplayerNextNote = property['value']
        elif property['name'] == 'maxEnemiesPerScreen':
            if property['value'] < 7:
                maxEnemiesPerScreen = property['value']
            else:
                maxEnemiesPerScreen = 6
        elif property['name'] == 'spritesMergeModeXor':
            spritesMergeModeXor = 1 if property['value'] else 0
        elif property['name'] == 'spritesWithColors':
            spritesWithColors = 1 if property['value'] else 0
        elif property['name'] == 'initTexts':
            initTexts = property['value']
        elif property['name'] == 'backgroundAttribute':
            backgroundAttribute = property['value']
        elif property['name'] == 'animatePeriodMain':
            animatePeriodMain = property['value']
        elif property['name'] == 'animatePeriodEnemy':
            animatePeriodEnemy = property['value']
        elif property['name'] == 'animatePeriodTile':
            animatePeriodTile = property['value']
        elif property['name'] == 'password':
            password = property['value']
        elif property['name'] == 'gameView':
            gameView = property['value']
        elif property['name'] == 'killJumpingOnTop':
            killJumpingOnTop = 1 if property['value'] else 0
        elif property['name'] == 'ammo':
            ammo = property['value']
        elif property['name'] == 'ammoIncrement':
            ammoIncrement = property['value']
        elif property['name'] == 'musicEnabled':
            musicEnabled = 1 if property['value'] else 0
        elif property['name'] == 'ink':
            ink = property['value']
        elif property['name'] == 'paper':
            paper = property['value']
        elif property['name'] == 'border':
            border = property['value']
        elif property['name'] == 'waitPressKeyAfterLoad':
            waitPressKeyAfterLoad = 1 if property['value'] else 0
        elif property['name'] == 'keysEnabled':
            keysEnabled = 1 if property['value'] else 0
        elif property['name'] == 'itemsEnabled':
            itemsEnabled = 1 if property['value'] else 0
        elif property['name'] == 'itemsCountdown':
            itemsCountdown = 1 if property['value'] else 0
        elif property['name'] == 'useBreakableTile':
            useBreakableTile = 1 if property['value'] else 0

if len(damageTiles) == 0:
    damageTiles.append('0')
 
damageTilesCount = len(damageTiles) - 1 if len(damageTiles) > 0 else 0
animatedTilesIdsCount = len(animatedTilesIds) - 1 if len(animatedTilesIds) > 0 else 0

configStr = "const MAX_ENEMIES_PER_SCREEN as ubyte = " + str(maxEnemiesPerScreen) + "\n"
configStr += "const MAX_ANIMATED_TILES_PER_SCREEN as ubyte = " + str(maxAnimatedTilesPerScreen - 1) + "\n"
configStr += "const screenWidth as ubyte = " + str(screenWidth) + "\n"
configStr += "const screenHeight as ubyte = " + str(screenHeight) + "\n"
configStr += "const INITIAL_LIFE as ubyte = " + str(initialLife) + "\n"
configStr += "const MAX_LINE as ubyte = " + str(screenHeight * 2 - 4) + "\n"
configStr += "const DAMAGE_AMOUNT as ubyte = " + str(damageAmount) + "\n"
configStr += "const LIFE_AMOUNT as ubyte = " + str(lifeAmount) + "\n"
configStr += "const BULLET_DISTANCE as ubyte = " + str(bulletDistance) + "\n"
configStr += "const SHOULD_KILL_ENEMIES as ubyte = " + str(shouldKillEnemies) + "\n"
configStr += "const AMMO_TILE as ubyte = " + str(ammoTile) + "\n"
configStr += "const KEY_TILE as ubyte = " + keyTile + "\n"
configStr += "const ITEM_TILE as ubyte = " + itemTile + "\n"
configStr += "const DOOR_TILE as ubyte = " + doorTile + "\n"
configStr += "const LIFE_TILE as ubyte = " + lifeTile + "\n"
configStr += "const ANIMATE_PERIOD_MAIN as ubyte = " + str(animatePeriodMain) + "\n"
configStr += "const ANIMATE_PERIOD_ENEMY as ubyte = " + str(animatePeriodEnemy) + "\n"
configStr += "const ANIMATE_PERIOD_TILE as ubyte = " + str(animatePeriodTile) + "\n\n"

configStr += "const ITEMS_COUNTDOWN as ubyte = " + str(itemsCountdown) + "\n"
configStr += "const ITEMS_TO_FIND as ubyte = " + str(goalItems) + "\n"
if itemsCountdown == 1:
    configStr += "const ITEMS_INCREMENT as ubyte = -1\n"
    configStr += "const GOAL_ITEMS as ubyte = 0 \n"
    configStr += "dim currentItems as ubyte = " + str(goalItems) + "\n"
else:
    configStr += "const ITEMS_INCREMENT as ubyte = 1\n"
    configStr += "const GOAL_ITEMS as ubyte = " + str(goalItems) + "\n"
    configStr += "dim currentItems as ubyte = 0\n\n"


# save damage tiles in file .bin instead variable
with open("output/damageTiles.bin", "wb") as f:
    f.write(bytearray(damageTiles))

configStr += "const DAMAGE_TILES_COUNT as ubyte = " + str(damageTilesCount) + "\n"

if shooting == 1:
    configStr += "#DEFINE SHOOTING_ENABLED\n"

configStr += "#DEFINE VTPLAYER_INIT $" + str(vtplayerInit) + "\n"
configStr += "#DEFINE VTPLAYER_MUTE $" + str(vtplayerMute) + "\n"
configStr += "#DEFINE VTPLAYER_NEXTNOTE $" + str(vtplayerNextNote) + "\n\n"

if keysEnabled == 1:
    configStr += "#DEFINE KEYS_ENABLED\n"

if itemsEnabled == 1:
    configStr += "#DEFINE ITEMS_ENABLED\n"

configStr += "const BACKGROUND_ATTRIBUTE = " + str(backgroundAttribute) + "\n"

if len(initTexts) > 0:
    configStr += "#DEFINE INIT_TEXTS\n"
    initTexts = initTexts.split("\n")
    configStr += "dim initTexts(" + str(len(initTexts) - 1) + ") as string\n"
    for idx, text in enumerate(initTexts):
        configStr += "initTexts(" + str(idx) + ") = \"" + text + "\"\n"

configStr += "\n"

if enabled128K == 1:
    configStr += "#DEFINE ENABLED_128k\n"

if hiScore == 1:
    configStr += "#DEFINE HISCORE_ENABLED\n\n"
    configStr += "dim score as uinteger = 0\n"
    configStr += "dim hiScore as uinteger = 0\n"

if spritesMergeModeXor == 1:
    configStr += "#DEFINE MERGE_WITH_XOR\n"

if spritesWithColors == 1:
    configStr += "#DEFINE SPRITES_WITH_COLORS\n"

if len(password) > 0:
    configStr += "#DEFINE PASSWORD_ENABLED\n"
    configStr += "dim password as string = \"" + str(password) + "\"\n"

if gameView == 'overhead':
    configStr += "#DEFINE OVERHEAD_VIEW\n"
else:
    configStr += "#DEFINE SIDE_VIEW\n"

if killJumpingOnTop == 1:
    configStr += "#DEFINE KILL_JUMPING_ON_TOP\n"

if ammo > -1:
    configStr += "#DEFINE AMMO_ENABLED\n"
    configStr += "dim currentAmmo as ubyte = " + str(ammo) + "\n"
    configStr += "const AMMO_INCREMENT as ubyte = " + str(ammoIncrement) + "\n"

if musicEnabled == 1:
    configStr += "#DEFINE MUSIC_ENABLED\n"

configStr += "const INK_VALUE as ubyte = " + str(ink) + "\n"
configStr += "const PAPER_VALUE as ubyte = " + str(paper) + "\n"
configStr += "const BORDER_VALUE as ubyte = " + str(border) + "\n"

if waitPressKeyAfterLoad == 1:
    configStr += "#DEFINE WAIT_PRESS_KEY_AFTER_LOAD\n"
    configStr += "dim firstLoad as ubyte = 1\n"

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        screensCount = len(layer['chunks'])
        mapRows = layer['height']//screenHeight
        mapCols = layer['width']//screenWidth

        screens = []
        screenObjects = defaultdict(dict)

        for idx, screen in enumerate(layer['chunks']):
            screens.append(array.array('B', screen['data']))

            screenObjects[idx]['ammo'] = 0
            screenObjects[idx]['key'] = 0
            screenObjects[idx]['item'] = 0
            screenObjects[idx]['door'] = 0
            screenObjects[idx]['life'] = 0

            screenAnimatedTiles[idx] = []

            for jdx, cell in enumerate(screen['data']):
                mapX = jdx % screen['width']
                mapY = jdx // screen['width']

                tile = str(cell - 1)

                # screens[idx][mapY][mapX % screenWidth] = tile

                if int(tile) in animatedTilesIds and len(screenAnimatedTiles[idx]) < maxAnimatedTilesPerScreen:
                    screenAnimatedTiles[idx].append([tile, mapX, mapY, 0])

                if tile == keyTile:
                    screenObjects[idx]['key'] = 1
                elif tile == itemTile:
                    screenObjects[idx]['item'] = 1
                elif tile == doorTile:
                    screenObjects[idx]['door'] = 1
                elif tile == lifeTile:
                    screenObjects[idx]['life'] = 1
                elif tile == ammoTile:
                    screenObjects[idx]['ammo'] = 1
                
configStr += "const MAP_SCREENS_WIDTH_COUNT as ubyte = " + str(mapCols) + "\n"
configStr += "const SCREEN_OBJECT_ITEM_INDEX as ubyte = 0 \n"
configStr += "const SCREEN_OBJECT_KEY_INDEX as ubyte = 1 \n"
configStr += "const SCREEN_OBJECT_DOOR_INDEX as ubyte = 2 \n"
configStr += "const SCREEN_OBJECT_LIFE_INDEX as ubyte = 3 \n"
configStr += "const SCREEN_OBJECT_AMMO_INDEX as ubyte = 4 \n"
configStr += "const SCREENS_COUNT as ubyte = " + str(screensCount - 1) + "\n\n"

with open("output/screenObjects.bin", "wb") as f:
    for screen in screenObjects:
        f.write(bytearray([screenObjects[screen]['item'], screenObjects[screen]['key'], screenObjects[screen]['door'], screenObjects[screen]['life'], screenObjects[screen]['ammo']]))

with open("output/objectsInScreen.bin", "wb") as f:
    for screen in screenObjects:
        f.write(bytearray([screenObjects[screen]['item'], screenObjects[screen]['key'], screenObjects[screen]['door'], screenObjects[screen]['life'], screenObjects[screen]['ammo']]))

for screen in screenAnimatedTiles:
    for i in range(3 - len(screenAnimatedTiles[screen])):
        screenAnimatedTiles[screen].append([0, 0, 0, 0, 0])

with open("output/animatedTilesInScreen.bin", "wb") as f:
    for screen in screenAnimatedTiles:
        for tile in screenAnimatedTiles[screen]:
            f.write(bytearray([int(tile[0]), int(tile[1]), int(tile[2]), int(tile[3])]))

# configStr += "dim screenObjectsInitial(" + str(screensCount - 1) + ", 3) as ubyte = { _\n"
# for screen in screenObjects:
#     configStr += '\t{' + str(screenObjects[screen]['item']) + ', ' + str(screenObjects[screen]['key']) + ', ' + str(screenObjects[screen]['door']) + ', ' + str(screenObjects[screen]['life']) + '}, _\n'
# configStr = configStr[:-4]
# configStr += " _\n}\n\n"

configStr += "const SCREEN_LENGTH as uinteger = " + str(len(screens[0]) - 1) + "\n"
configStr += "dim decompressedMap(SCREEN_LENGTH) as ubyte\n"

currentOffset = 0
screenOffsets = []
screenOffsets.append(currentOffset)

if shouldKillEnemies == 1:
    configStr += "#DEFINE SHOULD_KILL_ENEMIES_ENABLED\n"

if enemiesRespawn == 0:
    configStr += "#DEFINE ENEMIES_NOT_RESPAWN_ENABLED\n"

with open("output/screensWon.bin", "wb") as f:
    f.write(bytearray([0] * screensCount))

if useBreakableTile == 1:
    configStr += "#DEFINE USE_BREAKABLE_TILE\n"
    with open("output/brokenTiles.bin", "wb") as f:
        f.write(bytearray([0] * screensCount))

for idx, screen in enumerate(screens):
    label = 'screen' + str(idx).zfill(3)
    with open(outputDir + label + '.bin', 'wb') as f:
        screen.tofile(f)
    subprocess.run(['src/bin/zx0', '-f', outputDir + label + '.bin', outputDir + label + '.bin.zx0'])
    currentOffset += os.path.getsize(outputDir + label + '.bin.zx0')
    screenOffsets.append(currentOffset)

with open(outputDir + "screenOffsets.bin", "wb") as f:
    for offset in screenOffsets:
        f.write(offset.to_bytes(2, byteorder='little'))

# Construct enemies

objects = {}
keys = {}
items = {}

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if 'gid' in object:
                xScreenPosition = math.ceil(object['x'] / screenPixelsWidth) - 1
                yScreenPosition = math.ceil(object['y'] / screenPixelsHeight) - 1
                screenId = xScreenPosition + (yScreenPosition * mapCols)
                objects[str(object['id'])] = {
                    'name': object['name'],
                    'screenId': screenId,
                    'linIni': str(int((object['y'] % (tileHeight * screenHeight))) // 4),
                    'linEnd': str(int((object['y'] % (tileHeight * screenHeight))) // 4),
                    'colIni': str(int((object['x'] % (tileWidth * screenWidth))) // 4),
                    'colEnd': str(int((object['x'] % (tileWidth * screenWidth))) // 4),
                    'tile': str(object['gid'] - spriteTileOffset),
                    'life': '1',
                    'color': '0',
                }

                if 'properties' in object and len(object['properties']) > 0:
                    for property in object['properties']:
                        if property['name'] == 'life':
                            objects[str(object['id'])]['life'] = str(property['value'])
                        elif property['name'] == 'color':
                            objects[str(object['id'])]['color'] = str(property['value'])
for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if 'point' in object and object['point'] == True:
                if object['type'] == '' and 'properties' in object:
                    objects[str(object['properties'][0]['value'])]['linEnd'] = str(int((object['y'] % (tileHeight * screenHeight))) // 4)
                    objects[str(object['properties'][0]['value'])]['colEnd'] = str(int((object['x'] % (tileWidth * screenWidth))) // 4)
                elif object['type'] == 'mainCharacter':
                    xScreenPosition = math.ceil(object['x'] / screenPixelsWidth) - 1
                    yScreenPosition = math.ceil(object['y'] / screenPixelsHeight) - 1
                    screenId = xScreenPosition + (yScreenPosition * mapCols)
                    initialScreen = screenId
                    initialMainCharacterX = str(int((object['x'] % (tileWidth * screenWidth))) // 4)
                    initialMainCharacterY = str(int((object['y'] % (tileHeight * screenHeight))) // 4)

                    if int(initialMainCharacterX) < 2 or int(initialMainCharacterX) > 60 or int(initialMainCharacterY) < 0 or int(initialMainCharacterY) > 38:
                        exitWithErrorMessage('Main character initial position is out of bounds. X: ' + initialMainCharacterX + ', Y: ' + initialMainCharacterY)
                else:
                    exitWithErrorMessage('Unknown object type. Only "enemy" and "mainCharacter" are allowed')   
                    

screenEnemies = defaultdict(dict)

for enemyId in objects:
    enemy = objects[enemyId]
    if len(screenEnemies[enemy['screenId']]) == 0:
        screenEnemies[enemy['screenId']] = []
    screenEnemies[enemy['screenId']].append(enemy)

enemiesPerScreen = []

configStr += "const INITIAL_SCREEN as ubyte = " + str(initialScreen) + "\n"
configStr += "const INITIAL_MAIN_CHARACTER_X as ubyte = " + str(initialMainCharacterX) + "\n"
configStr += "const INITIAL_MAIN_CHARACTER_Y as ubyte = " + str(initialMainCharacterY) + "\n"

enemiesArray = []

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        for idx, screen in enumerate(layer['chunks']):
            arrayBuffer = []
            if idx in screenEnemies:
                screen = screenEnemies[idx]
                enemiesPerScreen.append(0)
                for i in range(maxEnemiesPerScreen):
                    if i <= len(screen) - 1:
                        enemy = screen[i]
                        if (int(enemy['colIni']) < int(enemy['colEnd'])):
                            horizontalDirection = '-1'
                        else:
                            horizontalDirection = '1'

                        if (int(enemy['linIni']) > int(enemy['linEnd'])):
                            verticalDirection = '1'
                        else:
                            verticalDirection = '-1'

                        enemiesPerScreen[idx] = enemiesPerScreen[idx] + 1
                        arrayBuffer.append(int(enemy['tile']))
                        arrayBuffer.append(int(enemy['linIni']))
                        arrayBuffer.append(int(enemy['colIni']))
                        arrayBuffer.append(int(enemy['linEnd']))
                        arrayBuffer.append(int(enemy['colEnd']))
                        arrayBuffer.append(int(horizontalDirection))
                        arrayBuffer.append(int(enemy['linIni']))
                        arrayBuffer.append(int(enemy['colIni']))
                        arrayBuffer.append(int(enemy['life']))
                        arrayBuffer.append(i + 1)
                        arrayBuffer.append(int(verticalDirection))                  
                        arrayBuffer.append(int(enemy['color']))                  
                    else:
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(i + 1)
                        arrayBuffer.append(0) 
                        arrayBuffer.append(0)
            else:
                for i in range(maxEnemiesPerScreen):
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(1)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                enemiesPerScreen.append(0)
            enemiesArray.append(array.array('b', arrayBuffer))

enemiesInScreenOffsets = []
enemiesInScreenOffsets.append(0)
currentOffset = 0
for idx, enemiesScreen in enumerate(enemiesArray):
    label = 'enemiesInScreen' + str(idx).zfill(3)
    with open(outputDir + label + '.bin', 'wb') as f:
        enemiesScreen.tofile(f)
    subprocess.run(['src/bin/zx0', '-f', outputDir + label + '.bin', outputDir + label + '.bin.zx0'])
    currentOffset += os.path.getsize(outputDir + label + '.bin.zx0')
    enemiesInScreenOffsets.append(currentOffset)

with open(outputDir + "enemiesInScreenOffsets.bin", "wb") as f:
    for offset in enemiesInScreenOffsets:
        f.write(offset.to_bytes(2, byteorder='little'))

with open("output/enemiesPerScreen.bin", "wb") as f:
    f.write(bytearray(enemiesPerScreen))

with open("output/enemiesPerScreenInitial.bin", "wb") as f:
    f.write(bytearray(enemiesPerScreen))

# configStr += "dim decompressedEnemiesScreen(" + str(maxEnemiesPerScreen - 1) + ", 11) as byte\n"

with open("output/decompressedEnemiesScreen.bin", "wb") as f:
    for i in range(maxEnemiesPerScreen):
        f.write(bytearray([0] * 12))

with open(outputDir + "config.bas", "w") as text_file:
    print(configStr, file=text_file)

with open(outputDir + 'map.bin.zx0', 'wb') as outfile:
    for idx in range(screensCount):
        label = 'screen' + str(idx).zfill(3)
        with open(outputDir + label + '.bin.zx0', 'rb') as infile:
            outfile.write(infile.read())

with open(outputDir + 'enemies.bin.zx0', 'wb') as outfile:
    for idx in range(screensCount):
        label = 'enemiesInScreen' + str(idx).zfill(3)
        with open(outputDir + label + '.bin.zx0', 'rb') as infile:
            outfile.write(infile.read())