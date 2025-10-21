import os
from pathlib import Path
from configuration.folders import SRC_FOLDER
from watchdog.events import FileSystemEventHandler
from builder.helper import blackoutForbiddenSprites

WATCH_FILES = ["tiles.zxp", "sprites.zxp"]

class ZXPHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if not event.is_directory:
            file_path = Path(event.src_path)
            if file_path.name in WATCH_FILES:
                print(f"{file_path.name} modificado. Ejecutando conversión...")
                if file_path.name == "tiles.zxp":
                    os.system("zxp2gus -t tiles -i " + str(file_path) + " -o " + str(SRC_FOLDER) + " -f png")
                elif file_path.name == "sprites.zxp":
                    os.system("zxp2gus -t sprites -i " + str(file_path) + " -o " + str(SRC_FOLDER) + " -f png")
                    
                    # Limpiar sprites no permitidos
                    sprites_png = SRC_FOLDER / "sprites.png"
                    blackoutForbiddenSprites(sprites_png)

