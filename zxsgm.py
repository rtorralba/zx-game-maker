import os
import sys
from pathlib import Path
import subprocess

PROJECT_DIR = Path(__file__).resolve().parent
SRC_DIR = PROJECT_DIR / "src"
VENV_DIR = PROJECT_DIR / "venv"
REQUIREMENTS = PROJECT_DIR / "requirements.txt"

def ensure_venv_and_requirements():
    if sys.platform == "win32":
        python_path = VENV_DIR / "Scripts" / "python.exe"
        pip_path = VENV_DIR / "Scripts" / "pip.exe"
        venv_bin = VENV_DIR / "Scripts"
    else:
        python_path = VENV_DIR / "bin" / "python"
        pip_path = VENV_DIR / "bin" / "pip"
        venv_bin = VENV_DIR / "bin"

    if not VENV_DIR.exists():
        print("Creando entorno virtual...")
        subprocess.check_call([sys.executable, "-m", "venv", str(VENV_DIR)])
        print("Instalando dependencias en el entorno virtual...")
        subprocess.check_call([str(pip_path), "install", "-r", str(REQUIREMENTS)])

    return python_path, venv_bin

python_path, venv_bin = ensure_venv_and_requirements()

# Prepara el entorno como si estuviera "activado"
env = os.environ.copy()
env["VIRTUAL_ENV"] = str(VENV_DIR)
env["PATH"] = str(venv_bin) + os.pathsep + env.get("PATH", "")

subprocess.run([str(python_path), str(SRC_DIR / "launcher.py")], env=env, cwd=str(SRC_DIR))