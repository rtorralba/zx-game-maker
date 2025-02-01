#!/usr/bin/env python3

import os
import shutil
import subprocess
import json
import sys
from pathlib import Path

#Get os
os_name = os.name

# Get the path separator
if os_name == "nt":
    path_separator = "\\"
    ZX0 = "zx0.exe"
else:
    path_separator = "/"
    ZX0 = "zx0"

python_executable = str(Path(sys.executable)) + " "

BIN_FOLDER = str(Path("src/bin/")) + path_separator
OUTPUT_FOLDER = str(Path("output/")) + path_separator
SCREENS_FOLDER = str(Path("assets/screens/")) + path_separator
MAP_FOLDER = str(Path("assets/map/")) + path_separator

# Leer el valor de enabled128K desde output/maps.json
with open(OUTPUT_FOLDER + "maps.json", "r") as f:
    maps_json = json.load(f)
enabled128K = any(prop["name"] == "128Kenabled" and prop["value"] for prop in maps_json["properties"])
useBreakableTile = any(prop["name"] == "useBreakableTile" and prop["value"] for prop in maps_json["properties"])

def run_command(command):
    result = subprocess.call(command, shell=True)
    if result != 0:
        print("Error executing command: {}".format(command))
        sys.exit(1)

def process_screen(screen_name):
    run_command(BIN_FOLDER + ZX0 + " -f " + SCREENS_FOLDER + screen_name + ".scr " + OUTPUT_FOLDER + screen_name + ".png.scr.zx0")

process_screen("title")
process_screen("ending")
process_screen("hud")

shutil.copy(SCREENS_FOLDER + "loading.scr", OUTPUT_FOLDER + "loading.bin")

tilesPath = str(Path("assets/map/tiles.zxp"))
spritesPath = str(Path("assets/map/sprites.zxp"))

os.system("zxp2gus -t tiles -i " + tilesPath + " -o " + MAP_FOLDER + " -f png")
os.system("zxp2gus -t sprites -i " + spritesPath + " -o " + MAP_FOLDER + " -f png")
os.system("zxp2gus -t tiles -i " + tilesPath + " -o output -f bin")
os.system("zxp2gus -t sprites -i " + spritesPath + " -o output -f bin")

# Archivo de salida
output_file = OUTPUT_FOLDER + "files.bin"

if os.path.isfile(output_file):
    os.remove(output_file)

if not enabled128K:
    files_to_concatenate = [
        OUTPUT_FOLDER + "title.png.scr.zx0",
        OUTPUT_FOLDER + "ending.png.scr.zx0",
        OUTPUT_FOLDER + "hud.png.scr.zx0",
    ]
    
    with open(output_file, 'wb') as outfile:
        for fname in files_to_concatenate:
            with open(fname, 'rb') as infile:
                outfile.write(infile.read())

input_files = [
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

if useBreakableTile:
    input_files.append(OUTPUT_FOLDER + "brokenTiles.bin")

# Concatenar archivos de entrada en el archivo de salida
with open(output_file, 'ab') as outfile:
    for fname in input_files:
        with open(fname, 'rb') as infile:
            outfile.write(infile.read())

SIZE0 = 49152

config_bas_path = OUTPUT_FOLDER + "config.bas"
if not enabled128K:
    with open(config_bas_path, 'a') as config_bas:
        config_bas.write("const BEEP_FX_ADDRESS as uinteger={}\n".format(SIZE0))
    SIZEFX = os.path.getsize("assets/fx/fx.tap")
else:
    SIZEFX = 0

if enabled128K:
    SIZE1 = 0
    SIZE2 = 0
    SIZE3 = 0
    SFX = os.path.getsize(Path("assets/fx/fx.tap"))
    S1 = os.path.getsize(Path("output/title.png.scr.zx0"))
    S2 = os.path.getsize(Path("output/ending.png.scr.zx0"))
    S3 = os.path.getsize(Path("output/hud.png.scr.zx0"))
    params = "FX:" + str(SFX) + ",Init-Screen:" + str(S1) + ",End-Screen:" + str(S2) + ",HUD:" + str(S3)

    if os.path.isfile(SCREENS_FOLDER + "intro.scr"):
        run_command(BIN_FOLDER + ZX0 + " -f " + SCREENS_FOLDER + "intro.scr " + OUTPUT_FOLDER + "intro.scr.zx0")
        S4 = os.path.getsize(OUTPUT_FOLDER + "intro.scr.zx0")
        params = "{},Intro-Screen:{}".format(params, S4)
    
    if os.path.isfile(SCREENS_FOLDER + "gameover.scr"):
        run_command(BIN_FOLDER + ZX0 + " -f " + SCREENS_FOLDER + "gameover.scr " + OUTPUT_FOLDER + "gameover.scr.zx0")
        S5 = os.path.getsize(OUTPUT_FOLDER + "gameover.scr.zx0")
        params = "{},GameOver-Screen:{}".format(params, S5)
    
    run_command(python_executable + BIN_FOLDER + "memoryImageGenerator.py " + params + " memory-bank-3.png")
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
        sizeFX = os.path.getsize(Path("assets/fx/fx.tap"))
        baseAddress = sizeFX + SIZE0
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

os.system("bin2tap " + output_file + " " + OUTPUT_FOLDER + "files.tap " + str(SIZE0))

enemiesSize = SIZE5 + SIZE11 + SIZE14 + SIZE15 + SIZE18
mapsSize = SIZE4 + SIZE10 + SIZE16 + SIZE17

params = "FX:" + str(SIZEFX) + ",Init-Screen:" + str(SIZE1) + ",End-Screen:" + str(SIZE2) + ",HUD:" + str(SIZE3) + ",Maps:" + str(mapsSize) + ",Enemies:" + str(enemiesSize) + ",Tileset:" + str(SIZE6) + ",Attributes:" + str(SIZE7) + ",Sprites:" + str(SIZE8) + ",Objects:" + str(SIZE9) + ",Damage-Tiles:" + str(SIZE13) + ",Animated-Tiles:" + str(SIZE12) + " memory-bank-0.png"
run_command(python_executable + BIN_FOLDER + "memoryImageGenerator.py " + params)
