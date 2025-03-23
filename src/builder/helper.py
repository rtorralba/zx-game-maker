import os
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

BIN_FOLDER = str(Path("src/bin/")) + getOsSeparator()
OUTPUT_FOLDER = str(Path("output/")) + getOsSeparator()
SCREENS_FOLDER = str(Path("assets/screens/")) + getOsSeparator()
MAP_FOLDER = str(Path("assets/map/")) + getOsSeparator()
MAPS_FILE = str(Path("assets/map/maps.tmx"))
DIST_FOLDER = str(Path("dist/")) + getOsSeparator()
INITIAL_ADDRESS = 49152
MEMORY_BANK_SIZE = 16384

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
    else:
        return "tiled --export-map json " + MAPS_FILE + " " + str(Path("output/maps.json"))

def tiledExport():
    runCommand(getTiledExportCommand())

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
    return os.path.isfile("assets/music/" + music_name + ".tap")