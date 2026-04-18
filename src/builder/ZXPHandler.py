import os
from pathlib import Path
from configuration.folders import ASSETS_FOLDER, SRC_FOLDER, UI_FOLDER, OUTPUT_FOLDER
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
                    os.system("zxp2gus -t sprites -i " + str(file_path) + " -o " + str(OUTPUT_FOLDER) + " -f png")

                    # Limpiar sprites no permitidos
                    sprites_png = SRC_FOLDER / "sprites.png"
                    blackoutForbiddenSprites(sprites_png)
                    
            # Si cambia el HUD en formato .scr (en assets/screens), generar hud.png
            if file_path.name == "hud.scr":
                try:
                    hud_scr = ASSETS_FOLDER / "screens" / "hud.scr"
                    hud_png = ASSETS_FOLDER / "screens" / "hud.png"
                    if hud_scr.exists():
                        # Usar la misma herramienta que en build.py
                        os.system(f"sna2img.py \"{hud_scr}\" \"{hud_png}\"")
                        print(f"HUD convertido a PNG: {hud_png}")
                    else:
                        print(f"No se encontró {hud_scr} para convertir a PNG")
                except Exception as e:
                    print(f"Error al convertir HUD: {e}")

