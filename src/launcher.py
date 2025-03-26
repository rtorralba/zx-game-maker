import os
import subprocess
import tkinter as tk
from tkinter import messagebox
from tkinter import PhotoImage
import platform
import threading
from PIL import Image, ImageTk

from builder.SpritesPreviewGenerator import SpritesPreviewGenerator
from builder.helper import DIST_FOLDER, getProjectFileName

def run_script(script_name, output_text):
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
            script_path = os.path.join(os.getcwd(), "scripts", script_name)

            # Depuración: Imprimir la ruta completa del script
            print(f"Intentando ejecutar el script en: {script_path}")

            # Verificar si el script existe
            if not os.path.exists(script_path):
                output_text.insert(tk.END, f"No se encontró el script: {script_path}\n")
                return

            # Ejecutar el script según el sistema operativo
            if platform.system() == "Windows":
                process = subprocess.Popen(
                    ["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    bufsize=1
                )
            elif platform.system() in ["Linux", "Darwin"]:
                process = subprocess.Popen(
                    ["stdbuf", "-oL", "-eL", "bash", script_path],
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
            if process.returncode == 0:
                output_text.insert(tk.END, f"\nEl script {script_name} se ejecutó correctamente.\n")
            else:
                output_text.insert(tk.END, f"\nEl script {script_name} terminó con errores.\n")

        except FileNotFoundError:
            output_text.insert(tk.END, f"No se encontró el script {script_name}\n")
        except Exception as e:
            output_text.insert(tk.END, f"Error al ejecutar {script_name}:\n{e}\n")

    threading.Thread(target=execute, args=(script_name,)).start()

def open_game():
    try:
        projectName = getProjectFileName()
        # Detectar el sistema operativo y seleccionar el archivo ejecutable
        if platform.system() == "Windows":
            game_path = os.path.join(os.getcwd(), DIST_FOLDER, projectName + ".exe")
        elif platform.system() in ["Linux", "Darwin"]:
            game_path = os.path.join(os.getcwd(), DIST_FOLDER, projectName + ".linux")
        else:
            messagebox.showerror("Error", "El sistema operativo no es compatible.")
            return

        # Verificar si el archivo existe
        if not os.path.exists(game_path):
            messagebox.showerror("Error", f"No se encontró el archivo del juego: {game_path}")
            return

        # Abrir el archivo ejecutable
        subprocess.Popen([game_path], shell=True)
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir el juego: {e}")

def show_modal_with_gif(gif_path):
    """Abre un modal para mostrar el GIF animado redimensionado al doble de su tamaño."""
    modal = tk.Toplevel(root)
    modal.title("Preview Result")
    modal.geometry("200x200")  # Ajustar el tamaño del modal para acomodar el GIF redimensionado
    modal.resizable(False, False)

    # Etiqueta para mostrar el GIF
    try:
        # Cargar el GIF usando Pillow
        gif = Image.open(gif_path)

        # Crear un widget Label para mostrar el GIF
        gif_label = tk.Label(modal)
        gif_label.pack(pady=10)

        # Función para actualizar los frames del GIF
        def update_frame(frame_index):
            try:
                gif.seek(frame_index)  # Mover al frame actual
                # Redimensionar el frame al doble de su tamaño
                frame = gif.resize((gif.width * 2, gif.height * 2), Image.Resampling.NEAREST)
                frame = ImageTk.PhotoImage(frame)
                gif_label.config(image=frame)
                gif_label.image = frame  # Mantener referencia para evitar recolección de basura
                modal.after(200, update_frame, (frame_index + 1) % gif.n_frames)  # Actualizar al siguiente frame
            except Exception as e:
                print(f"Error al actualizar el frame: {e}")

        # Iniciar la animación del GIF
        update_frame(0)

    except Exception as e:
        messagebox.showerror("Error", f"No se pudo cargar el GIF: {e}")
        modal.destroy()
        return

def open_main_character_running_preview():
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateMainPreview()
        if result:
            show_modal_with_gif(result)
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
            show_modal_with_gif(result)
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
            show_modal_with_gif(result)
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
            show_modal_with_gif(result)
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
            show_modal_with_gif(result)
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

# Crear la ventana principal
root = tk.Tk()
root.title("ZX Spectrum Game Maker")
root.geometry("600x800")

# Cargar el logo
logo_path = os.path.join(os.getcwd(), "ui/logo.png")
if os.path.exists(logo_path):
    logo = PhotoImage(file=logo_path)
    logo_label = tk.Label(root, image=logo)
    logo_label.pack(pady=10)
else:
    messagebox.showwarning("Advertencia", "No se encontró el logo en 'ui/logo.png'.")

# Crear un contenedor para los botones
button_frame = tk.Frame(root)
button_frame.pack(pady=10)

# Botón para ejecutar make-game
make_game_button = tk.Button(
    button_frame,
    text="Make Game",
    command=lambda: run_script("make-game", output_text),
    width=15
)
make_game_button.pack(side=tk.LEFT, padx=5)

# Botón para ejecutar make-fx
make_fx_button = tk.Button(
    button_frame,
    text="Make FX",
    command=lambda: run_script("make-fx", output_text),
    width=15
)
make_fx_button.pack(side=tk.LEFT, padx=5)

# Botón para mostrar el menú de Sprites Preview
sprites_preview_button = tk.Button(
    button_frame,
    text="Sprites Preview",
    width=15
)
sprites_preview_button.pack(side=tk.LEFT, padx=5)
sprites_preview_button.bind("<Button-1>", show_sprites_menu)

# Botón para abrir el juego
open_game_button = tk.Button(
    button_frame,
    text="Open Game",
    command=open_game,
    width=15
)
open_game_button.pack(side=tk.LEFT, padx=5)

# Área de texto para mostrar la salida de los scripts
output_text = tk.Text(root, height=30, width=70)
output_text.pack(pady=10)

# Iniciar el bucle principal de la aplicación
root.mainloop()