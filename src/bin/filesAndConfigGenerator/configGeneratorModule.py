import os

from helper import *

def generateMemoryConfigAndCharts():
    enabled128K = getEnabled128K()
    useBreakableTile = getUseBreakableTile()

    SIZE0 = 49152
    SIZEFX = os.path.getsize("assets/fx/fx.tap")

    config_bas_path = OUTPUT_FOLDER + "config.bas"

    with open(config_bas_path, 'a') as config_bas:
        config_bas.write("const BEEP_FX_ADDRESS as uinteger={}\n".format(SIZE0))

    if enabled128K:
        pngPrefix = "128K-"
    else:
        pngPrefix = "48K-"

    if enabled128K:
        SIZE1 = 0
        SIZE2 = 0
        SIZE3 = 0
        
        S1 = os.path.getsize(Path("output/title.png.scr.zx0"))
        S2 = os.path.getsize(Path("output/ending.png.scr.zx0"))
        S3 = os.path.getsize(Path("output/hud.png.scr.zx0"))
        params = "Init-Screen:" + str(S1) + ",End-Screen:" + str(S2) + ",HUD:" + str(S3)

        if os.path.isfile(SCREENS_FOLDER + "intro.scr"):
            runCommand(BIN_FOLDER + getZx0() + " -f " + SCREENS_FOLDER + "intro.scr " + OUTPUT_FOLDER + "intro.scr.zx0")
            S4 = os.path.getsize(OUTPUT_FOLDER + "intro.scr.zx0")
            params = "{},Intro-Screen:{}".format(params, S4)
        
        if os.path.isfile(SCREENS_FOLDER + "gameover.scr"):
            runCommand(BIN_FOLDER + getZx0() + " -f " + SCREENS_FOLDER + "gameover.scr " + OUTPUT_FOLDER + "gameover.scr.zx0")
            S5 = os.path.getsize(OUTPUT_FOLDER + "gameover.scr.zx0")
            params = "{},GameOver-Screen:{}".format(params, S5)
        
        generateMemoryChart(params + " " + pngPrefix + "memory-bank-3.png")

        SFX = os.path.getsize(Path("assets/fx/fx.tap"))
        SMusic = os.path.getsize(Path("assets/music/music.tap"))

        params = "FX:" + str(SFX) + ",Music:" + str(SMusic) + " " + pngPrefix + "memory-bank-4.png"
        generateMemoryChart(params)
    else:
        SIZE0 = SIZEFX + SIZE0
        SIZE1 = os.path.getsize(Path(OUTPUT_FOLDER + "title.png.scr.zx0"))
        SIZE2 = os.path.getsize(Path(OUTPUT_FOLDER + "ending.png.scr.zx0"))
        SIZE3 = os.path.getsize(Path(OUTPUT_FOLDER + "hud.png.scr.zx0"))

    SIZE4 = os.path.getsize(Path(OUTPUT_FOLDER + "map.bin.zx0"))
    SIZE5 = os.path.getsize(Path(OUTPUT_FOLDER + "enemies.bin.zx0"))
    SIZE6 = os.path.getsize(Path(OUTPUT_FOLDER + "tiles.bin"))
    SIZE7 = os.path.getsize(Path(OUTPUT_FOLDER + "attrs.bin"))
    SIZE8 = os.path.getsize(Path(OUTPUT_FOLDER + "sprites.bin"))
    SIZE9 = os.path.getsize(Path(OUTPUT_FOLDER + "objectsInScreen.bin"))
    SIZE10 = os.path.getsize(Path(OUTPUT_FOLDER + "screenOffsets.bin"))
    SIZE11 = os.path.getsize(Path(OUTPUT_FOLDER + "enemiesInScreenOffsets.bin"))
    SIZE12 = os.path.getsize(Path(OUTPUT_FOLDER + "animatedTilesInScreen.bin"))
    SIZE13 = os.path.getsize(Path(OUTPUT_FOLDER + "damageTiles.bin"))
    SIZE14 = os.path.getsize(Path(OUTPUT_FOLDER + "enemiesPerScreen.bin"))
    SIZE15 = os.path.getsize(Path(OUTPUT_FOLDER + "enemiesPerScreen.bin"))
    SIZE16 = os.path.getsize(Path(OUTPUT_FOLDER + "screenObjects.bin"))
    SIZE17 = os.path.getsize(Path(OUTPUT_FOLDER + "screensWon.bin"))
    SIZE18 = os.path.getsize(Path(OUTPUT_FOLDER + "decompressedEnemiesScreen.bin"))
    if useBreakableTile:
        SIZE19 = os.path.getsize(Path(OUTPUT_FOLDER + "brokenTiles.bin"))

    tilesetAddress = SIZE0 + SIZE1 + SIZE2 + SIZE3 + SIZE4 + SIZE5
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
            config_bas.write("const TITLE_SCREEN_ADDRESS as uinteger={}\n".format(SIZE0))

    address = SIZE0 + SIZE1

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
            baseAddress = SIZE0
            config_bas.write("const TITLE_SCREEN_ADDRESS as uinteger={}\n".format(baseAddress))
            titleAddress = os.path.getsize(Path(OUTPUT_FOLDER + "title.png.scr.zx0"))
            baseAddress += titleAddress
            config_bas.write("const ENDING_SCREEN_ADDRESS as uinteger={}\n".format(baseAddress))
            endingAddress = os.path.getsize(Path(OUTPUT_FOLDER + "ending.png.scr.zx0"))
            baseAddress += endingAddress
            config_bas.write("const HUD_SCREEN_ADDRESS as uinteger={}\n".format(baseAddress))

            if os.path.isfile(SCREENS_FOLDER + "intro.scr"):
                hudAddress = os.path.getsize(OUTPUT_FOLDER + "hud.png.scr.zx0")
                baseAddress += hudAddress
                config_bas.write("const INTRO_SCREEN_ADDRESS as uinteger={}\n".format(baseAddress))
                config_bas.write("#DEFINE INTRO_SCREEN_ENABLED\n")
            
            if os.path.isfile(SCREENS_FOLDER + "gameover.scr"):
                introAddress = os.path.getsize(OUTPUT_FOLDER + "intro.scr.zx0")
                baseAddress += introAddress
                config_bas.write("const GAMEOVER_SCREEN_ADDRESS as uinteger={}\n".format(baseAddress))
                config_bas.write("#DEFINE GAMEOVER_SCREEN_ENABLED\n")
            
        params = "Maps:" + str(mapsSize) + ",Enemies:" + str(enemiesSize) + ",Tileset:" + str(SIZE6) + ",Attributes:" + str(SIZE7) + ",Sprites:" + str(SIZE8) + ",Objects:" + str(SIZE9) + ",Damage-Tiles:" + str(SIZE13) + ",Animated-Tiles:" + str(SIZE12) + " " + pngPrefix + "memory-bank-0.png"
    else:
        params = "FX:" + str(SIZEFX) + ",Init-Screen:" + str(SIZE1) + ",End-Screen:" + str(SIZE2) + ",HUD:" + str(SIZE3) + ",Maps:" + str(mapsSize) + ",Enemies:" + str(enemiesSize) + ",Tileset:" + str(SIZE6) + ",Attributes:" + str(SIZE7) + ",Sprites:" + str(SIZE8) + ",Objects:" + str(SIZE9) + ",Damage-Tiles:" + str(SIZE13) + ",Animated-Tiles:" + str(SIZE12) + " " + pngPrefix + "memory-bank-0.png"

    generateMemoryChart(params)