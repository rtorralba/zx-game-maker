import os
import sys
from pathlib import Path
import subprocess

if sys.platform.startswith("win32"):
    try:
        import PIL  # Intentar importar Pillow
    except ImportError:
        print("Pillow no está instalado. Instalando...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    else:
        print("Pillow ya está instalado.")

# Obtiene la ruta del script actual y cambia al subdirectorio src
script_dir = Path(__file__).resolve().parent
src_dir = script_dir / "src"
os.chdir(src_dir)

# Ejecuta launcher.py con el mismo intérprete de Python que ejecuta este script
subprocess.run([sys.executable, "launcher.py"])