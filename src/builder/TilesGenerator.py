import os
import subprocess
import zxp2gus.cli as zxp2gus
from pathlib import Path
from builder.helper import MAP_FOLDER

class TilesGenerator:
    def execute(self):
        tilesPath = Path(MAP_FOLDER, "tiles.zxp")

        # import zxp2gus.cli as zxp2gus
        zxp2gus.main(["-t", "tiles", "-i", str(tilesPath), "-o", str(MAP_FOLDER), "-f", "png"])
        zxp2gus.main(["-t", "tiles", "-i", str(tilesPath), "-o", "output", "-f", "bin"])
