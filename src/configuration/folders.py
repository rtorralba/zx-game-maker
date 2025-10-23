from pathlib import Path
import tomllib

_fichero = Path("..", "configuration.toml")
if not _fichero.exists():
    raise FileNotFoundError(f"fichero de configuration ({_fichero.resolve()}) no encontrado")
with open(_fichero, mode="rb") as f:
    configuration = tomllib.load(f)
if not (all((x in configuration) for x in ("version", "bin", "output", "dist", "assets"))
    and all((x in configuration["assets"]) for x in ("folder", "screens", "map"))
    and all((x in configuration["assets"]["screens"]) for x in ("folder", "hud_map"))
    and all((x in configuration["assets"]["map"]) for x in ("folder", "maps_file", "maps_project"))):
    raise Exception(f"error en el fichero de configuration {_fichero} {configuration}")
versión = configuration.get("version", "?")
if versión != "ZX SPECTRUM GAME MAKER V1":
    raise Exception(f"versión incorrecta ({versión}) del fichero {_fichero}")
del _fichero

SRC_FOLDER = Path(configuration["src"])
UI_FOLDER = Path(configuration["ui"])
BIN_FOLDER = Path(configuration["bin"])
OUTPUT_FOLDER = Path(configuration["output"])
CONFIG_FILE = Path(configuration["config_file"])
DIST_FOLDER = Path(configuration["dist"])
ASSETS_FOLDER = Path(configuration["assets"]["folder"])
SCREENS_FOLDER = Path(ASSETS_FOLDER, configuration["assets"]["screens"]["folder"])
MAP_FOLDER = Path(ASSETS_FOLDER, configuration["assets"]["map"]["folder"])
I18N_FOLDER = Path(ASSETS_FOLDER, configuration["assets"]["i18n"])
MAPS_FILE = Path(MAP_FOLDER, configuration["assets"]["map"]["maps_file"])
HUD_MAP_FILE = Path(SCREENS_FOLDER, configuration["assets"]["screens"]["hud_map"])
MAPS_PROJECT = Path(MAP_FOLDER, configuration["assets"]["map"]["maps_project"])
MUSIC_FOLDER = Path(ASSETS_FOLDER, configuration["assets"]["music"])
