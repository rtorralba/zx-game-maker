#!/usr/bin/env python3

import array
import json
import math
from collections import defaultdict
import os
import platform
from pprint import pprint
import subprocess
import sys

def exitWithErrorMessage(message):
    print('\n\n=====================================================================================')
    sys.exit('ERROR: ' + message + '\n=====================================================================================\n\n')

# Detectar el sistema operativo y en base a el el nombre del ejecutable zx0 
CURRENT_OS = platform.system()
if CURRENT_OS=='Darwin':
    ZX0_EXEC="bin/zx0-mac"
else:
    ZX0_EXEC="bin/zx0"

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
maxAnimatedTilesPerScreen = 6

damageTiles = []
animatedTilesIds = []
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

useBreakableTile = "disabled"

waitPressKeyAfterLoad = 0

newBeeperPlayer = 1

redefineKeysEnabled = 0

mainCharacterExtraFrame = 1

idleTime = 0

arcadeMode = 0
arcadeModeFirstScreen = 0

jetPackFuel = 0

gravitySpeed = 2
jumpArrayCount = 5
jumpArray = "{-2, -2, -2, -2, -2}"

livesMode = 0

messagesEnabled = 0

laddersEnabled = 1

disableContinuousJump = 0

borderColorItem = 0
borderColorKey = 0
borderColorLife = 0

timerSeconds = 0

finishGameObjective = 0
finishGameEnemy = 0

itemsToOpenDoors = 0
useBreakableTileByTouch = 0
useBreakableTileByTouchFrames = 30

arcadeModeResetOnKill = 0

messagesDefaultPaper = 7
messagesDefaultInk = 0

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
            useBreakableTile = property['value']
        elif property['name'] == 'maxAnimatedTilesPerScreen':
            maxAnimatedTilesPerScreen = property['value']
        elif property['name'] == 'newBeeperPlayer':
            newBeeperPlayer = 1 if property['value'] else 0
        elif property['name'] == 'redefineKeysEnabled':
            redefineKeysEnabled = 1 if property['value'] else 0
        elif property['name'] == 'mainCharacterExtraFrame':
            mainCharacterExtraFrame = 1 if property['value'] else 0
        elif property['name'] == 'idleTime':
            idleTime = property['value']
        elif property['name'] == 'arcadeMode':
            arcadeMode = 1 if property['value'] else 0
        elif property['name'] == 'arcadeModeFirstScreen':
            arcadeModeFirstScreen = property['value']
        elif property['name'] == 'jetPackFuel':
            jetPackFuel = property['value'] 
        elif property['name'] == 'jumpType':
            if property['value'] == 'accelerated':
                jumpArrayCount = 8
                jumpArray = "{-2, -2, -2, -2, -2, 0, 0, 0}"
        elif property['name'] == 'livesMode':
            if property['value'] == 'instant respawn':
                livesMode = 1
            elif property['value'] == 'show graveyard':
                livesMode = 2
        elif property['name'] == 'messagesEnabled':
            messagesEnabled = 1 if property['value'] else 0
        elif property['name'] == 'laddersEnabled':
            laddersEnabled = 1 if property['value'] else 0
        elif property['name'] == 'disableContinuousJump':
            disableContinuousJump = 1 if property['value'] else 0
        elif property['name'] == 'borderColorItem':
            borderColorItem = property['value']
        elif property['name'] == 'borderColorKey':
            borderColorKey = property['value']
        elif property['name'] == 'borderColorLife':
            borderColorLife = property['value']
        elif property['name'] == 'timerSeconds':
            timerSeconds = property['value']
        elif property['name'] == 'finishGameObjective':
            finishGameObjective = property['value']
        elif property['name'] == 'finishGameEnemy':
            finishGameEnemy = property['value']
        elif property['name'] == 'itemsToOpenDoors':
            itemsToOpenDoors = property['value']
        elif property['name'] == 'useBreakableTileByTouch':
            useBreakableTileByTouch = 1 if property['value'] else 0
        elif property['name'] == 'useBreakableTileByTouchFrames':
            useBreakableTileByTouchFrames = property['value']
        elif property['name'] == 'arcadeModeResetOnKill':
            arcadeModeResetOnKill = 1 if property['value'] else 0
        elif property['name'] == 'messagesDefaultPaper':
            messagesDefaultPaper = property['value']
        elif property['name'] == 'messagesDefaultInk':
            messagesDefaultInk = property['value']

