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

from configuration.folders import BIN_FOLDER, OUTPUT_FOLDER, DIST_FOLDER, ASSETS_FOLDER, SCREENS_FOLDER, MAP_FOLDER, MAPS_FILE, HUD_MAP_FILE, MAPS_PROJECT, MUSIC_FOLDER
from configuration.memoria import INITIAL_ADDRESS, MEMORY_BANK_SIZE

# Detectar el sistema operativo para poder apuntar especificamente a MacOS
CURRENT_OS = platform.system()


def getZx0():
    if os.name == "nt":
        return "salvador.exe"
    elif CURRENT_OS == "Darwin": #MacOS
        return "salvador-mac"
    else:
        return "salvador"

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
        return "\"" + program_files + "\\Tiled\\tiled.exe\" --export-map json " + str(MAPS_FILE) + \
        " " + str(OUTPUT_FOLDER / "maps.json")
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
        return "tiled --export-map json " + str(MAPS_FILE) + " " + str(OUTPUT_FOLDER / "maps.json")

def tiledExport():
    runCommand(getTiledExportCommand())

def hudTiledExport():
    if os.name == "nt":
        program_files = os.environ["ProgramFiles"]
        runCommand("\"" + program_files + "\\Tiled\\tiled.exe\" --export-map json " + str(HUD_MAP_FILE) +
                   " " + str(OUTPUT_FOLDER / "hud.json"))
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
        runCommand("tiled --export-map json " + str(HUD_MAP_FILE) + " " + str(OUTPUT_FOLDER / "hud.json"))

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

def blackoutForbiddenSprites(sprites_png_path):
    """
    Pone en negro los sprites prohibidos de una imagen de sprites 16x3.
    
    Args:
        sprites_png_path: Path al archivo sprites.png
    """
    from PIL import Image
    
    # Sprites no permitidos (array empieza en 0)
    sprites_to_black = [1, 2, 3, 4, 5, 6, 7, 9, 11, 12, 13, 14, 15, 17, 19, 21, 23, 25, 27, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47]
    
    if not os.path.exists(sprites_png_path):
        return
    
    img = Image.open(sprites_png_path)
    pixels = img.load()
    
    # Matriz de 16x3 sprites de 16x16 píxeles
    sprite_width = 16
    sprite_height = 16
    cols = 16
    
    for sprite_id in sprites_to_black:
        # Calcular posición del sprite en la matriz
        col = sprite_id % cols
        row = sprite_id // cols
        
        # Coordenadas del sprite
        x_start = col * sprite_width
        y_start = row * sprite_height
        
        # Poner todos los píxeles en negro
        for y in range(y_start, y_start + sprite_height):
            for x in range(x_start, x_start + sprite_width):
                pixels[x, y] = (0, 0, 0, 255)  # Negro con alpha
    
    img.save(sprites_png_path)
    print(f"✓ Sprites prohibidos limpiados en {Path(sprites_png_path).name}")
