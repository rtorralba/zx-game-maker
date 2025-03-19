import sys
from pathlib import Path
import os
import shutil

sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from helper import *

START_ADDRESS = 49152

def compressScreen(screen_name):
    runCommand(BIN_FOLDER + getZx0() + " -f " + SCREENS_FOLDER + screen_name + ".scr " + OUTPUT_FOLDER + screen_name + ".scr.zx0")

def generateScreensFiles():
    compressScreen("title")
    compressScreen("ending")
    compressScreen("hud")

    if getEnabled128K():
        if screenExists("intro"):
            compressScreen("intro")
        if screenExists("gameover"):
            compressScreen("gameover")


    shutil.copy(SCREENS_FOLDER + "loading.scr", OUTPUT_FOLDER + "loading.bin")

def generateTilesAndSpritesFiles():
    tilesPath = str(Path("assets/map/tiles.zxp"))
    spritesPath = str(Path("assets/map/sprites.zxp"))

    os.system("zxp2gus -t tiles -i " + tilesPath + " -o " + MAP_FOLDER + " -f png")
    os.system("zxp2gus -t sprites -i " + spritesPath + " -o " + MAP_FOLDER + " -f png")
    os.system("zxp2gus -t tiles -i " + tilesPath + " -o output -f bin")
    os.system("zxp2gus -t sprites -i " + spritesPath + " -o output -f bin")

def concatenateBinariesIntoFileAndGenerateTap():
    output_file = OUTPUT_FOLDER + "files.bin"

    if os.path.isfile(output_file):
        os.remove(output_file)

    if not getEnabled128K():
        sizeFx = os.path.getsize(Path("assets/fx/fx.tap"))
        tapAddress = START_ADDRESS + sizeFx
        input_files = [
            OUTPUT_FOLDER + "title.scr.zx0",
            OUTPUT_FOLDER + "ending.scr.zx0",
            OUTPUT_FOLDER + "hud.scr.zx0",
        ]
    else:
        tapAddress = START_ADDRESS
        input_files = []

    input_files += [
        OUTPUT_FOLDER + "map.bin.zx0",
        OUTPUT_FOLDER + "enemies.bin.zx0",
        OUTPUT_FOLDER + "tiles.bin",
        OUTPUT_FOLDER + "attrs.bin",
        OUTPUT_FOLDER + "sprites.bin",
        OUTPUT_FOLDER + "objectsInScreen.bin",
        OUTPUT_FOLDER + "screenOffsets.bin",
        OUTPUT_FOLDER + "enemiesInScreenOffsets.bin",
        OUTPUT_FOLDER + "animatedTilesInScreen.bin",
        OUTPUT_FOLDER + "damageTiles.bin",
        OUTPUT_FOLDER + "enemiesPerScreen.bin",
        OUTPUT_FOLDER + "enemiesPerScreen.bin",
        OUTPUT_FOLDER + "screenObjects.bin",
        OUTPUT_FOLDER + "screensWon.bin",
        OUTPUT_FOLDER + "decompressedEnemiesScreen.bin"
    ]

    if getUseBreakableTile():
        input_files.append(OUTPUT_FOLDER + "brokenTiles.bin")

    concatenateFiles(output_file, input_files)
    
    os.system("bin2tap " + output_file + " " + OUTPUT_FOLDER + "files.tap " + str(tapAddress))