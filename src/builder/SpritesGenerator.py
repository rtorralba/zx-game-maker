import os
import subprocess
import zxp2gus.cli as zxp2gus
from pathlib import Path
from builder.helper import MAP_FOLDER

class SpritesGenerator:
    def execute(self):
        spritesPath = Path(MAP_FOLDER, "sprites.zxp")

        # import zxp2gus.cli as zxp2gus
        zxp2gus.main(["-t", "sprites", "-i", str(spritesPath), "-o", str(MAP_FOLDER), "-f", "png"])
