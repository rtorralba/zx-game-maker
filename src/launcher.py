import os
from pathlib import Path
import platform
import subprocess
import sys

from configuración.folders import BIN_FOLDER, OUTPUT_FOLDER, DIST_FOLDER, ASSETS_FOLDER, SCREENS_FOLDER, MAP_FOLDER, MAPS_FILE, HUD_MAP_FILE, MAPS_PROJECT, SRC_FOLDER
from configuración.memoria import INITIAL_ADDRESS, MEMORY_BANK_SIZE

def install_requirements():
    """Ejecuta el script de instalación de dependencias según el sistema operativo."""
    try:
        # Detectar el sistema operativo
        current_os = platform.system()
        script_name = ""

        if current_os == "Windows":
            script_name = "install-requeriments.ps1"
        elif current_os in ["Linux", "Darwin"]:  # Linux o macOS
            script_name = "install-requeriments.sh"
        else:
            print(f"Sistema operativo no soportado: {current_os}")
            sys.exit(1)

        # Construir la ruta completa del script
        script_path = Path(os.path.dirname(__file__)) / "scripts" / script_name

        # Verificar si el script existe
        if not script_path.exists():
            print(f"No se encontró el script: {script_path}")
            sys.exit(1)

        # Ejecutar el script
        if current_os == "Windows":
            subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", str(script_path)], check=True)
        else:
            subprocess.run(["bash", str(script_path)], check=True)

    except subprocess.CalledProcessError as e:
        print(f"Error al ejecutar el script de instalación de dependencias: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error inesperado: {e}")
        sys.exit(1)

# Ejecutar la instalación de dependencias antes de importar cualquier módulo
install_requirements()

import tkinter as tk
from tkinter import messagebox
from tkinter import PhotoImage
import threading
import webbrowser

from builder.SpritesPreviewGenerator import SpritesPreviewGenerator
# from builder.helper import DIST_FOLDER, MAPS_PROJECT, getProjectFileName
from builder.helper import getProjectFileName

import os

# Establecer el directorio de trabajo al directorio del script
os.chdir(os.path.dirname(os.path.abspath(__file__)))

def run_script(script_name, output_text, extra_args=None):
    def execute(script_name):
        try:
            # Limpiar la ventana de salida
            output_text.delete(1.0, tk.END)

            # Detectar el sistema operativo y añadir la extensión adecuada
            if platform.system() == "Windows":
                script_name += ".ps1"
            elif platform.system() in ["Linux", "Darwin"]:
                script_name += ".sh"
            else:
                output_text.insert(tk.END, f"El sistema operativo no es compatible.\n")
                return

            # Construir la ruta completa del script en la carpeta src/scripts
            script_path = Path.cwd() / "scripts" / script_name

            # Verificar si el script existe
            if not script_path.exists():
                output_text.insert(tk.END, f"No se encontró el script: {script_path}\n")
                return

            # Construir el comando con parámetros adicionales
            command = [str(script_path)]
            if extra_args:
                command.extend(extra_args)

            # Ejecutar el script según el sistema operativo
            if platform.system() == "Windows":
                process = subprocess.Popen(
                    ["powershell", "-ExecutionPolicy", "Bypass", "-File"] + command,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    bufsize=1
                )
            elif platform.system() in ["Linux", "Darwin"]:
                process = subprocess.Popen(
                    ["bash"] + command,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    bufsize=1
                )

            # Leer la salida del proceso en tiempo real
            for line in iter(process.stdout.readline, ''):
                output_text.insert(tk.END, line)
                output_text.see(tk.END)

            for line in iter(process.stderr.readline, ''):
                output_text.insert(tk.END, line)
                output_text.see(tk.END)

            process.wait()
            # if process.returncode == 0:
            #     output_text.insert(tk.END, f"\nEl script {script_name} se ejecutó correctamente.\n")
            # else:
            #     output_text.insert(tk.END, f"\nEl script {script_name} terminó con errores.\n")

        except FileNotFoundError:
            output_text.insert(tk.END, f"No se encontró el script {script_name}\n")
        except Exception as e:
            output_text.insert(tk.END, f"Error al ejecutar {script_name}:\n{e}\n")

    threading.Thread(target=execute, args=(script_name,)).start()

