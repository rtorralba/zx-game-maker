import os

from helper import *

def generateMemoryConfigAndCharts():
    enabled128K = getEnabled128K()
    useBreakableTile = getUseBreakableTile()

    INITIAL_ADDRESS = 49152
    SIZE_FX = getFileSize("assets/fx/fx.tap")
    SIZE_TITLE = getOutputFileSize("title.scr.zx0")
    SIZE_ENDING = getOutputFileSize("ending.scr.zx0")
    SIZE_HUD = getOutputFileSize("hud.scr.zx0")

    config_bas_path = OUTPUT_FOLDER + "config.bas"

    with open(config_bas_path, 'a') as config_bas:
        config_bas.write("const BEEP_FX_ADDRESS as uinteger={}\n".format(INITIAL_ADDRESS))

    if enabled128K:
        SIZE1 = 0
        SIZE2 = 0
        SIZE3 = 0
        pngPrefix = "128K-"
        params = "Init-Screen:" + str(SIZE_TITLE) + ",End-Screen:" + str(SIZE_ENDING) + ",HUD:" + str(SIZE_HUD)

        if screenExists("intro"):
            params = "{},Intro-Screen:{}".format(params, getOutputFileSize("intro.scr.zx0"))
        
        if os.path.isfile(SCREENS_FOLDER + "gameover.scr"):
            params = "{},GameOver-Screen:{}".format(params, getOutputFileSize("gameover.scr.zx0"))
        
        generateMemoryChart(params + " " + pngPrefix + "memory-bank-3.png")

        SIZE_MUSIC = getFileSize("assets/music/music.tap")

        params = "FX:" + str(SIZE_FX) + ",Music:" + str(SIZE_MUSIC) + " " + pngPrefix + "memory-bank-4.png"
        generateMemoryChart(params)
    else:
        pngPrefix = "48K-"
        INITIAL_ADDRESS = SIZE_FX + INITIAL_ADDRESS
        SIZE1 = getOutputFileSize("title.scr.zx0")
        SIZE2 = getOutputFileSize("ending.scr.zx0")
        SIZE3 = getOutputFileSize("hud.scr.zx0")

    SIZE4 = getOutputFileSize("map.bin.zx0")
    SIZE5 = getOutputFileSize("enemies.bin.zx0")
    SIZE6 = getOutputFileSize("tiles.bin")
    SIZE7 = getOutputFileSize("attrs.bin")
    SIZE8 = getOutputFileSize("sprites.bin")
    SIZE9 = getOutputFileSize("objectsInScreen.bin")
    SIZE10 = getOutputFileSize("screenOffsets.bin")
    SIZE11 = getOutputFileSize("enemiesInScreenOffsets.bin")
    SIZE12 = getOutputFileSize("animatedTilesInScreen.bin")
    SIZE13 = getOutputFileSize("damageTiles.bin")
    SIZE14 = getOutputFileSize("enemiesPerScreen.bin")
    SIZE15 = getOutputFileSize("enemiesPerScreen.bin")
    SIZE16 = getOutputFileSize("screenObjects.bin")
    SIZE17 = getOutputFileSize("screensWon.bin")
    SIZE18 = getOutputFileSize("decompressedEnemiesScreen.bin")
    if useBreakableTile:
        SIZE19 = getOutputFileSize("brokenTiles.bin")

    tilesetAddress = INITIAL_ADDRESS + SIZE1 + SIZE2 + SIZE3 + SIZE4 + SIZE5
    attrAddress = tilesetAddress + SIZE6
    spriteAddress = attrAddress + SIZE7
    screenObjectsInitialAddress = spriteAddress + SIZE8
    screenOffsetsAddress = screenObjectsInitialAddress + SIZE9
    enemiesInScreenOffsetsAddress = screenOffsetsAddress + SIZE10
    animatedTilesInScreenAddress = enemiesInScreenOffsetsAddress + SIZE11
    damageTilesAddress = animatedTilesInScreenAddress + SIZE12
    enemiesPerScreenAddress = damageTilesAddress + SIZE13
    enemiesPerScreenInitialAddress = enemiesPerScreenAddress + SIZE14
    screenObjectsAddress = enemiesPerScreenInitialAddress + SIZE15
    screensWonAddress = screenObjectsAddress + SIZE16
    decompressedEnemiesScreenAddress = screensWonAddress + SIZE17

    enemiesSize = SIZE5 + SIZE11 + SIZE14 + SIZE15 + SIZE18
    mapsSize = SIZE4 + SIZE10 + SIZE16 + SIZE17

    if useBreakableTile:
        brokenTilesAddress = decompressedEnemiesScreenAddress + SIZE18

    if not enabled128K:
        with open(config_bas_path, 'a') as config_bas:
            config_bas.write("const TITLE_SCREEN_ADDRESS as uinteger={}\n".format(INITIAL_ADDRESS))

    address = INITIAL_ADDRESS + SIZE1

    if not enabled128K:
        with open(config_bas_path, 'a') as config_bas:
            config_bas.write("const ENDING_SCREEN_ADDRESS as uinteger={}\n".format(address))

    address += SIZE2

    if not enabled128K:
        with open(config_bas_path, 'a') as config_bas:
            config_bas.write("const HUD_SCREEN_ADDRESS as uinteger={}\n".format(address))

    address += SIZE3

    with open(config_bas_path, 'a') as config_bas:
        config_bas.write("const MAPS_DATA_ADDRESS as uinteger={}\n".format(address))
        address += SIZE4
        config_bas.write("const ENEMIES_DATA_ADDRESS as uinteger={}\n".format(address))
        config_bas.write("const TILESET_DATA_ADDRESS as uinteger={}\n".format(tilesetAddress))
        config_bas.write("const ATTR_DATA_ADDRESS as uinteger={}\n".format(attrAddress))
        config_bas.write("const SPRITES_DATA_ADDRESS as uinteger={}\n".format(spriteAddress))
        config_bas.write("const SCREEN_OBJECTS_INITIAL_DATA_ADDRESS as uinteger={}\n".format(screenObjectsInitialAddress))
        config_bas.write("const SCREEN_OFFSETS_DATA_ADDRESS as uinteger={}\n".format(screenOffsetsAddress))
        config_bas.write("const ENEMIES_IN_SCREEN_OFFSETS_DATA_ADDRESS as uinteger={}\n".format(enemiesInScreenOffsetsAddress))
        config_bas.write("const ANIMATED_TILES_IN_SCREEN_DATA_ADDRESS as uinteger={}\n".format(animatedTilesInScreenAddress))
        config_bas.write("const DAMAGE_TILES_DATA_ADDRESS as uinteger={}\n".format(damageTilesAddress))
        config_bas.write("const ENEMIES_PER_SCREEN_DATA_ADDRESS as uinteger={}\n".format(enemiesPerScreenAddress))
        config_bas.write("const ENEMIES_PER_SCREEN_INITIAL_DATA_ADDRESS as uinteger={}\n".format(enemiesPerScreenInitialAddress))
        config_bas.write("const SCREEN_OBJECTS_DATA_ADDRESS as uinteger={}\n".format(screenObjectsAddress))
        config_bas.write("const SCREENS_WON_DATA_ADDRESS as uinteger={}\n".format(screensWonAddress))
        config_bas.write("const DECOMPRESSED_ENEMIES_SCREEN_DATA_ADDRESS as uinteger={}\n".format(decompressedEnemiesScreenAddress))

        if useBreakableTile:
            config_bas.write("const BROKEN_TILES_DATA_ADDRESS as uinteger={}\n".format(brokenTilesAddress))

    if enabled128K:
        with open(config_bas_path, 'a') as config_bas:
            config_bas.write("\n' Memory bank 3\n")
            baseAddress = INITIAL_ADDRESS
            config_bas.write("const TITLE_SCREEN_ADDRESS as uinteger={}\n".format(baseAddress))
            titleAddress = getOutputFileSize("title.scr.zx0")
            baseAddress += titleAddress
            config_bas.write("const ENDING_SCREEN_ADDRESS as uinteger={}\n".format(baseAddress))
            endingAddress = getOutputFileSize("ending.scr.zx0")
            baseAddress += endingAddress
            config_bas.write("const HUD_SCREEN_ADDRESS as uinteger={}\n".format(baseAddress))

            if os.path.isfile(SCREENS_FOLDER + "intro.scr"):
                hudAddress = getOutputFileSize("hud.scr.zx0")
                baseAddress += hudAddress
                config_bas.write("const INTRO_SCREEN_ADDRESS as uinteger={}\n".format(baseAddress))
                config_bas.write("#DEFINE INTRO_SCREEN_ENABLED\n")
            
            if os.path.isfile(SCREENS_FOLDER + "gameover.scr"):
                introAddress = getOutputFileSize("intro.scr.zx0")
                baseAddress += introAddress
                config_bas.write("const GAMEOVER_SCREEN_ADDRESS as uinteger={}\n".format(baseAddress))
                config_bas.write("#DEFINE GAMEOVER_SCREEN_ENABLED\n")
            
        params = "Maps:" + str(mapsSize) + ",Enemies:" + str(enemiesSize) + ",Tileset:" + str(SIZE6) + ",Attributes:" + str(SIZE7) + ",Sprites:" + str(SIZE8) + ",Objects:" + str(SIZE9) + ",Damage-Tiles:" + str(SIZE13) + ",Animated-Tiles:" + str(SIZE12) + " " + pngPrefix + "memory-bank-0.png"
    else:
        params = "FX:" + str(SIZE_FX) + ",Init-Screen:" + str(SIZE1) + ",End-Screen:" + str(SIZE2) + ",HUD:" + str(SIZE3) + ",Maps:" + str(mapsSize) + ",Enemies:" + str(enemiesSize) + ",Tileset:" + str(SIZE6) + ",Attributes:" + str(SIZE7) + ",Sprites:" + str(SIZE8) + ",Objects:" + str(SIZE9) + ",Damage-Tiles:" + str(SIZE13) + ",Animated-Tiles:" + str(SIZE12) + " " + pngPrefix + "memory-bank-0.png"

    generateMemoryChart(params)