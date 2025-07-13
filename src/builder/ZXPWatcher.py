import time
from pathlib import Path
import watchdog
from watchdog.observers import Observer

from builder.ZXPHandler import ZXPHandler
from builder.helper import MAP_FOLDER

DIR = MAP_FOLDER

class ZXPWatcher(watchdog.observers.Observer) :
    def start(self):
        observer = Observer()
        event_handler = ZXPHandler()
        observer.schedule(event_handler, str(DIR), recursive=False)
        observer.start()
        print("Vigilando cambios en assets/tiles.zxp y assets/sprites.zxp... (Ctrl+C para salir)")
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            observer.stop()
        observer.join()
    