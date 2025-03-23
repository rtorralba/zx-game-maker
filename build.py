import os
import shutil
import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parent / 'src'))

from builder.Builder import Builder 
from builder.helper import *

if os.getenv('VIRTUAL_ENV') is None:
    print("Please activate the virtual environment before running this script.")
    sys.exit(1)

verbose = False

python_executable = str(Path(sys.executable)) + " "

TILED_SCRIPT = str(Path("src/bin/tiled-build.py"))

DEFAULT_FX = str(Path("src/default/fx.tap"))

def tiled_export():
    print("Exporting game from Tiled... ", end="")
    tiledExport()
    print("OK!")

def tiled_build():
    print("Building tiled into code... ", end="")
    runPythonScript(TILED_SCRIPT)
    print("OK!")

def check_fx():
    if not os.path.isdir("assets/fx"):
        print("FX folder not detected, creating... ", end="")
        os.makedirs(str(Path("assets/fx")))
        print("OK!")
    if not os.path.isfile("assets/fx/fx.tap"):
        print("FX not detected. Applying default... ", end="")
        shutil.copy(DEFAULT_FX, str(Path("assets/fx/fx.tap")))
        print("OK!")

def screens_build():
    print("Building screens... ", end="")
    Builder().execute()
    print("OK!")

def compiling_game():
    print("Compiling game... ", end="")
    runCommand("zxbc -H 128 --heap-address 23755 -S 24576 -O 4 " + str(Path("src/main.bas")) + " --mmap " + str(Path("output/map.txt")) + " -D HIDE_LOAD_MSG -o " + str(Path("output/main.bin")))
    print("OK!")

def check_memory():
    print("Checking memory... ", end="")
    runPythonScript("src/bin/check-memory.py")
    print("OK!")

def taps_build():
    OUTPUT_FILE = str(Path("dist/" + getProjectFileName() + ".tap"))
    
    runCommand("bin2tap " + str(Path("src/bin/loader.bin")) + " " + str(Path("output/loader.tap")) + " 10 --header \"" + getProjectName() + "\" --block_type 1")
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
            str(Path("assets/fx/fx.tap")),
            str(Path("output/files.tap")),
            str(Path("assets/music/title.tap")),
            str(Path("assets/music/music.tap")),
            str(Path("output/title.tap")),
            str(Path("output/ending.tap")),
            str(Path("output/hud.tap"))
        ]

        if not musicExists("title"):
            input_files.remove(str(Path("assets/music/title.tap")))

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
            str(Path("assets/fx/fx.tap")),
            str(Path("output/files.tap")),
        ]

    concatenateFiles(OUTPUT_FILE, input_files)

def sna_build():
    runCommand("tap2sna.py --sim-load-config machine=128 " + str(Path("dist/" + getProjectFileName() + ".tap")) + " " + str(Path("dist/" + getProjectFileName() + ".z80")))

def exe_build():
    concatenateFiles(str(Path("dist/" + getProjectFileName() + ".exe")), [str(Path("src/bin/spectral.exe")), str(Path("dist/" + getProjectFileName() + ".z80"))])
    concatenateFiles(str(Path("dist/" + getProjectFileName() + "-RF.exe")), [str(Path("src/bin/spectral-rf.exe")), str(Path("dist/" + getProjectFileName() + ".z80"))])

def linux_build():
    concatenateFiles(str(Path("dist/" + getProjectFileName() + "-RF.linux")), [str(Path("src/bin/spectral-rf.linux")), str(Path("dist/" + getProjectFileName() + ".z80"))])
    concatenateFiles(str(Path("dist/" + getProjectFileName() + ".linux")), [str(Path("src/bin/spectral.linux")), str(Path("dist/" + getProjectFileName() + ".z80"))])
    # run_command("chmod +x " + str(Path("dist/" + getProjectFileName() + "-RF.linux")))
    # run_command("chmod +x " + str(Path("dist/" + getProjectFileName() + ".linux")))

def dist_build():
    print("Building TAP, Z80 and EXE files... ", end="")
    taps_build()
    sna_build()
    exe_build()
    linux_build()
    print("OK!")


def remove_temp_files():
    print("Removing temporary files... ", end="")
    for file in os.listdir("output"):
        if file.endswith(".zx0") or file.endswith(".bin") or file.endswith(".tap") or file.endswith(".bas"):
            os.remove(os.path.join("output", file))
    print("OK!\n")

def build():
    print("============================================")
    print("=          ZX SPECTRUM GAME MAKER          =")
    print("============================================")

    tiled_export()

    if getEnabled128K():
        print("Mode 128K enabled!")
    else:
        print("Mode 48K enabled!")

    tiled_build()

    check_fx()

    screens_build()

    compiling_game()

    check_memory()

    dist_build()

    remove_temp_files()

    print("Game compiled successfully! You can find it at dist/" + getProjectFileName() + ".tap.\n")

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
