import os
import platform
import sys
from pathlib import Path
import json
import subprocess

# create function to get os separator
def getOsSeparator():
    if os.name == "nt":
        return "\\"
    else:
        return "/"
    
ASSETS_FOLDER = str(Path("../assets/")) + getOsSeparator()
BIN_FOLDER = str(Path("../src/bin/")) + getOsSeparator()
OUTPUT_FOLDER = str(Path("output/")) + getOsSeparator()
SCREENS_FOLDER = str(Path(ASSETS_FOLDER + "screens/")) + getOsSeparator()
MAP_FOLDER = str(Path(ASSETS_FOLDER + "map/")) + getOsSeparator()
MAPS_FILE = str(Path(ASSETS_FOLDER + "map/maps.tmx"))
HUD_MAP_FILE = str(Path(ASSETS_FOLDER + "screens/hud.tmx"))
MAPS_PROJECT = str(Path(ASSETS_FOLDER + "map/maps.tiled-project"))
DIST_FOLDER = str(Path("../dist/")) + getOsSeparator()
INITIAL_ADDRESS = 49152
MEMORY_BANK_SIZE = 16384

# Detectar el sistema operativo para poder apuntar especificamente a MacOS
CURRENT_OS = platform.system()


def getZx0():
    if os.name == "nt":
        return "zx0.exe"
    else:
        return "zx0"

verbose = False

def setVerbose(value):
    global verbose
    verbose = value

def runCommand(command):
    global verbose
    if verbose:
        result = subprocess.call(command, shell=True)
    else:
        result = subprocess.call(command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if result != 0:
        print("Error executing command: " + command)
        sys.exit(1)

def getPythonExecutable():
    return str(Path(sys.executable)) + " "

def runPythonScript(script):
    runCommand(getPythonExecutable() + script)

def getTiledExportCommand():
    if os.name == "nt":
        program_files = os.environ["ProgramFiles"]
        return "\"" + program_files + "\\Tiled\\tiled.exe\" --export-map json " + MAPS_FILE + " " + str(Path("output/maps.json"))
    elif CURRENT_OS == "Darwin":  # macOS
        applications = "/Applications" # Ruta standard en MacOS
        tiled_path = os.path.join(applications, "Tiled.app/Contents/MacOS/Tiled")
        if os.path.exists(tiled_path):
            command = f'"{tiled_path}" --export-map json "{MAPS_FILE}" "{str(Path("output/maps.json"))}"'
            return command
        else:
            print("Error: Tiled no está instalado en /Applications/Tiled.app")
            exit(1)
    else:
        return "tiled --export-map json " + MAPS_FILE + " " + str(Path("output/maps.json"))

def tiledExport():
    runCommand(getTiledExportCommand())

def hudTiledExport():
    if os.name == "nt":
        program_files = os.environ["ProgramFiles"]
        runCommand("\"" + program_files + "\\Tiled\\tiled.exe\" --export-map json " + HUD_MAP_FILE + " " + str(Path("output/hud.json")))
    elif CURRENT_OS == "Darwin":  # macOS
        applications = "/Applications" # Ruta standard en MacOS
        tiled_path = os.path.join(applications, "Tiled.app/Contents/MacOS/Tiled")
        if os.path.exists(tiled_path):
            command = f'"{tiled_path}" --export-map json "{HUD_MAP_FILE}" "{str(Path("output/hud.json"))}"'
            runCommand(command)
        else:
            print("Error: Tiled no está instalado en /Applications/Tiled.app")
            exit(1)
    else:
        runCommand("tiled --export-map json " + HUD_MAP_FILE + " " + str(Path("output/hud.json")))

def getProjectName():
    with open(str(Path("output/maps.json")), "r") as f:
        maps_json = json.load(f)
    project_name = next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "gameName"), "Game Name")
    return project_name

def getProjectFileName():
    return getProjectName().replace(" ", "-")

def getEnabled128K():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "128Kenabled" and prop["value"] for prop in maps_json["properties"])

def getMusicEnabled():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "musicEnabled" and prop["value"] for prop in maps_json["properties"])

def getGameView():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "gameView"), 'side')

def getUseBreakableTile():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "useBreakableTile" and prop["value"] for prop in maps_json["properties"])

def concatenateFiles(output_file, input_files):
    with open(output_file, "wb") as out_file:
        for file in input_files:
            with open(file, "rb") as in_file:
                out_file.write(in_file.read())

def screenExists(screen_name):  
    return os.path.isfile(SCREENS_FOLDER + screen_name + ".scr")

def musicExists(music_name):
    return os.path.isfile(ASSETS_FOLDER + "music/" + music_name + ".tap")