if len(damageTiles) == 0:
    damageTiles.append('0')
 
damageTilesCount = len(damageTiles) - 1 if len(damageTiles) > 0 else 0
animatedTilesIdsCount = len(animatedTilesIds) - 1 if len(animatedTilesIds) > 0 else 0

configStr = "const MAX_ENEMIES_PER_SCREEN as ubyte = " + str(maxEnemiesPerScreen) + "\n"
configStr += "#define MAX_ANIMATED_TILES_PER_SCREEN " + str(maxAnimatedTilesPerScreen - 1) + "\n"
configStr += "const ANIMATED_TILES_COUNT as ubyte = " + str(animatedTilesIdsCount) + "\n"
configStr += "const screenWidth as ubyte = " + str(screenWidth) + "\n"
configStr += "const screenHeight as ubyte = " + str(screenHeight) + "\n"
configStr += "const INITIAL_LIFE as ubyte = " + str(initialLife) + "\n"
configStr += "const MAX_LINE as ubyte = " + str(screenHeight * 2 - 4) + "\n"

if livesMode == 1:
    configStr += "#DEFINE LIVES_MODE_ENABLED\n"
    configStr += "#DEFINE LIVES_MODE_RESPAWN\n"
elif livesMode == 2:
    configStr += "#DEFINE LIVES_MODE_ENABLED\n"
    configStr += "#DEFINE LIVES_MODE_GRAVEYARD\n"
else:
    configStr += "const DAMAGE_AMOUNT as ubyte = " + str(damageAmount) + "\n"

configStr += "const LIFE_AMOUNT as ubyte = " + str(lifeAmount) + "\n"
configStr += "const BULLET_DISTANCE as ubyte = " + str(bulletDistance) + "\n"
configStr += "const SHOULD_KILL_ENEMIES as ubyte = " + str(shouldKillEnemies) + "\n"
configStr += "const KEY_TILE as ubyte = " + keyTile + "\n"
configStr += "const ITEM_TILE as ubyte = " + itemTile + "\n"
# configStr += "const DOOR_TILE as ubyte = " + doorTile + "\n"
configStr += "const LIFE_TILE as ubyte = " + lifeTile + "\n"
configStr += "const ANIMATE_PERIOD_MAIN as ubyte = " + str(animatePeriodMain) + "\n"
configStr += "const ANIMATE_PERIOD_ENEMY as ubyte = " + str(animatePeriodEnemy) + "\n"
configStr += "const ANIMATE_PERIOD_TILE as ubyte = " + str(animatePeriodTile) + "\n\n"

configStr += "const ITEMS_COUNTDOWN as ubyte = " + str(itemsCountdown) + "\n"
configStr += "dim itemsToFind as ubyte = " + str(goalItems) + "\n"
if itemsCountdown == 1 and not arcadeMode:
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

configStr += "#define ONSCREEN_2x2_SPRITES " + str(maxEnemiesPerScreen + 1) + "\n"

configStr += "const DAMAGE_TILES_COUNT as ubyte = " + str(damageTilesCount) + "\n"

if shooting == 1:
    configStr += "#DEFINE SHOOTING_ENABLED\n"

if newBeeperPlayer == 1:
    configStr += "#DEFINE NEW_BEEPER_PLAYER\n"

if keysEnabled == 1:
    configStr += "#DEFINE KEYS_ENABLED\n"

if itemsEnabled == 1:
    configStr += "#DEFINE ITEMS_ENABLED\n"

configStr += "const BACKGROUND_ATTRIBUTE as ubyte = " + str(backgroundAttribute) + "\n"

