import os
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

def tapsBuild(outputFile):    
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

    concatenateFiles(outputFile.with_suffix(".tap"), input_files)

def snaBuild(outputFile):
    runCommand("tap2sna.py --sim-load-config machine=128 " + str(outputFile.with_suffix(".tap")) + " " + str(outputFile.with_suffix(".z80")))

def exeBuild(outputFile):
    concatenateFiles(outputFile.with_suffix(".exe"), [BIN_FOLDER / "spectral.exe", outputFile.with_suffix(".z80")])
    concatenateFiles(outputFile.with_name(getProjectFileName() + "-RF").with_suffix(".exe"), [BIN_FOLDER / "spectral-rf.exe", outputFile.with_suffix(".z80")])

def linuxBuild(outputFile):
    concatenateFiles(outputFile.with_suffix(".linux"), [BIN_FOLDER / "spectral.linux", outputFile.with_suffix(".z80")])
    concatenateFiles(outputFile.with_name(getProjectFileName() + "-RF").with_suffix(".linux"), [BIN_FOLDER / "spectral-rf.linux", outputFile.with_suffix(".z80")])
    # run_command("chmod +x " + str(Path(DIST_FOLDER + getProjectFileName() + "-RF.linux")))
    # run_command("chmod +x " + str(Path(DIST_FOLDER + getProjectFileName() + ".linux")))

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


def removeTempFiles():
    for file in os.listdir("output"):
        if file.endswith(".zx0") or file.endswith(".bin") or file.endswith(".tap") or file.endswith(".bas"):
            os.remove(os.path.join("output", file))

def showFolderSelectionModal():
    import tkinter as tk
    from tkinter import filedialog

    root = tk.Tk()
    root.withdraw()  # Hide the root window

    # selected_folder = filedialog.askdirectory(initialdir=folder_path, title="Select Language Folder")

    folder_path = ASSETS_FOLDER / "texts"
    if len(os.listdir(folder_path)) > 0:
        folders = [d for d in os.listdir(folder_path) if os.path.isdir(os.path.join(folder_path, d))]

        # keep only folder with 2 letters
        folders = [f for f in folders if len(f) == 2]

    # buscar carpetas tambien en screens de 2 letras y añadirlas si no estan ya
    screens_path = ASSETS_FOLDER / "screens"
    if len(os.listdir(screens_path)) > 0:
        screens_folders = [d for d in os.listdir(screens_path) if os.path.isdir(os.path.join(screens_path, d))]

        # keep only folder with 2 letters
        screens_folders = [f for f in screens_folders if len(f) == 2]

        for folder in screens_folders:
            if folder not in folders:
                folders.append(folder)

    # Crear ventana modal
    selection = tk.StringVar(value="default")

    folders.insert(0, "default")

    def on_ok():
        win.destroy()

    win = tk.Toplevel(root)
    win_width = 400
    win_height = 60 + len(folders) * 30  # 60 para el label y botón, 30 por opción
    win.geometry(f"{win_width}x{win_height}")
    win.title("Select Language Folder")
    tk.Label(win, text="Select a language folder:").pack(anchor="w", padx=10, pady=5)
    for folder in folders:
        tk.Radiobutton(win, text=folder, variable=selection, value=folder).pack(anchor="w", padx=20)
    tk.Button(win, text="OK", command=on_ok).pack(pady=10)
    win.grab_set()
    win.protocol("WM_DELETE_WINDOW", on_ok)
    root.wait_window(win)

    selected_folder = selection.get()
    root.destroy()

    if selected_folder in folders:
        return selected_folder
    else:
        return None

def build():
    global totalExecutionTime
    totalExecutionTime = 0

    selected_folder = showFolderSelectionModal()

    if selected_folder is None:
        selected_folder = "default"

    os.environ["ZXSGM_I18N_FOLDER"] = str(selected_folder)

    print(f"Compiling for language: {selected_folder}\n")

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
