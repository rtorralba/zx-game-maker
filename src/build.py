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

TILED_SCRIPT = str(Path("bin/tiled-build.py"))

DEFAULT_FX = str(Path("default/fx.tap"))

def tiledBuild():
    runPythonScript(TILED_SCRIPT)

def buildingFilesAndConfig():
    return Builder().execute()

def compilingGame():
    runCommand("zxbc -W160 -W170 -W130 -W190 -W150 -W100 -H 128 --heap-address 23755 -S 24576 -O 4 " + str(Path("boriel/main.bas")) + " --mmap " + str(Path("output/map.txt")) + " -D HIDE_LOAD_MSG -o " + str(Path("output/main.bin")))

def checkMemory():
    runPythonScript("bin/check-memory.py")

def tapsBuild():
    OUTPUT_FILE = str(Path(DIST_FOLDER + getProjectFileName() + ".tap"))
    
    runCommand("bin2tap " + str(Path("bin/loader.bin")) + " " + str(Path("output/loader.tap")) + " 10 --header \"" + getProjectName() + "\" --block_type 1")
    runCommand("bin2tap " + str(Path("output/loading.bin")) + " " + str(Path("output/loading.tap")) + " 16384")
    runCommand("bin2tap " + str(Path("output/main.bin")) + " " + str(Path("output/main.tap")) + " 24576")

    if getEnabled128K():
        runCommand("bin2tap " + str(Path("output/title.scr.zx0")) + " " + str(Path("output/title.tap")) + " 49152")
        runCommand("bin2tap " + str(Path("output/ending.scr.zx0")) + " " + str(Path("output/ending.tap")) + " 16384")
        runCommand("bin2tap " + str(Path("output/hud.scr.zx0")) + " " + str(Path("output/hud.tap")) + " 24576")
        input_files = [
            str(Path("output/loader.tap")),
            str(Path("output/loading.tap")),
            str(Path("output/main.tap")),
            str(Path(ASSETS_FOLDER + "fx/fx.tap")),
            str(Path("output/files.tap")),
            str(Path(ASSETS_FOLDER + "music/title.tap")),
            str(Path(ASSETS_FOLDER + "music/music.tap")),
            str(Path("output/title.tap")),
            str(Path("output/ending.tap")),
            str(Path("output/hud.tap"))
        ]

        if not musicExists("title"):
            input_files.remove(str(Path(ASSETS_FOLDER + "music/title.tap")))

        if os.path.isfile("output/intro.scr.zx0"):
            runCommand("bin2tap " + str(Path("output/intro.scr.zx0")) + " " + str(Path("output/intro.tap")) + " 49152")
            input_files.append("output/intro.tap")
        
        if os.path.isfile("output/gameover.scr.zx0"):
            runCommand("bin2tap " + str(Path("output/gameover.scr.zx0")) + " " + str(Path("output/gameover.tap")) + " 49152")
            input_files.append("output/gameover.tap")
    else:
        input_files = [
            str(Path("output/loader.tap")),
            str(Path("output/loading.tap")),
            str(Path("output/main.tap")),
            str(Path(ASSETS_FOLDER + "fx/fx.tap")),
            str(Path("output/files.tap")),
        ]

    concatenateFiles(OUTPUT_FILE, input_files)

def snaBuild():
    runCommand("tap2sna.py --sim-load-config machine=128 " + str(Path(DIST_FOLDER + getProjectFileName() + ".tap")) + " " + str(Path(DIST_FOLDER + getProjectFileName() + ".z80")))

def exeBuild():
    concatenateFiles(str(Path(DIST_FOLDER + getProjectFileName() + ".exe")), [str(Path("bin/spectral.exe")), str(Path(DIST_FOLDER + getProjectFileName() + ".z80"))])
    concatenateFiles(str(Path(DIST_FOLDER + getProjectFileName() + "-RF.exe")), [str(Path("bin/spectral-rf.exe")), str(Path(DIST_FOLDER + getProjectFileName() + ".z80"))])

def linuxBuild():
    concatenateFiles(str(Path(DIST_FOLDER + getProjectFileName() + "-RF.linux")), [str(Path("bin/spectral-rf.linux")), str(Path(DIST_FOLDER + getProjectFileName() + ".z80"))])
    concatenateFiles(str(Path(DIST_FOLDER + getProjectFileName() + ".linux")), [str(Path("bin/spectral.linux")), str(Path(DIST_FOLDER + getProjectFileName() + ".z80"))])
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

    executeFunction(tiledExport, "Exporting game from Tiled")
    executeFunction(hudTiledExport, "Exporting HUD from Tiled")
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
