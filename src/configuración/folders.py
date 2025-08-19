from pathlib import Path
import tomllib

_fichero = Path("..", "configuración.toml")
if not _fichero.exists():
    raise FileNotFoundError(f"fichero de configuración ({_fichero.resolve()}) no encontrado")
with open(_fichero, mode="rb") as f:
    configuración = tomllib.load(f)
if not (all((x in configuración) for x in ("version", "src", "bin", "output", "config_file", "dist", "assets"))
    and all((x in configuración["assets"]) for x in ("folder", "screens", "map", "music", "i18n"))
    and all((x in configuración["assets"]["screens"]) for x in ("folder", "hud_map"))
    and all((x in configuración["assets"]["map"]) for x in ("folder", "maps_file", "maps_project"))):
    raise Exception(f"error en el fichero de configuración {_fichero} {configuración}")
versión = configuración.get("version", "?")
if versión != "ZX SPECTRUM GAME MAKER V1":
    raise Exception(f"versión incorrecta ({versión}) del fichero {_fichero}")
del _fichero

SRC_FOLDER = Path(configuración["src"])
BIN_FOLDER = Path(configuración["bin"])
OUTPUT_FOLDER = Path(configuración["output"])
CONFIG_FILE = Path(configuración["config_file"])
DIST_FOLDER = Path(configuración["dist"])
ASSETS_FOLDER = Path(configuración["assets"]["folder"])
SCREENS_FOLDER = Path(ASSETS_FOLDER, configuración["assets"]["screens"]["folder"])
MAP_FOLDER = Path(ASSETS_FOLDER, configuración["assets"]["map"]["folder"])
I18N_FOLDER = Path(ASSETS_FOLDER, configuración["assets"]["i18n"])
MAPS_FILE = Path(MAP_FOLDER, configuración["assets"]["map"]["maps_file"])
HUD_MAP_FILE = Path(SCREENS_FOLDER, configuración["assets"]["screens"]["hud_map"])
MAPS_PROJECT = Path(MAP_FOLDER, configuración["assets"]["map"]["maps_project"])
MUSIC_FOLDER = Path(ASSETS_FOLDER, configuración["assets"]["music"])
