from pathlib import Path
import os
from builder.helper import *

class BinaryFilesToTapMerger:
    def execute(self, is128k, useBreakableTile):
        output_file = OUTPUT_FOLDER + "files.bin"

        if os.path.isfile(output_file):
            os.remove(output_file)

        if not is128k:
            sizeFx = os.path.getsize(Path("assets/fx/fx.tap"))
            tapAddress = INITIAL_ADDRESS + sizeFx
            input_files = [
                OUTPUT_FOLDER + "title.scr.zx0",
                OUTPUT_FOLDER + "ending.scr.zx0",
                OUTPUT_FOLDER + "hud.scr.zx0",
            ]
        else:
            tapAddress = INITIAL_ADDRESS
            input_files = []

        input_files += [
            OUTPUT_FOLDER + "map.bin.zx0",
            OUTPUT_FOLDER + "enemies.bin.zx0",
            OUTPUT_FOLDER + "tiles.bin",
            OUTPUT_FOLDER + "attrs.bin",
            OUTPUT_FOLDER + "sprites.bin",
            OUTPUT_FOLDER + "objectsInScreen.bin",
            OUTPUT_FOLDER + "screenOffsets.bin",
            OUTPUT_FOLDER + "enemiesInScreenOffsets.bin",
            OUTPUT_FOLDER + "animatedTilesInScreen.bin",
            OUTPUT_FOLDER + "damageTiles.bin",
            OUTPUT_FOLDER + "enemiesPerScreen.bin",
            OUTPUT_FOLDER + "enemiesPerScreen.bin",
            OUTPUT_FOLDER + "screenObjects.bin",
            OUTPUT_FOLDER + "screensWon.bin",
            OUTPUT_FOLDER + "decompressedEnemiesScreen.bin"
        ]

        if useBreakableTile:
            input_files.append(OUTPUT_FOLDER + "brokenTiles.bin")

        concatenateFiles(output_file, input_files)

        os.system("bin2tap " + output_file + " " + OUTPUT_FOLDER + "files.tap " + str(tapAddress))