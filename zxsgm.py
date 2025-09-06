import os
import sys
import platform
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

        # rm venv/bin/bin2tap.py
        bin2tap_path = VENV_DIR / "bin" / "bin2tap.py"
        #if bin2tap_path.exists():
            #bin2tap_path.unlink()

       

    return python_path, venv_bin

python_path, venv_bin = ensure_venv_and_requirements()

# Prepara el entorno como si estuviera "activado"
env = os.environ.copy()
env["VIRTUAL_ENV"] = str(VENV_DIR)
env["PATH"] = str(venv_bin) + os.pathsep + env.get("PATH", "")


# =====================================================
# Check if bin2tap_zxsgm is already installed
venv_path = VENV_DIR
script_dir = venv_path / ("Scripts" if platform.system() == "Windows" else "bin")
bin2tap_zxsgm = script_dir / ("bin2tap_zxsgm.exe" if platform.system() == "Windows" else "bin2tap_zxsgm")

# Instala bin2tap como bin2tap_zxsgm si no lo esta ya
if bin2tap_zxsgm.exists():
    print("bin2tap_zxsgm ya está instalado, omitiendo instalación.")
else:
    print("Instalando bin2tap como bin2tap-zxsgm...")
    comando_install = str(SRC_DIR / "repo" / "install-bin2tap-zxsgm.py")
    print(f"Ejecutando: {comando_install}")
    result = subprocess.run([str(python_path), comando_install], env=env, cwd=str(PROJECT_DIR), capture_output=True, text=True)
    print(result.stdout)
    if result.stderr:
        print("Advertencias/Errores:", result.stderr)
    if result.returncode != 0:
        print("Error: La instalación de bin2tap-zxsgm falló")
        sys.exit(1)
    print("Fin instalación bin2tap-zxsgm. Por favor espere mientras se lanza el GUI")
# =====================================================

subprocess.run([str(python_path), str(SRC_DIR / "launcher.py")], env=env, cwd=str(SRC_DIR))