if arcadeMode == 1:
    configStr += "#DEFINE ARCADE_MODE\n"
    if arcadeModeResetOnKill == 1:
        configStr += "#DEFINE ARCADE_MODE_RESET_ON_KILL\n"

if messagesEnabled == 1:
    configStr += "#DEFINE MESSAGES_ENABLED\n"
    configStr += "Dim messageLoopCounter As Ubyte = 0\n"
    configStr += "#Define MESSAGE_LOOPS_VISIBLE 30\n"
    configStr += "Const MESSAGE_DEFAULT_PAPER As Ubyte = " + str(messagesDefaultPaper) + "\n"
    configStr += "Const MESSAGE_DEFAULT_INK As Ubyte = " + str(messagesDefaultInk) + "\n"

if laddersEnabled == 1:
    configStr += "#DEFINE LADDERS_ENABLED\n"

if disableContinuousJump == 1 and gameView == 'side':
    configStr += "#DEFINE DISABLE_CONTINUOUS_JUMP\n"
    configStr += "\n"

if borderColorItem != border and borderColorItem < 8:
    configStr += "#DEFINE BORDER_COLOR_ITEM " + str(borderColorItem) + "\n"

if borderColorKey != border and borderColorKey < 8:
    configStr += "#DEFINE BORDER_COLOR_KEY " + str(borderColorKey) + "\n"

if borderColorLife != border and borderColorLife < 8:
    configStr += "#DEFINE BORDER_COLOR_LIFE " + str(borderColorLife) + "\n"

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
    configStr += "const AMMO_TILE as ubyte = " + str(ammoTile) + "\n"
    configStr += "#DEFINE AMMO_ENABLED\n"
    configStr += "const INITIAL_AMMO as ubyte = " + str(ammo) + "\n"
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

if redefineKeysEnabled == 1:
    configStr += "#DEFINE REDEFINE_KEYS_ENABLED\n"

if jetPackFuel > 0:
    configStr += "#DEFINE JETPACK_FUEL "  + str(jetPackFuel) + "\n"

if mainCharacterExtraFrame == 1:
    configStr += "#DEFINE MAIN_CHARACTER_EXTRA_FRAME\n"

if idleTime > 0:
    configStr += "#DEFINE IDLE_ENABLED\n"
    configStr += "const IDLE_TIME as ubyte = " + str(idleTime) + "\n"

if finishGameObjective == 'items' or finishGameObjective == 0:
    configStr += "#define FINISH_GAME_OBJECTIVE_ITEM\n"
elif finishGameObjective == 'killSpecificEnemy':
    if finishGameEnemy == 0:
        exitWithErrorMessage('You must specify the enemyToKill property when finishGameObjective is set to killSpecificEnemy')
    configStr += "#define FINISH_GAME_OBJECTIVE_ENEMY\n"
    configStr += "Const ENEMY_TO_KILL as ubyte = " + str(finishGameEnemy) + "\n"
    configStr += "Dim enemyToKillAlreadyKilled as ubyte = 0\n"
elif finishGameObjective == 'itemsAndKillEnemy':
    if finishGameEnemy == 0:
        exitWithErrorMessage('You must specify the enemyToKill property when finishGameObjective is set to itemsAndKillEnemy')
    configStr += "#define FINISH_GAME_OBJECTIVE_ITEMS_AND_ENEMY\n"
    configStr += "Const ENEMY_TO_KILL as ubyte = " + str(finishGameEnemy) + "\n"
    configStr += "Dim enemyToKillAlreadyKilled as ubyte = 0\n"

configStr += "Const ITEMS_TO_OPEN_DOORS as ubyte = " + str(itemsToOpenDoors) + "\n"

if useBreakableTileByTouch == 1:
    configStr += "#DEFINE USE_BREAKABLE_TILE_BY_TOUCH\n"
    configStr += "Const BREAKABLE_BY_TOUCH_TILE_FRAMES as ubyte = " + str(useBreakableTileByTouchFrames) + "\n"

breakableTilesCount = 0
screenObjectsCount = 0