def open_game_variant(variant):
    """Abre el juego en su variante 'Normal' o 'RF'."""
    try:
        project_name = getProjectFileName()

        if variant == "rf":
            project_name += "-RF"
            
        # Detectar el sistema operativo y seleccionar el archivo ejecutable
        if platform.system() == "Windows":
            # game_path = os.path.join(os.getcwd(), DIST_FOLDER, f"{project_name}.exe")
            game_path = Path.cwd() / DIST_FOLDER / f"{project_name}.exe"
        elif platform.system() in ["Linux", "Darwin"]:
            # game_path = os.path.join(os.getcwd(), DIST_FOLDER, f"{project_name}.linux")
            game_path = Path.cwd() / DIST_FOLDER / f"{project_name}.linux"
        else:
            messagebox.showerror("Error", "El sistema operativo no es compatible.")
            return

        # Verificar si el archivo existe
        if not game_path.exists():
            messagebox.showerror("Error", f"No se encontró el archivo del juego: {game_path}")
            return

        # Abrir el archivo ejecutable
        subprocess.Popen([str(game_path)], shell=True)
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir el juego: {e}")

def show_modal_with_animation(gif_path):
    """Abre el GIF en el navegador predeterminado."""
    try:
        # Verificar si el archivo existe
        if not gif_path.exists():
            messagebox.showerror("Error", f"No se encontró el archivo: {gif_path}")
            return

        # Abrir el archivo GIF en el navegador predeterminado
        webbrowser.open(f"file://{os.path.abspath(gif_path)}")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir el GIF: {e}")

def open_main_character_running_preview():
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateMainPreview()
        if result:
            show_modal_with_animation(result)
        else:
            messagebox.showerror("Error", "No se generó ningún resultado.")
    except Exception as e:
        messagebox.showerror("Error", f"Error al generar el preview: {e}")

def open_main_character_idle_preview():
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateIdlePreview()
        if result:
            show_modal_with_animation(result)
        else:
            messagebox.showerror("Error", "No se generó ningún resultado.")
    except Exception as e:
        messagebox.showerror("Error", f"Error al generar el preview: {e}")

def open_first_platform_preview():
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateFirstPreview()
        if result:
            show_modal_with_animation(result)
        else:
            messagebox.showerror("Error", "No se generó ningún resultado.")
    except Exception as e:
        messagebox.showerror("Error", f"Error al generar el preview: {e}")

def open_second_platform_preview():
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateSecondPreview()
        if result:
            show_modal_with_animation(result)
        else:
            messagebox.showerror("Error", "No se generó ningún resultado.")
    except Exception as e:
        messagebox.showerror("Error", f"Error al generar el preview: {e}")

def open_enemy_preview(enemy_number):
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateEnemy(enemy_number)
        if result:
            show_modal_with_animation(result)
        else:
            messagebox.showerror("Error", "No se generó ningún resultado.")
    except Exception as e:
        messagebox.showerror("Error", f"Error al generar el preview: {e}")

