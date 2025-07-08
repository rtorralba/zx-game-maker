import os
import sys
from pathlib import Path
import subprocess

# Obtiene la ruta del script actual y cambia al subdirectorio src
script_dir = Path(__file__).resolve().parent
src_dir = script_dir / "src"
os.chdir(src_dir)

# Ejecuta launcher.py con el mismo intérprete de Python que ejecuta este script
subprocess.run([sys.executable, "launcher.py"])