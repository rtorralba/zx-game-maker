import os
import sys
from pathlib import Path
import time
import shutil,subprocess
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

def tapsBuild(outputFile):    
    runCommand("zxbin2tap " + str(BIN_FOLDER / "loader.bin") + " " + str(OUTPUT_FOLDER / "loader.tap") + " 10 --header \"" + getProjectName() + "\" --block_type 1")
    runCommand("zxbin2tap " + str(OUTPUT_FOLDER / "loading.bin") + " " + str(OUTPUT_FOLDER / "loading.tap") + " 16384")
    runCommand("zxbin2tap " + str(OUTPUT_FOLDER / "main.bin") + " " + str(OUTPUT_FOLDER / "main.tap") + " 24576")

    if getEnabled128K():
        runCommand("zxbin2tap " + str(OUTPUT_FOLDER / "title.scr.zx0") + " " + str(OUTPUT_FOLDER / "title.tap") + " 49152")
        runCommand("zxbin2tap " + str(OUTPUT_FOLDER / "ending.scr.zx0") + " " + str(OUTPUT_FOLDER / "ending.tap") + " 16384")
        runCommand("zxbin2tap " + str(OUTPUT_FOLDER / "hud.scr.zx0") + " " + str(OUTPUT_FOLDER / "hud.tap") + " 24576")
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
            str(OUTPUT_FOLDER / "music-stage-clear.tap"),
            str(OUTPUT_FOLDER / "music-intro.tap"),
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
            input_files.remove(str(OUTPUT_FOLDER / "music-stage-clear.tap"))
            input_files.remove(str(OUTPUT_FOLDER / "music-intro.tap"))
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
            
            if not musicExists("stage-clear"):
                input_files.remove(str(OUTPUT_FOLDER / "music-stage-clear.tap"))
            
            if not musicExists("intro"):
                input_files.remove(str(OUTPUT_FOLDER / "music-intro.tap"))

        if os.path.isfile(OUTPUT_FOLDER / "intro.scr.zx0"):
            runCommand("zxbin2tap " + str(OUTPUT_FOLDER / "intro.scr.zx0") + " " + str(OUTPUT_FOLDER / "intro.tap") + " 49152")
            input_files.append(OUTPUT_FOLDER / "intro.tap")
        
        if os.path.isfile(OUTPUT_FOLDER / "gameover.scr.zx0"):
            runCommand("zxbin2tap " + str(OUTPUT_FOLDER / "gameover.scr.zx0") + " " + str(OUTPUT_FOLDER / "gameover.tap") + " 49152")
            input_files.append(OUTPUT_FOLDER / "gameover.tap")
    else:
        input_files = [
            str(OUTPUT_FOLDER / "loader.tap"),
            str(OUTPUT_FOLDER / "loading.tap"),
            str(OUTPUT_FOLDER / "main.tap"),
            str(ASSETS_FOLDER / "fx/fx.tap"),
            str(OUTPUT_FOLDER / "files.tap"),
        ]

    concatenateFiles(outputFile.with_suffix(".tap"), input_files)

def snaBuild(outputFile):
    runCommand("tap2sna.py --sim-load-config machine=128 " + str(outputFile.with_suffix(".tap")) + " " + str(outputFile.with_suffix(".z80")))

def exeBuild(outputFile):
    concatenateFiles(outputFile.with_suffix(".exe"), [BIN_FOLDER / "spectral.exe", outputFile.with_suffix(".z80")])
    concatenateFiles(outputFile.with_name(getProjectFileName() + "-RF").with_suffix(".exe"), [BIN_FOLDER / "spectral-rf.exe", outputFile.with_suffix(".z80")])

def macBuild(outputFile):
    z=outputFile.with_suffix(".z80")
    for s in("","-RF"):
        src=BIN_FOLDER/("spectral.app" if s=="" else "spectral-rf.app")
        d=DIST_FOLDER/f"{getProjectFileName()}{s}.app"
        shutil.rmtree(d,ignore_errors=True);shutil.copytree(src,d)
        m=d/"Contents"/"MacOS";shutil.move(m/"spectral",m/"spectral.bin")
        (m/"spectral").write_text(f'''#!/bin/bash
DIR="$(cd "$(dirname "$0")"&&pwd)"
"$DIR/spectral.bin" -a "$DIR/{getProjectFileName()}.z80"
''')
        shutil.copy2(z,m/f"{getProjectFileName()}.z80")
        if os.name != 'nt':
            for p in(m/"spectral.bin",m/"spectral"):subprocess.run(["chmod","+x",str(p)])

def linuxBuild(outputFile):
    concatenateFiles(outputFile.with_suffix(".linux"), [BIN_FOLDER / "spectral.linux", outputFile.with_suffix(".z80")])
    concatenateFiles(outputFile.with_name(getProjectFileName() + "-RF").with_suffix(".linux"), [BIN_FOLDER / "spectral-rf.linux", outputFile.with_suffix(".z80")])
    #check if os is not windows to run chmod
    if os.name != 'nt':
        runCommand("chmod +x " + str(outputFile.with_name(getProjectFileName() + "-RF").with_suffix(".linux")))
        runCommand("chmod +x " + str(outputFile.with_suffix(".linux")))

def distBuild():
    outputFolder = DIST_FOLDER
    language = os.getenv("ZXSGM_I18N_FOLDER", "default")
    if language != "default":
        if not os.path.exists(DIST_FOLDER / language):
            os.makedirs(DIST_FOLDER / language)
        outputFolder = DIST_FOLDER / language

    outputFile = outputFolder / getProjectFileName()
    tapsBuild(outputFile)
    snaBuild(outputFile)
    exeBuild(outputFile)
    linuxBuild(outputFile)
    macBuild(outputFile)


def removeTempFiles():
    for file in os.listdir("output"):
        if file.endswith(".zx0") or file.endswith(".bin") or file.endswith(".tap") or file.endswith(".bas"):
            os.remove(os.path.join("output", file))

def build(verbose = False):
    global totalExecutionTime
    totalExecutionTime = 0

    setVerbose(verbose)

    print(f"Compiling for language: {os.getenv('ZXSGM_I18N_FOLDER', 'default')}\n")

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
