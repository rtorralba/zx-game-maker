import os
from pathlib import Path
from builder.helper import MAP_FOLDER

class SpritesGenerator:
    def execute(self):
        spritesPath = MAP_FOLDER / "sprites.zxp"

        os.system("zxp2gus -t sprites -i " + str(spritesPath) + " -o " + str(MAP_FOLDER) + " -f png")
