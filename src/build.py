import os
import shutil
import sys
from pathlib import Path
import time
sys.path.append(str(Path(__file__).resolve().parent / 'src'))

from builder.Builder import Builder 
from builder.helper import *

if os.getenv('VIRTUAL_ENV') is None:
    print("Please activate the virtual environment before running this script.")
    sys.exit(1)

verbose = False

totalExecutionTime = 0

python_executable = str(Path(sys.executable)) + " "

TILED_SCRIPT = BIN_FOLDER / "tiled-build.py"

def tiledBuild():
    runPythonScript(str(TILED_SCRIPT))

def hudScrToPng():
    runCommand("sna2img.py " + str(ASSETS_FOLDER / "screens/hud.scr") + " " + str(ASSETS_FOLDER / "screens/hud.png"))

def buildingFilesAndConfig():
    return Builder().execute()

def compilingGame():
    runCommand("zxbc -W160 -W170 -W130 -W190 -W150 -W100 -H 128 --heap-address 23755 -S 24576 -O 4 " + str(Path("boriel/main.bas")) + " --mmap " + str(OUTPUT_FOLDER / "map.txt") + " -D HIDE_LOAD_MSG -o " + str(OUTPUT_FOLDER / "main.bin"))

def checkMemory():
    runPythonScript(str(BIN_FOLDER / "check-memory.py"))

def tapsBuild():
    OUTPUT_FILE = str((DIST_FOLDER / getProjectFileName()).with_suffix(".tap"))
    
    runCommand("bin2tap " + str(BIN_FOLDER / "loader.bin") + " " + str(OUTPUT_FOLDER / "loader.tap") + " 10 --header \"" + getProjectName() + "\" --block_type 1")
    runCommand("bin2tap " + str(OUTPUT_FOLDER / "loading.bin") + " " + str(OUTPUT_FOLDER / "loading.tap") + " 16384")
    runCommand("bin2tap " + str(OUTPUT_FOLDER / "main.bin") + " " + str(OUTPUT_FOLDER / "main.tap") + " 24576")

    if getEnabled128K():
        runCommand("bin2tap " + str(OUTPUT_FOLDER / "title.scr.zx0") + " " + str(OUTPUT_FOLDER / "title.tap") + " 49152")
        runCommand("bin2tap " + str(OUTPUT_FOLDER / "ending.scr.zx0") + " " + str(OUTPUT_FOLDER / "ending.tap") + " 16384")
        runCommand("bin2tap " + str(OUTPUT_FOLDER / "hud.scr.zx0") + " " + str(OUTPUT_FOLDER / "hud.tap") + " 24576")
        input_files = [
            str(OUTPUT_FOLDER / "loader.tap"),
            str(OUTPUT_FOLDER / "loading.tap"),
            str(OUTPUT_FOLDER / "main.tap"),
            str(ASSETS_FOLDER / "fx/fx.tap"),
            str(OUTPUT_FOLDER / "files.tap"),
            str(BIN_FOLDER / "vtplayer.tap"),
            str(OUTPUT_FOLDER / "music.tap"),
            str(OUTPUT_FOLDER / "music-title.tap"),
            str(OUTPUT_FOLDER / "music2.tap"),
            str(OUTPUT_FOLDER / "music3.tap"),
            str(OUTPUT_FOLDER / "music-ending.tap"),
            str(OUTPUT_FOLDER / "music-gameover.tap"),
            str(OUTPUT_FOLDER / "title.tap"),
            str(OUTPUT_FOLDER / "ending.tap"),
            str(OUTPUT_FOLDER / "hud.tap")
        ]

        if not getMusicEnabled():
            input_files.remove(str(BIN_FOLDER / "vtplayer.tap"))
            input_files.remove(str(OUTPUT_FOLDER / "music.tap"))
            input_files.remove(str(OUTPUT_FOLDER / "music-title.tap"))
            input_files.remove(str(OUTPUT_FOLDER / "music2.tap"))
            input_files.remove(str(OUTPUT_FOLDER / "music3.tap"))
            input_files.remove(str(OUTPUT_FOLDER / "music-ending.tap"))
            input_files.remove(str(OUTPUT_FOLDER / "music-gameover.tap"))
        else:
            if not musicExists("title"):
                input_files.remove(str(OUTPUT_FOLDER / "music-title.tap"))
            
            if not musicExists("music2"):
                input_files.remove(str(OUTPUT_FOLDER / "music2.tap"))

            if not musicExists("music3"):
                input_files.remove(str(OUTPUT_FOLDER / "music3.tap"))
            
            if not musicExists("ending"):
                input_files.remove(str(OUTPUT_FOLDER / "music-ending.tap"))
            
            if not musicExists("gameover"):
                input_files.remove(str(OUTPUT_FOLDER / "music-gameover.tap"))

        if os.path.isfile(OUTPUT_FOLDER / "intro.scr.zx0"):
            runCommand("bin2tap " + str(OUTPUT_FOLDER / "intro.scr.zx0") + " " + str(OUTPUT_FOLDER / "intro.tap") + " 49152")
            input_files.append(OUTPUT_FOLDER / "intro.tap")
        
        if os.path.isfile(OUTPUT_FOLDER / "gameover.scr.zx0"):
            runCommand("bin2tap " + str(OUTPUT_FOLDER / "gameover.scr.zx0") + " " + str(OUTPUT_FOLDER / "gameover.tap") + " 49152")
            input_files.append(OUTPUT_FOLDER / "gameover.tap")
    else:
        input_files = [
            str(OUTPUT_FOLDER / "loader.tap"),
            str(OUTPUT_FOLDER / "loading.tap"),
            str(OUTPUT_FOLDER / "main.tap"),
            str(ASSETS_FOLDER / "fx/fx.tap"),
            str(OUTPUT_FOLDER / "files.tap"),
        ]

    concatenateFiles(OUTPUT_FILE, input_files)

