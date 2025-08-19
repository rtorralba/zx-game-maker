import os
import sys
from pathlib import Path
import subprocess

# Obtiene la ruta del script actual y cambia al subdirectorio src
script_dir = Path(__file__).resolve().parent
src_dir = script_dir / "src"
os.chdir(src_dir)

path_venv = src_dir / "venv"
path_venv_bin = path_venv / "bin"

if not (path_venv).exists():
    sys.exit("No existe el directorio del entorno virtual.")

entorno = dict(os.environ)
entorno.update({"PATH": f"{path_venv_bin}:{os.environ.get("PATH")}"})
entorno.update({"PYTHONPATH": str(path_venv)})
entorno.update({"VIRTUAL_ENV": str(path_venv)})

subprocess.run([path_venv_bin / "python", "launcher.py"], env=entorno)