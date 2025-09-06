#!/usr/bin/env python3

import os
import sys
import subprocess
import platform
from pathlib import Path

def run_command(command, error_message):
    """Execute a command and handle errors."""
    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        print(result.stdout)
        if result.stderr:
            print("Advertencias:", result.stderr)
        return True
    except subprocess.CalledProcessError as e:
        print(f"{error_message}: {e}")
        print(e.stderr)
        return False

def get_venv_python(venv_path):
    """Return the Python executable path for the existing virtual environment."""
    venv_path = Path(venv_path)
    if not venv_path.exists():
        print(f"Error: El entorno virtual {venv_path} no existe")
        sys.exit(1)
    if platform.system() == "Windows":
        python_exe = venv_path / "Scripts" / "python.exe"
    else:
        python_exe = venv_path / "bin" / "python"
    if not python_exe.exists():
        print(f"Error: No se encontró el ejecutable de Python en {python_exe}")
        sys.exit(1)
    return python_exe

def install_bin2tap(venv_python, repo_dir):
    """Install the bin2tap_zxsgm package from the local directory."""
    print(f"Instalando desde {repo_dir}")
    cmd = [str(venv_python), "-m", "pip", "install", "--no-cache-dir", "-e", str(repo_dir)]
    print(f"Ejecutando: {' '.join(cmd)}")
    if not run_command(cmd, "Error al instalar bin2tap_zxsgm"):
        sys.exit(1)
    print("Verificando paquetes instalados:")
    run_command([str(venv_python), "-m", "pip", "list"], "Error al listar paquetes")

def verify_installation(venv_path):
    """Verify that the bin2tap_zxsgm executable is installed."""
    script_dir = Path(venv_path) / ("Scripts" if platform.system() == "Windows" else "bin")
    bin2tap_zxsgm = script_dir / ("bin2tap_zxsgm.exe" if platform.system() == "Windows" else "bin2tap_zxsgm")
    if bin2tap_zxsgm.exists():
        print(f"Éxito: bin2tap_zxsgm está instalado en {bin2tap_zxsgm}")
        print("Prueba ejecutando: bin2tap_zxsgm --help")
    else:
        print(f"Error: No se encontró bin2tap_zxsgm en {script_dir}")
        print(f"Contenido de {script_dir}:")
        for f in script_dir.iterdir():
            print(f"  {f}")
        sys.exit(1)

def main():
    # Get the absolute path of the script and its parent directory
    script_path = Path(__file__).resolve()
    script_dir = script_path.parent
    repo_dir = script_dir / "bin2tap-zxsgm"
    venv_path = script_dir / "../../venv"

    # Check if the bin2tap-zxsgm folder exists
    if not repo_dir.exists():
        print(f"Error: La carpeta {repo_dir} no se encontró en el directorio del script")
        sys.exit(1)

    # Print the structure of the bin2tap-zxsgm folder for debugging
    print(f"Estructura de la carpeta {repo_dir}:")
    for root, dirs, files in os.walk(repo_dir):
        level = root.replace(str(repo_dir), '').count(os.sep)
        indent = ' ' * 4 * level
        print(f"{indent}{os.path.basename(root)}/")
        for f in files:
            print(f"{indent}    {f}")

    # Check if setup.py exists
    setup_path = repo_dir / "setup.py"
    if not setup_path.exists():
        print(f"Error: No se encontró setup.py en {repo_dir}")
        sys.exit(1)

    # Get the Python executable for the virtual environment
    venv_python = get_venv_python(venv_path)

    # Install the package
    install_bin2tap(venv_python, repo_dir)

    # Verify the installation
    verify_installation(venv_path)

    print("\nInstrucciones finales:")
    print(f"1. Activa el entorno virtual manualmente si no está activado:")
    print(f"   source {venv_path}/bin/activate  # Linux/Mac")
    print(f"   {venv_path}\\Scripts\\activate  # Windows")
    print("2. Usa 'bin2tap_zxsgm' para ejecutar el comando")
    print("3. Desactiva el venv con: deactivate")

if __name__ == "__main__":
    main()