import time
from pathlib import Path
import watchdog
from watchdog.observers import Observer

from builder.ZXPHandler import ZXPHandler
from builder.helper import MAP_FOLDER
from configuration.folders import ASSETS_FOLDER

# Vigilar además la carpeta assets/screens para detectar cambios en hud.scr
DIR = MAP_FOLDER
SCREENS_DIR = ASSETS_FOLDER / "screens"

class ZXPWatcher(watchdog.observers.Observer) :
    def start(self):
        observer = Observer()
        event_handler = ZXPHandler()
        observer.schedule(event_handler, str(DIR), recursive=False)
        # Añadir watcher para screens (hud.scr y otros)
        observer.schedule(event_handler, str(SCREENS_DIR), recursive=False)
        observer.start()
        print("Vigilando cambios en assets/tiles.zxp, assets/sprites.zxp y assets/screens... (Ctrl+C para salir)")
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            observer.stop()
        observer.join()
    