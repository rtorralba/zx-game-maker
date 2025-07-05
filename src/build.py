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

# python_executable = Path(sys.executable)

TILED_SCRIPT = Path("bin/tiled-build.py")

DEFAULT_FX = Path("default/fx.tap")

def tiledBuild():
    runPythonScript(TILED_SCRIPT)

def hudScrToPng():
    runCommand(["sna2img.py", SCREENS_FOLDER / "hud.scr", SCREENS_FOLDER / "hud.png"])

def buildingFilesAndConfig():
    return Builder().execute()

def compilingGame():
    runCommand(["zxbc", "-W160", "-W170", "-W130", "-W190", "-W150", "-W100", "-H 128", "--heap-address 23755", "-S 24576", "-O 4",
        Path("boriel/main.bas"), f"--mmap {OUTPUT_FOLDER / map.txt}", "-D HIDE_LOAD_MSG", f"-o {OUTPUT_FOLDER / main.bin}"])

def checkMemory():
    runPythonScript("bin/check-memory.py")

def tapsBuild():
    OUTPUT_FILE = Path(DIST_FOLDER, getProjectFileName()).with_suffix(".tap")

    runCommand(["bin2tap", Path("bin/loader.bin", OUTPUT_FOLDER / "loader.tap"), "10", f'--header "{getProjectName()}"', "--block_type 1"])
    runCommand(["bin2tap", OUTPUT_FOLDER / "loading.bin", OUTPUT_FOLDER / "loading.tap", "16384"])
    runCommand(["bin2tap", OUTPUT_FOLDER / "main.bin", OUTPUT_FOLDER / "main.tap", "24576"])

    if getEnabled128K():
        runCommand(["bin2tap", OUTPUT_FOLDER / "title.scr.zx0", OUTPUT_FOLDER / "title.tap", "49152"])
        runCommand(["bin2tap", OUTPUT_FOLDER / "ending.scr.zx0", OUTPUT_FOLDER / "ending.tap", "16384"])
        runCommand(["bin2tap", OUTPUT_FOLDER / "hud.scr.zx0", OUTPUT_FOLDER / "hud.tap", "24576"])
        input_files = [
            OUTPUT_FOLDER / "loader.tap",
            OUTPUT_FOLDER / "loading.tap",
            OUTPUT_FOLDER / "main.tap",
            ASSETS_FOLDER / "fx/fx.tap",
            OUTPUT_FOLDER / "files.tap",
            ASSETS_FOLDER / "music/title.tap",
            ASSETS_FOLDER / "music/music.tap",
            OUTPUT_FOLDER / "title.tap",
            OUTPUT_FOLDER / "ending.tap",
            OUTPUT_FOLDER / "hud.tap"
        ]

        if not musicExists("title"):
            input_files.remove(ASSETS_FOLDER / "music/title.tap")

        if Path(OUTPUT_FOLDER, "intro.scr.zx0").is_file():
            runCommand(["bin2tap", OUTPUT_FOLDER / "intro.scr.zx0", OUTPUT_FOLDER / "intro.tap", "49152"])
            input_files.append(OUTPUT_FOLDER / "intro.tap")
        
        if Path(OUTPUT_FOLDER, "gameover.scr.zx0").is_file():
            runCommand(["bin2tap", OUTPUT_FOLDER / "gameover.scr.zx0", OUTPUT_FOLDER / "gameover.tap", "49152"])
            input_files.append(OUTPUT_FOLDER / "gameover.tap")
    else:
        input_files = [
            OUTPUT_FOLDER / "loader.tap",
            OUTPUT_FOLDER / "loading.tap",
            OUTPUT_FOLDER / "main.tap",
            ASSETS_FOLDER / "fx/fx.tap",
            OUTPUT_FOLDER / "output/files.tap"
        ]

    concatenateFiles(output_file=OUTPUT_FILE, input_files=input_files)

def snaBuild():
    runCommand(["tap2sna.py", "--sim-load-config machine=128",
        DIST_FOLDER / Path(getProjectFileName()).with_suffix(".tap"),
        DIST_FOLDER / Path(getProjectFileName()).with_suffix(".z80")
        ])

def exeBuild():
    concatenateFiles(
        output_file = DIST_FOLDER / Path(getProjectFileName()).with_suffix(".exe"),
        input_files = [Path("bin/spectral.exe"), DIST_FOLDER / Path(getProjectFileName()).with_suffix(".z80")]
        )
    concatenateFiles(
        output_file = DIST_FOLDER / f"{getProjectFileName()}-RF.exe",
        input_files = [Path("bin/spectral-rf.exe"), DIST_FOLDER / Path(getProjectFileName()).with_suffix(".z80")]
        )

def linuxBuild():
    concatenateFiles(
        output_file = DIST_FOLDER / f"{getProjectFileName()}-RF.linux",
        input_files = [Path("bin/spectral-rf.linux"), DIST_FOLDER / Path(getProjectFileName()).with_suffix(".z80")]
        )
    concatenateFiles(
        output_file = DIST_FOLDER / Path(getProjectFileName()).with_suffix(".linux"),
        input_files = [Path("bin/spectral.linux"), DIST_FOLDER / Path(getProjectFileName()).with_suffix(".z80")]
        )
    # run_command("chmod +x " + str(DIST_FOLDER / Path(getProjectFileName()).with_suffix("-RF.linux")))
    # run_command("chmod +x " + str(DIST_FOLDER / Path(getProjectFileName()).with_suffix(".linux")))

def distBuild():
    tapsBuild()
    snaBuild()
    exeBuild()
    linuxBuild()


def removeTempFiles():
    for file in os.listdir("output"):
        if any(filter(file.endswith, [".zx0", ".bin", ".tap", ".bas"])):
            os.remove(OUTPUT_FOLDER / file)

def build():
    global totalExecutionTime
    totalExecutionTime = 0

    print("============================================")
    print("=          ZX SPECTRUM GAME MAKER          =")
    print("============================================")

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
