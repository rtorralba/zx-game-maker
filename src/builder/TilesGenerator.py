import os
from pathlib import Path
from builder.helper import MAP_FOLDER

class TilesGenerator:
    def execute(self):
        tilesPath = str(Path(MAP_FOLDER + "tiles.zxp"))

        os.system("zxp2gus -t tiles -i " + tilesPath + " -o " + MAP_FOLDER + " -f png")
        os.system("zxp2gus -t tiles -i " + tilesPath + " -o output -f bin")