def show_sprites_menu(event):
    # Crear un menú emergente
    sprites_menu = tk.Menu(root, tearoff=0)

    # Submenú para "Main Character"
    main_character_menu = tk.Menu(sprites_menu, tearoff=0)
    main_character_menu.add_command(label="Running", command=open_main_character_running_preview)
    main_character_menu.add_command(label="Idle", command=lambda: open_main_character_idle_preview())
    sprites_menu.add_cascade(label="Main Character", menu=main_character_menu)

    # Submenú para "Platforms"
    platforms_menu = tk.Menu(sprites_menu, tearoff=0)
    platforms_menu.add_command(label="Platform 1", command=lambda: open_first_platform_preview())
    platforms_menu.add_command(label="Platform 2", command=lambda: open_second_platform_preview())
    sprites_menu.add_cascade(label="Platforms", menu=platforms_menu)

    # Submenú para "Enemies"
    enemies_menu = tk.Menu(sprites_menu, tearoff=0)
    for i in range(1, 9):  # Generar dinámicamente las opciones de enemigos del 1 al 8
        enemies_menu.add_command(label=f"Enemy {i}", command=lambda i=i: open_enemy_preview(i))
    sprites_menu.add_cascade(label="Enemies", menu=enemies_menu)

    # Mostrar el menú en la posición del cursor
    sprites_menu.post(event.x_root, event.y_root)

def open_memory_bank_image(image):
    """Abre la imagen de uso de memoria para el banco especificado."""
    try:
        # Construir la ruta de la imagen
        # image_path = os.path.join(os.getcwd(), "output", image)
        image_path = Path.cwd() / OUTPUT_FOLDER / image

        # Verificar si la imagen existe
        if not image_path.exists():
            messagebox.showerror("Error", f"No se encontró la imagen: {image_path}")
            return

        # Abrir la imagen con el visor predeterminado del sistema
        if platform.system() == "Windows":
            os.startfile(image_path)
        elif platform.system() == "Linux":
            subprocess.Popen(["xdg-open", image_path])
        elif platform.system() == "Darwin":  # macOS
            subprocess.Popen(["open", image_path])
        else:
            messagebox.showerror("Error", "El sistema operativo no es compatible.")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir la imagen: {e}")

def open_map_with_tiled():
    """Abre el mapa en Tiled."""
    # Verificar si el archivo del mapa existe
    if not MAPS_PROJECT.exists():
        messagebox.showerror("Error", f"No se encontró el archivo del mapa: {MAPS_PROJECT}")
        return

    if os.name == "nt":
        program_files = os.environ["ProgramFiles"]
        command = "\"" + program_files + "\\Tiled\\tiled.exe\" " + str(MAPS_PROJECT)
    else:
        command = "tiled " + str(MAPS_PROJECT)
    
    subprocess.Popen(command, shell=True)

# Crear la ventana principal
root = tk.Tk()
root.title("ZX Spectrum Game Maker")
root.geometry("600x750")
root.resizable(False, False)

os.system("zxp2gus -t tiles -i " + str(ASSETS_FOLDER / "map/tiles.zxp") + " -o " + str(SRC_FOLDER) + " -f png")
os.system("zxp2gus -t sprites -i " + str(ASSETS_FOLDER / "map/sprites.zxp") + " -o " + str(SRC_FOLDER) + " -f png")

from builder.ZXPWatcher import ZXPWatcher
watcher = ZXPWatcher()
watcher_thread = threading.Thread(target=watcher.start, daemon=True)
watcher_thread.start()

# Establecer el icono de la aplicación
icon_path = Path.cwd() / "ui/logo.png"
if icon_path.exists():
    root.iconphoto(True, PhotoImage(file=icon_path))
else:
    messagebox.showwarning("Advertencia", "No se encontró el icono en 'ui/logo.png'.")

# Cargar el logo
logo_path = Path.cwd() / "ui/logo.png"
if logo_path.exists():
    logo = PhotoImage(file=logo_path)
    logo_label = tk.Label(root, image=logo)
    logo_label.pack(pady=10)
else:
    messagebox.showwarning("Advertencia", "No se encontró el logo en 'ui/logo.png'.")

# Crear el menú de barras
menu_bar = tk.Menu(root)