animatedTilesArray = "{" + ', '.join(str(i) for i in animatedTilesIds) + "}"
configStr += "Dim animatedTiles(ANIMATED_TILES_COUNT) As Ubyte = " + animatedTilesArray + "\n"

breakableByBulletTile = '60'

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        screensCount = len(layer['chunks'])
        mapRows = layer['height']//screenHeight
        mapCols = layer['width']//screenWidth

        screens = []
        screenObjects = defaultdict(dict)

        for idx, screen in enumerate(layer['chunks']):
            screens.append(array.array('B', screen['data']))

            for jdx, cell in enumerate(screen['data']):
                mapX = jdx % screen['width']
                mapY = jdx // screen['width']

                tile = str(cell - 1)

                if tile == breakableByBulletTile:
                    breakableTilesCount += 1

                # screens[idx][mapY][mapX % screenWidth] = tile

                if tile == keyTile or tile == itemTile or tile == doorTile or tile == lifeTile or tile == ammoTile or tile == "63":
                    screenObjectsCount += 1
                
configStr += "const MAP_SCREENS_WIDTH_COUNT as ubyte = " + str(mapCols) + "\n"
configStr += "const SCREEN_OBJECT_ITEM_INDEX as ubyte = 0 \n"
configStr += "const SCREEN_OBJECT_KEY_INDEX as ubyte = 1 \n"
configStr += "const SCREEN_OBJECT_DOOR_INDEX as ubyte = 2 \n"
configStr += "const SCREEN_OBJECT_LIFE_INDEX as ubyte = 3 \n"
configStr += "const SCREEN_OBJECT_AMMO_INDEX as ubyte = 4 \n"
configStr += "const SCREENS_COUNT as ubyte = " + str(screensCount - 1) + "\n\n"

configStr += "#ifdef SIDE_VIEW\n"
configStr += "  Const jumpStopValue As Ubyte = 255\n"
configStr += "  Dim landed As Ubyte = 1\n"
configStr += "  Dim jumpCurrentKey As Ubyte = jumpStopValue\n"
configStr += "  #ifndef JETPACK_FUEL\n"
configStr += "    Const jumpStepsCount As Ubyte = " + str(jumpArrayCount) + "\n"
configStr += "    Dim jumpArray(jumpStepsCount - 1) As Byte = " + jumpArray + "\n"
configStr += "  #else\n"
configStr += "    Const jumpStepsCount As Ubyte = JETPACK_FUEL\n"
configStr += "    Dim jumpEnergy As Ubyte = jumpStepsCount\n"
configStr += "  #endif\n"
configStr += "#endif\n"

with open("output/screenObjects.bin", "wb") as f:
    f.write(bytearray([0] * (screenObjectsCount) * 4))

configStr += "CONST SCREEN_OBJECTS_COUNT as ubyte = " + str(screenObjectsCount) + "\n"

with open("output/objectsInScreen.bin", "wb") as f:
    for screen in screenObjects:
        f.write(bytearray([screenObjects[screen]['item'], screenObjects[screen]['key'], screenObjects[screen]['door'], screenObjects[screen]['life'], screenObjects[screen]['ammo']]))

with open("output/animatedTilesInScreen.bin", "wb") as f:
    for i in range(maxAnimatedTilesPerScreen):
        f.write(bytearray([0, 0, 0]))

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

if useBreakableTile == 'all':
    configStr += "#DEFINE USE_BREAKABLE_TILE_ALL\n"
    with open("output/brokenTiles.bin", "wb") as f:
        f.write(bytearray([0] * screensCount))
elif useBreakableTile == 'individual':
    configStr += "#DEFINE USE_BREAKABLE_TILE_INDIVIDUAL\n"
    configStr += "#DEFINE BREAKABLE_TILES_COUNT " + str(breakableTilesCount) + "\n"
    with open("output/brokenTiles.bin", "wb") as f:
        f.write(bytearray([0] * breakableTilesCount * 3))


