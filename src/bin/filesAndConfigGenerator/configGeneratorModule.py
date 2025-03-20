from helper import *

def getDeclaration(name, address):
    return "const {}_ADDRESS as uinteger={}\n".format(name, address)

def writeConfigDeclaration(config_bas, name, address):
    config_bas.write(getDeclaration(name, address))

sizes = {}

def generateMemoryConfigAndCharts():
    enabled128K = getEnabled128K()
    useBreakableTile = getUseBreakableTile()

    INITIAL_ADDRESS = 49152

    sizes["BEEP_FX"] = getFileSize("assets/fx/fx.tap")
    sizes["TITLE_SCREEN"] = getOutputFileSize("title.scr.zx0")
    sizes["ENDING_SCREEN"] = getOutputFileSize("ending.scr.zx0")
    sizes["HUD_SCREEN"] = getOutputFileSize("hud.scr.zx0")
    sizes["MAPS_DATA"] = getOutputFileSize("map.bin.zx0")
    sizes["ENEMIES_DATA"] = getOutputFileSize("enemies.bin.zx0")
    sizes["TILESET_DATA"] = getOutputFileSize("tiles.bin")
    sizes["ATTR_DATA"] = getOutputFileSize("attrs.bin")
    sizes["SPRITES_DATA"] = getOutputFileSize("sprites.bin")
    sizes["SCREEN_OBJECTS_INITIAL_DATA"] = getOutputFileSize("objectsInScreen.bin")
    sizes["SCREEN_OFFSETS_DATA"] = getOutputFileSize("screenOffsets.bin")
    sizes["ENEMIES_IN_SCREEN_OFFSETS_DATA"] = getOutputFileSize("enemiesInScreenOffsets.bin")
    sizes["ANIMATED_TILES_IN_SCREEN_DATA"] = getOutputFileSize("animatedTilesInScreen.bin")
    sizes["DAMAGE_TILES_DATA"] = getOutputFileSize("damageTiles.bin")
    sizes["ENEMIES_PER_SCREEN_DATA"] = getOutputFileSize("enemiesPerScreen.bin")
    sizes["ENEMIES_PER_SCREEN_INITIAL_DATA"] = getOutputFileSize("enemiesPerScreen.bin")
    sizes["SCREEN_OBJECTS_DATA"] = getOutputFileSize("screenObjects.bin")
    sizes["SCREENS_WON_DATA"] = getOutputFileSize("screensWon.bin")
    sizes["DECOMPRESSED_ENEMIES_SCREEN_DATA"] = getOutputFileSize("decompressedEnemiesScreen.bin")

    if useBreakableTile:
        sizes["SIZE_BROKEN_TILES"] = getOutputFileSize("brokenTiles.bin")
    
    if enabled128K:
        sizes["MUSIC"] = getFileSize("assets/music/music.tap")
        sizes["INTRO"] = getOutputFileSize("intro.scr.zx0") if screenExists("intro") else 0
        sizes["GAME_OVER"] = getOutputFileSize("gameover.scr.zx0") if screenExists("gameover") else 0
    
    enemiesSize = sizes["ENEMIES_DATA"] + sizes["ENEMIES_IN_SCREEN_OFFSETS_DATA"] + sizes["ENEMIES_PER_SCREEN_DATA"] + sizes["ENEMIES_PER_SCREEN_INITIAL_DATA"] + sizes["DECOMPRESSED_ENEMIES_SCREEN_DATA"]
    mapsSize = sizes["MAPS_DATA"] + sizes["SCREEN_OFFSETS_DATA"] + sizes["SCREEN_OBJECTS_DATA"] + sizes["SCREENS_WON_DATA"]

    if enabled128K:
        paramsMap0 = "Maps:" + str(mapsSize) + ",Enemies:" + str(enemiesSize) + ",Tileset:" + str(sizes["TILESET_DATA"]) + ",Attributes:" + str(sizes["ATTR_DATA"]) + ",Sprites:" + str(sizes["SPRITES_DATA"]) + ",Objects:" + str(sizes["SCREEN_OBJECTS_INITIAL_DATA"]) + ",Damage-Tiles:" + str(sizes["DAMAGE_TILES_DATA"]) + ",Animated-Tiles:" + str(sizes["ANIMATED_TILES_IN_SCREEN_DATA"]) + " memory-bank-0-128K.png"
        paramsMap3 = "Title-Screen:" + str(sizes["TITLE_SCREEN"]) + ",End-Screen:" + str(sizes["ENDING_SCREEN"]) + ",HUD:" + str(sizes["HUD_SCREEN"]) + ",Intro-Screen:" + str(sizes["INTRO"]) + ",GameOver-Screen:" + str(sizes["GAME_OVER"]) + " memory-bank-3.png"
        paramsMap4 = "FX:" + str(sizes["BEEP_FX"]) + ",Music:" + str(sizes["MUSIC"]) + " memory-bank-4.png"

        generateMemoryChart(paramsMap3)
        generateMemoryChart(paramsMap4)
    else:
        paramsMap0 = "FX:" + str(sizes["BEEP_FX"]) + ",Title-Screen:" + str(sizes["TITLE_SCREEN"]) + ",End-Screen:" + str(sizes["ENDING_SCREEN"]) + ",HUD:" + str(sizes["HUD_SCREEN"]) + ",Maps:" + str(mapsSize) + ",Enemies:" + str(enemiesSize) + ",Tileset:" + str(sizes["TILESET_DATA"]) + ",Attributes:" + str(sizes["ATTR_DATA"]) + ",Sprites:" + str(sizes["SPRITES_DATA"]) + ",Objects:" + str(sizes["SCREEN_OBJECTS_INITIAL_DATA"]) + ",Damage-Tiles:" + str(sizes["DAMAGE_TILES_DATA"]) + ",Animated-Tiles:" + str(sizes["ANIMATED_TILES_IN_SCREEN_DATA"]) + " memory-bank-0-48K.png"

    generateMemoryChart(paramsMap0)

    currentAddress = INITIAL_ADDRESS

    config_bas_path = OUTPUT_FOLDER + "config.bas"

    with open(config_bas_path, 'a') as config_bas:
        if enabled128K:
            config_bas.write("\n' Memory bank 3\n")
            writeConfigDeclaration(config_bas, "TITLE_SCREEN", currentAddress)
            currentAddress += sizes["TITLE_SCREEN"]
            writeConfigDeclaration(config_bas, "ENDING_SCREEN", currentAddress)
            currentAddress += sizes["ENDING_SCREEN"]
            writeConfigDeclaration(config_bas, "HUD_SCREEN", currentAddress)
            currentAddress += sizes["HUD_SCREEN"]

            if screenExists("intro"):
                writeConfigDeclaration(config_bas, "INTRO_SCREEN", currentAddress)
                config_bas.write("#DEFINE INTRO_SCREEN_ENABLED\n")
                currentAddress += sizes["INTRO"]
            
            if screenExists("gameover"):
                writeConfigDeclaration(config_bas, "GAMEOVER_SCREEN", currentAddress)
                config_bas.write("#DEFINE GAMEOVER_SCREEN_ENABLED\n")
                currentAddress += sizes["GAME_OVER"]
            
            config_bas.write("\n")
            currentAddress = INITIAL_ADDRESS
        else:
            currentAddress += sizes["BEEP_FX"]
            writeConfigDeclaration(config_bas, "TITLE_SCREEN", currentAddress)
            currentAddress += sizes["TITLE_SCREEN"]
            writeConfigDeclaration(config_bas, "ENDING_SCREEN", currentAddress)
            currentAddress += sizes["ENDING_SCREEN"]
            writeConfigDeclaration(config_bas, "HUD_SCREEN", currentAddress)
            currentAddress += sizes["HUD_SCREEN"]

        for key in sizes:
            if key == "BEEP_FX" or key == "TITLE_SCREEN" or key == "ENDING_SCREEN" or key == "HUD_SCREEN" or key == "INTRO_SCREEN" or key == "GAMEOVER_SCREEN" or key == "BROKEN_TILES_DATA":
                continue
            writeConfigDeclaration(config_bas, key, currentAddress)
            currentAddress += sizes[key]

        if useBreakableTile:
            writeConfigDeclaration(config_bas, "BROKEN_TILES_DATA", currentAddress)