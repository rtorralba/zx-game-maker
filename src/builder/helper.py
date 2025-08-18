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

from configuración.folders import BIN_FOLDER, OUTPUT_FOLDER, DIST_FOLDER, ASSETS_FOLDER, SCREENS_FOLDER, MAP_FOLDER, MAPS_FILE, HUD_MAP_FILE, MAPS_PROJECT, MUSIC_FOLDER
from configuración.memoria import INITIAL_ADDRESS, MEMORY_BANK_SIZE

# Detectar el sistema operativo para poder apuntar especificamente a MacOS
CURRENT_OS = platform.system()


def getZx0():
    if os.name == "nt":
        return "zx0.exe"
    elif CURRENT_OS == "Darwin": #MacOS
        return "zx0-mac"
    else:
        return "zx0"

verbose = False

def setVerbose(value):
    global verbose
    verbose = value

def runCommand(command):    # solo acepta listas, no cadenas
    global verbose
    if verbose:
        result = subprocess.run(command, shell=False).returncode
    else:
        # result = subprocess.run(command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode
        result = subprocess.run(command, shell=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode
    if result != 0:
        print("Error executing command: " + str(command))
        sys.exit(1)

def getPythonExecutable():
    return Path(sys.executable)

def runPythonScript(script):
    runCommand([getPythonExecutable()] + script)

def getTiledExportCommand():
    command = list()
    if os.name == "nt":
        program_files = os.environ["ProgramFiles"]
        command = [
            Path(program_files, "Tiled", "tiled.exe"),
            "--export-map", "json",
            MAPS_FILE,
            OUTPUT_FOLDER / "maps.json"
        ]
    elif CURRENT_OS == "Darwin":  # macOS
        applications = Path("/Applications") # Ruta standard en MacOS
        tiled_path = applications / "Tiled.app/Contents/MacOS/Tiled"
        if tiled_path.exists():
            command = [
                f'"{tiled_path}"',
                "--export-map", "json",
                f'"{MAPS_FILE}"',
                f'"{Path("output/maps.json")}"'
            ]
        else:
            print("Error: Tiled no está instalado en /Applications/Tiled.app")
            exit(1)
    else:
        command = ["tiled", "--export-map", "json", MAPS_FILE, OUTPUT_FOLDER / "maps.json"]
    return command

def tiledExport():
    runCommand(getTiledExportCommand())

def hudTiledExport():
    if os.name == "nt":
        program_files = os.environ["ProgramFiles"]
        command = [
            Path(program_files, "Tiled", "tiled.exe"),
            "--export-map", "json",
            HUD_MAP_FILE,
            OUTPUT_FOLDER / "hud.json"
        ]
    elif CURRENT_OS == "Darwin":  # macOS
        applications = Path("/Applications") # Ruta standard en MacOS
        tiled_path = applications / "Tiled.app/Contents/MacOS/Tiled"
        if tiled_path.exists():
            command = [
                f'"{tiled_path}"',
                "--export-map", "json",
                f'"{HUD_MAP_FILE}"',
                f'"{Path("output/hud.json")}"'
            ] 
        else:
            print("Error: Tiled no está instalado en /Applications/Tiled.app")
            exit(1)
    else:
        command = ["tiled", "--export-map", "json", HUD_MAP_FILE,  OUTPUT_FOLDER / "hud.json"]
    runCommand(command)

def getProjectName():
    with open(OUTPUT_FOLDER / "maps.json", "r") as f:
        maps_json = json.load(f)
    project_name = next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "gameName"), "Game Name")
    return project_name

def getProjectFileName():
    return getProjectName().replace(" ", "-")

def getEnabled128K():
    with open(OUTPUT_FOLDER / "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "128Kenabled" and prop["value"] for prop in maps_json["properties"])

def getMusicEnabled():
    with open(OUTPUT_FOLDER / "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "musicEnabled" and prop["value"] for prop in maps_json["properties"])

def getGameView():
    with open(OUTPUT_FOLDER / "maps.json", "r") as f:
        maps_json = json.load(f)
    return next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "gameView"), 'side')

def getUseBreakableTile():
    with open(OUTPUT_FOLDER / "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "useBreakableTile" and prop["value"] for prop in maps_json["properties"])

def concatenateFiles(output_file, input_files):
    with open(output_file, "wb") as out_file:
        for file in input_files:
            with open(file, "rb") as in_file:
                out_file.write(in_file.read())

def screenExists(screen_name):  
    return os.path.isfile((SCREENS_FOLDER / screen_name).with_suffix(".scr"))

def musicExists(music_name):
    return os.path.isfile((MUSIC_FOLDER / music_name).with_suffix(".tap"))
