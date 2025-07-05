import json
import os
import subprocess
import sys
from pathlib import Path
# import fileinput

# create function to get os separator
def getOsSeparator():
    if os.name == "nt":
        return "\\"
    else:
        return "/"

ASSETS_FOLDER = Path("../assets/")
BIN_FOLDER = Path("../src/bin/")
OUTPUT_FOLDER = Path("output/")
SCREENS_FOLDER = ASSETS_FOLDER / "screens"
MAP_FOLDER = ASSETS_FOLDER / "map"
# MAPS_FILE = ASSETS_FOLDER / "map/maps.tmx"
MAPS_FILE = MAP_FOLDER / "maps.tmx"
# HUD_MAP_FILE = ASSETS_FOLDER / "screens/hud.tmx"
HUD_MAP_FILE = SCREENS_FOLDER / "hud.tmx"
# MAPS_PROJECT = ASSETS_FOLDER / "map/maps.tiled-project"
MAPS_PROJECT = MAP_FOLDER / "maps.tiled-project"
DIST_FOLDER = Path("../dist")
INITIAL_ADDRESS = 49152
MEMORY_BANK_SIZE = 16384

EJECUTABLE_TILED = Path(os.environ["ProgramFiles"], "Tiled/tiled.exe") if os.name == "nt" else "tiled"

def getZx0():
    return "zx0.exe" if os.name == "nt" else "zx0"

verbose = False

def setVerbose(value):
    global verbose
    verbose = value

def runCommand(command):
    global verbose
    if verbose:
        result = subprocess.run(command).returncode
    else:
        result = subprocess.run(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode
    if result != 0:
        print(f"Error executing command: {command}")
        sys.exit(1)

def getPythonExecutable():
    return Path(sys.executable)

def runPythonScript(script):
    runCommand([getPythonExecutable(), script])

def getTiledExportCommand():
    return [EJECUTABLE_TILED, "--export-map json", MAPS_FILE, Path(OUTPUT_FOLDER,"maps.json")]

def tiledExport():
    runCommand(getTiledExportCommand())

def hudTiledExport():
    runCommand([EJECUTABLE_TILED, "--export-map json", HUD_MAP_FILE, Path(OUTPUT_FOLDER, "hud.json")])

def getProjectName():
    with Path(OUTPUT_FOLDER, "maps.json").open(mode="r") as f:
        maps_json = json.load(f)
    return next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "gameName"), "Game Name")

def getProjectFileName():
    return getProjectName().replace(" ", "-")

def getEnabled128K():
    with Path(OUTPUT_FOLDER, "maps.json").open(mode="r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "128Kenabled" and prop["value"] for prop in maps_json["properties"])

def getGameView():
    with Path(OUTPUT_FOLDER, "maps.json").open(mode="r") as f:
        maps_json = json.load(f)
    return next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "gameView"), 'side')

def getUseBreakableTile():
    with Path(OUTPUT_FOLDER, "maps.json").open(mode="r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "useBreakableTile" and prop["value"] for prop in maps_json["properties"])

def concatenateFiles(output_file=None, input_files=None):
    with open(output_file, "wb") as out_file:
        for file in input_files:
            with open(file, "rb") as in_file:
                out_file.write(in_file.read())

    # with open(output_file, "wb") as out_file:
    #     with fileinput.input(files=input_files, mode="rb") as f:
    #         out_file.write(f.read())

def screenExists(screen_name):  
    return Path(SCREENS_FOLDER, f"{screen_name}.scr").is_file()

def musicExists(music_name):
    return Path(ASSETS_FOLDER, "music", f"{music_name}.tap").is_file()
