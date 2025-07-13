import os
from pathlib import Path
from builder.helper import MAP_FOLDER

class TilesGenerator:
    def execute(self):
        tilesPath = MAP_FOLDER / "tiles.zxp"

        os.system("zxp2gus -t tiles -i " + str(tilesPath) + " -o " + str(MAP_FOLDER) + " -f png")
        os.system("zxp2gus -t tiles -i " + str(tilesPath) + " -o output -f bin")