def snaBuild():
    runCommand("tap2sna.py --sim-load-config machine=128 " + str((DIST_FOLDER / getProjectFileName()).with_suffix(".tap")) + " " + str((DIST_FOLDER / getProjectFileName()).with_suffix(".z80")))

def exeBuild():
    concatenateFiles((DIST_FOLDER / getProjectFileName()).with_suffix(".exe"), [BIN_FOLDER / "spectral.exe", (DIST_FOLDER / getProjectFileName()).with_suffix(".z80")])
    concatenateFiles(DIST_FOLDER / (getProjectFileName() + "-RF.exe"), [BIN_FOLDER / "spectral-rf.exe", (DIST_FOLDER / getProjectFileName()).with_suffix(".z80")])

def linuxBuild():
    concatenateFiles(DIST_FOLDER / (getProjectFileName() + "-RF.linux"), [BIN_FOLDER / "spectral-rf.linux", (DIST_FOLDER / getProjectFileName()).with_suffix(".z80")])
    concatenateFiles((DIST_FOLDER / getProjectFileName()).with_suffix(".linux"), [BIN_FOLDER / "spectral.linux", (DIST_FOLDER / getProjectFileName()).with_suffix(".z80")])
    # run_command("chmod +x " + str(Path(DIST_FOLDER + getProjectFileName() + "-RF.linux")))
    # run_command("chmod +x " + str(Path(DIST_FOLDER + getProjectFileName() + ".linux")))

def distBuild():
    tapsBuild()
    snaBuild()
    exeBuild()
    linuxBuild()


def removeTempFiles():
    for file in os.listdir("output"):
        if file.endswith(".zx0") or file.endswith(".bin") or file.endswith(".tap") or file.endswith(".bas"):
            os.remove(os.path.join("output", file))

def build():
    global totalExecutionTime
    totalExecutionTime = 0

    print("============================================")
    print("=          ZX SPECTRUM GAME MAKER          =")
    print("============================================")

    executeFunction(removeTempFiles, "Removing temporary files")
    executeFunction(tiledExport, "Exporting game from Tiled")
    executeFunction(hudTiledExport, "Exporting HUD from Tiled")
    executeFunction(hudScrToPng, "Converting HUD screen to PNG")
    executeFunction(tiledBuild, "Building Tiled maps")
    sizes = executeFunction(buildingFilesAndConfig, "Building files and config")
    executeFunction(compilingGame, "Compiling game")
    if getEnabled128K():
        executeFunction(checkMemory, "Checking memory")
    executeFunction(distBuild, "Building TAP, Z80 and EXE files")
    if not verbose:
        executeFunction(removeTempFiles, "Removing temporary files")

    print("\nTotal execution time: " + f"{totalExecutionTime:.2f}s")

    print("============================================\n")

    print("MEMORY USAGE:\n")

    if getEnabled128K():
        sizes.printAllSizesByMemoryBankFor128()
        mode = "128K"
    else:
        sizes.printAllSizesByMemoryBankFor48()
        mode = "48K"
    
    print("\nFor more detailed information about memory check bank charts (png) in dist folder.\n")

    print("Game compiled for " + mode + " successfully at dist/" + getProjectFileName() + ".tap!.\n")

def executeFunction(function, message):
    global totalExecutionTime

    print(message, end="", flush=True)  # Forzar el vaciado del búfer
    start_time = time.time()
    result = function()
    end_time = time.time()
    elapsed_time = end_time - start_time
    totalExecutionTime += elapsed_time
    padding = 33 - len(message)

    elapsedTimeLenght = len(f"{elapsed_time:.2f}s")

    paddingElapsed = 8 - elapsedTimeLenght

    print("." * padding + "OK!" + " " * paddingElapsed + f"{elapsed_time:.2f}s", flush=True)  # Forzar el vaciado del búfer

    return result

def printSizes(sizes):
    print("Sizes:")

def main():
    global verbose
    import argparse

    parser = argparse.ArgumentParser(description="Build and manage the ZX Spectrum game project.")
    parser.add_argument("-v", "--verbose", action="store_true", help="Show detailed output")
    
    args = parser.parse_args()
    verbose = args.verbose

    setVerbose(verbose) 

    build()

if __name__ == "__main__":
    main()