# Menú "Build"
build_menu = tk.Menu(menu_bar, tearoff=0)
build_menu.add_command(label="Game", command=lambda: run_script("make-game", output_text))
build_menu.add_command(label="Game (verbose)", command=lambda: run_script("make-game", output_text, ["--verbose"]))
build_menu.add_command(label="FX", command=lambda: run_script("make-fx", output_text))
build_menu.add_separator()
build_menu.add_command(label="Exit", command=root.quit)
menu_bar.add_cascade(label="Build", menu=build_menu)

# Menú "Map"
map_menu = tk.Menu(menu_bar, tearoff=0)
map_menu.add_command(label="Open Map", command=open_map_with_tiled)
menu_bar.add_cascade(label="Map", menu=map_menu)

# Menú "Sprites"
sprites_menu = tk.Menu(menu_bar, tearoff=0)

# Submenú para "Main Character"
main_character_menu = tk.Menu(sprites_menu, tearoff=0)
main_character_menu.add_command(label="Running", command=open_main_character_running_preview)
main_character_menu.add_command(label="Idle", command=open_main_character_idle_preview)
sprites_menu.add_cascade(label="Main Character", menu=main_character_menu)

# Submenú para "Platforms"
platforms_menu = tk.Menu(sprites_menu, tearoff=0)
platforms_menu.add_command(label="Platform 1", command=open_first_platform_preview)
platforms_menu.add_command(label="Platform 2", command=open_second_platform_preview)
sprites_menu.add_cascade(label="Platforms", menu=platforms_menu)

# Submenú para "Enemies"
enemies_menu = tk.Menu(sprites_menu, tearoff=0)
for i in range(1, 9):  # Generar dinámicamente las opciones de enemigos del 1 al 8
    enemies_menu.add_command(label=f"Enemy {i}", command=lambda i=i: open_enemy_preview(i))
sprites_menu.add_cascade(label="Enemies", menu=enemies_menu)

menu_bar.add_cascade(label="Sprites Preview", menu=sprites_menu)

# Menú "Game"
game_menu = tk.Menu(menu_bar, tearoff=0)
game_menu.add_command(label="Normal", command=lambda: open_game_variant("normal"))
game_menu.add_command(label="RF", command=lambda: open_game_variant("rf"))
menu_bar.add_cascade(label="Game", menu=game_menu)

# Menú "Memory Usage"
memory_menu = tk.Menu(menu_bar, tearoff=0)
memory_menu.add_command(label="Bank 0 48k", command=lambda: open_memory_bank_image("memory-bank-0-48K.png"))
memory_menu.add_command(label="Bank 0 128k", command=lambda: open_memory_bank_image("memory-bank-0-128K.png"))
memory_menu.add_command(label="Bank 3", command=lambda: open_memory_bank_image("memory-bank-3.png"))
memory_menu.add_command(label="Bank 4", command=lambda: open_memory_bank_image("memory-bank-4.png"))
memory_menu.add_command(label="Bank 6", command=lambda: open_memory_bank_image("memory-bank-6.png"))
menu_bar.add_cascade(label="Memory Usage", menu=memory_menu)

# Menú "Help"
help_menu = tk.Menu(menu_bar, tearoff=0)
help_menu.add_command(label="Documentation", command=lambda: webbrowser.open("https://gm.retrojuegos.org/"))
help_menu.add_command(label="Telegram", command=lambda: webbrowser.open("https://t.me/zx_spectrum_game_maker"))
help_menu.add_command(label="GitHub", command=lambda: webbrowser.open("https://github.com/rtorralba/zx-game-maker"))
menu_bar.add_cascade(label="Help", menu=help_menu)

# Configurar el menú en la ventana principal
root.config(menu=menu_bar)

# Área de texto para mostrar la salida de los scripts
output_text = tk.Text(root, height=30, width=70)
output_text.pack(pady=10)

def on_close():
    watcher.stop()  # Debes implementar el método stop() en tu ZXPWatcher si no existe
    root.destroy()

root.protocol("WM_DELETE_WINDOW", on_close)

# Iniciar el bucle principal de la aplicación
root.mainloop()