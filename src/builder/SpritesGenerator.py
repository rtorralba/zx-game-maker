import os
from pathlib import Path
from builder.helper import MAP_FOLDER

class SpritesGenerator:
    def execute(self):
        spritesPath = str(Path(MAP_FOLDER + "/sprites.zxp"))

        os.system("zxp2gus -t sprites -i " + spritesPath + " -o " + MAP_FOLDER + " -f png")
        os.system("zxp2gus -t sprites -i " + spritesPath + " -o output -f bin")