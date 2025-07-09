import os
from pathlib import Path
from watchdog.events import FileSystemEventHandler
import zxp2gus.cli as zxp2gus

from builder.helper import MAP_FOLDER

WATCH_FILES = ["tiles.zxp", "sprites.zxp"]

class ZXPHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if not event.is_directory:
            file_path = Path(event.src_path)
            if file_path.name in WATCH_FILES:
                print(f"{file_path.name} modificado. Ejecutando conversión...")
                if file_path.name == "tiles.zxp":
                    os.system("zxp2gus -t tiles -i " + str(file_path) + " -o " + MAP_FOLDER + " -f png")
                elif file_path.name == "sprites.zxp":
                    os.system("zxp2gus -t sprites -i " + str(file_path) + " -o " + MAP_FOLDER + " -f png")