for idx, screen in enumerate(screens):
    label = 'screen' + str(idx).zfill(3)
    with open(outputDir + label + '.bin', 'wb') as f:
        screen.tofile(f)
    subprocess.run([ZX0_EXEC, '-f', outputDir + label + '.bin', outputDir + label + '.bin.zx0'])
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
                    'linEnd': "255",
                    'colIni': str(int((object['x'] % (tileWidth * screenWidth))) // 4),
                    'colEnd': str(int((object['x'] % (tileWidth * screenWidth))) // 4),
                    'tile': str(object['gid'] - spriteTileOffset),
                    'life': '1',
                    'speed': '3',
                    'move': '0',
                    'id': str(object['id'])
                }

                if 'properties' in object and len(object['properties']) > 0:
                    for property in object['properties']:
                        if property['name'] == 'life':
                            objects[str(object['id'])]['life'] = str(property['value'])
                        elif property['name'] == 'speed':
                            if property['value'] in [0, 1, 2, 3]:
                                objects[str(object['id'])]['speed'] = str(property['value'])
                        elif property['name'] == 'move':
                            if property['value'] == 'noReturn':
                                objects[str(object['id'])]['move'] = '1'
for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if 'point' in object and object['point'] == True:
                xScreenPosition = math.ceil(object['x'] / screenPixelsWidth) - 1
                yScreenPosition = math.ceil(object['y'] / screenPixelsHeight) - 1
                screenId = xScreenPosition + (yScreenPosition * mapCols)
                if object['type'] == '' and 'properties' in object:
                    objects[str(object['properties'][0]['value'])]['linEnd'] = str(int((object['y'] % (tileHeight * screenHeight))) // 4)
                    objects[str(object['properties'][0]['value'])]['colEnd'] = str(int((object['x'] % (tileWidth * screenWidth))) // 4)
                elif object['type'] == 'mainCharacter':
                    initialScreen = screenId
                    initialMainCharacterX = str(int((object['x'] % (tileWidth * screenWidth))) // 4)
                    initialMainCharacterY = str(int((object['y'] % (tileHeight * screenHeight))) // 4)

                    if int(initialMainCharacterX) < 2 or int(initialMainCharacterX) > 60 or int(initialMainCharacterY) < 0 or int(initialMainCharacterY) > 38:
                        exitWithErrorMessage('Main character initial position is out of bounds. X: ' + initialMainCharacterX + ', Y: ' + initialMainCharacterY)
                    
                    if arcadeMode == 1: # Voy guardando en un array cuyo indice sea la pantalla y el valor sea la posición de inicio
                        keys[str(screenId)] = [int(initialMainCharacterX), int(initialMainCharacterY)]
                elif object['type'] == 'music2':
                    configStr += "Const MUSIC_2_SCREEN_ID as Uinteger = " + str(screenId) + "\n"
                    configStr += "Dim music2alreadyPlayed as Ubyte = 0\n"
                elif object['type'] == 'music3':
                    configStr += "Const MUSIC_3_SCREEN_ID as Uinteger = " + str(screenId) + "\n"
                    configStr += "Dim music3alreadyPlayed as Ubyte = 0\n"
                else:
                    exitWithErrorMessage('Unknown object type. Only "enemy" and "mainCharacter" are allowed')   
                    
if arcadeMode == 1: # Defino el array de posiciones iniciales del personaje principal
    configStr += "dim mainCharactersArray(" + str(screensCount - 1) + ", 1) as ubyte = { _\n"
    for key in keys:
        configStr += '\t{' + str(keys[key][0]) + ', ' + str(keys[key][1]) + '}, _\n'
    configStr = configStr[:-4]
    configStr += " _\n}\n\n"

screenEnemies = defaultdict(dict)

for enemyId in objects:
    enemy = objects[enemyId]
    if len(screenEnemies[enemy['screenId']]) == 0:
        screenEnemies[enemy['screenId']] = []
    screenEnemies[enemy['screenId']].append(enemy)

enemiesPerScreen = []

if arcadeMode == 1:
    if arcadeModeFirstScreen != 0:
        initialScreen = arcadeModeFirstScreen
    else:
        initialScreen = 0

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
                            horizontalDirection = '255'
                        else:
                            horizontalDirection = '1'

                        if (int(enemy['linIni']) > int(enemy['linEnd'])):
                            verticalDirection = '1'
                        else:
                            verticalDirection = '255'

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
                        arrayBuffer.append(int(enemy['move']))
                        arrayBuffer.append(int(verticalDirection))                  
                        arrayBuffer.append(int(enemy['speed']))
                        arrayBuffer.append(int(enemy['id']))               
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
                        arrayBuffer.append(0)
                        arrayBuffer.append(0) 
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
                    arrayBuffer.append(0)
                enemiesPerScreen.append(0)
            enemiesArray.append(array.array('B', arrayBuffer))

enemiesInScreenOffsets = []
enemiesInScreenOffsets.append(0)
currentOffset = 0
for idx, enemiesScreen in enumerate(enemiesArray):
    label = 'enemiesInScreen' + str(idx).zfill(3)
    with open(outputDir + label + '.bin', 'wb') as f:
        enemiesScreen.tofile(f)
    subprocess.run([ZX0_EXEC, '-f', outputDir + label + '.bin', outputDir + label + '.bin.zx0'])
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

# get hud.json
hudFile = open(outputDir + 'hud.json')
hudData = json.load(hudFile)
hudFile.close()

for i in hudData['layers'][1]['objects']:
    if i['name'] == "life":
        configStr += "#DEFINE HUD_LIFE_X " + str((i['x']//8)) + "\n"
        configStr += "#DEFINE HUD_LIFE_Y " + str((i['y']//8) - 1) + "\n"
    elif i['name'] == "ammo":
        if ammo > -1:
            configStr += "#DEFINE HUD_AMMO_X " + str((i['x']//8)) + "\n"
            configStr += "#DEFINE HUD_AMMO_Y " + str((i['y']//8) - 1) + "\n"
    elif i['name'] == "keys":
        if keysEnabled == 1:
            configStr += "#DEFINE HUD_KEYS_X " + str((i['x']//8)) + "\n"
            configStr += "#DEFINE HUD_KEYS_Y " + str((i['y']//8) - 1) + "\n"
    elif i['name'] == "score":
        if hiScore == 1:
            configStr += "#DEFINE HUD_HISCORE_X " + str((i['x']//8)) + "\n"
            configStr += "#DEFINE HUD_HISCORE_Y " + str((i['y']//8) - 1) + "\n"
            configStr += "#DEFINE HUD_HISCORE_Y_2 " + str((i['y']//8)) + "\n"
    elif i['name'] == "items":
        if itemsEnabled == 1:
            configStr += "#DEFINE HUD_ITEMS_X " + str((i['x']//8)) + "\n"
            configStr += "#DEFINE HUD_ITEMS_Y " + str((i['y']//8) - 1) + "\n"
    elif i['name'] == "fuel":
        if jetPackFuel > 0:
            configStr += "#DEFINE HUD_JETPACK_FUEL_X " + str((i['x']//8)) + "\n"
            configStr += "#DEFINE HUD_JETPACK_FUEL_Y " + str((i['y']//8) - 1) + "\n"
    elif i['name'] == "messages":
        if messagesEnabled == 1:
            configStr += "#DEFINE HUD_MESSAGE_X " + str((i['x']//8)) + "\n"
            configStr += "#DEFINE HUD_MESSAGE_Y " + str((i['y']//8) - 1) + "\n"
            configStr += "#DEFINE HUD_MESSAGE_Y_2 " + str((i['y']//8)) + "\n"
    elif i['name'] == "timer":
        if timerSeconds > 0:
            configStr += "#DEFINE TIMER_ENABLED\n"
            configStr += "#DEFINE HUD_TIMER_X " + str((i['x']//8)) + "\n"
            configStr += "#DEFINE HUD_TIMER_Y " + str((i['y']//8) - 1) + "\n"
            configStr += "Dim initialTimerSeconds as ubyte = " + str(timerSeconds) + "\n"

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