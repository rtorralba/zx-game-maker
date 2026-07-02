import os
from pathlib import Path
import platform
import subprocess
import build
import sys
import json
import locale
import xml.etree.ElementTree as ET
import urllib.request
from html.parser import HTMLParser

# i18n setup
I18N_FOLDER = Path.cwd() / "i18n"
CONFIG_FILE = Path.cwd() / "config.json"
DEFAULT_LANG = "en"

def get_saved_language():
    try:
        if CONFIG_FILE.exists():
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                config = json.load(f)
                return config.get("language")
    except Exception:
        pass
    return None

def set_saved_language(lang_code):
    try:
        config = {}
        if CONFIG_FILE.exists():
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                config = json.load(f)
        config["language"] = lang_code
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(config, f, indent=4)
        messagebox.showinfo(_("success"), _("language_changed_restart"))
    except Exception as e:
        print(f"Error saving language: {e}")

def load_translations():
    try:
        lang_code = get_saved_language()
        if not lang_code:
            system_locale, _ = locale.getdefaultlocale()
            lang_code = DEFAULT_LANG
            if system_locale:
                lang_prefix = system_locale.split('_')[0].lower()
                if lang_prefix in ["es", "en", "pt"]:
                    lang_code = lang_prefix
        
        lang_file = I18N_FOLDER / f"{lang_code}.json"
        if not lang_file.exists():
            lang_file = I18N_FOLDER / f"{DEFAULT_LANG}.json"
            
        with open(lang_file, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading language: {e}")
        return {}

translations = load_translations()

def _(key, *args):
    text = translations.get(key, key)
    if args:
        try:
            return text.format(*args)
        except Exception:
            pass
    return text

class TextRedirector:
    def __init__(self, text_widget):
        self.text_widget = text_widget

    def write(self, s):
        self.text_widget.insert('end', s)
        self.text_widget.see('end')

    def flush(self):
        pass  # Necesario para compatibilidad con sys.stdout

from builder.PlayerFxBuilder import PlayerFxBuilder
from configuration.folders import BIN_FOLDER, OUTPUT_FOLDER, DIST_FOLDER, ASSETS_FOLDER, SCREENS_FOLDER, MAP_FOLDER, MAPS_FILE, HUD_MAP_FILE, MAPS_PROJECT, SRC_FOLDER
from configuration.memoria import INITIAL_ADDRESS, MEMORY_BANK_SIZE
# Detectar el sistema operativo 
CURRENT_OS = platform.system()

import tkinter as tk
from tkinter import messagebox
from tkinter import PhotoImage
import threading
import webbrowser
from PIL import Image, ImageTk

from builder.SpritesPreviewGenerator import SpritesPreviewGenerator
# from builder.helper import DIST_FOLDER, MAPS_PROJECT, getProjectFileName
from builder.helper import getProjectFileName

import os

# Establecer el directorio de trabajo al directorio del script
os.chdir(os.path.dirname(os.path.abspath(__file__)))

def executeBuild(verbose=False, selected_folder=None):

    if selected_folder is None:
        selected_folder = showFolderSelectionModal()

    if selected_folder is None:
        selected_folder = "default"

    os.environ["ZXSGM_I18N_FOLDER"] = str(selected_folder)

    def run():
        output_text.delete(1.0, tk.END)
        redirector = TextRedirector(output_text)
        old_stdout = sys.stdout
        old_stderr = sys.stderr
        sys.stdout = redirector
        sys.stderr = redirector
        try:
            build.build(verbose=verbose)
        except Exception as e:
            print(f"\nBUILD ERROR: {e}")
        finally:
            sys.stdout = old_stdout
            sys.stderr = old_stderr
    threading.Thread(target=run).start()

def open_game_variant(variant):
    """Abre el juego en su variante 'Normal' o 'RF'."""
    try:
        project_name = getProjectFileName()

        if variant == "rf":
            project_name += "-RF"
            
        # Detectar el sistema operativo y seleccionar el archivo ejecutable
        if CURRENT_OS == "Windows":
            # game_path = os.path.join(os.getcwd(), DIST_FOLDER, f"{project_name}.exe")
            game_path = Path.cwd() / DIST_FOLDER / f"{project_name}.exe"
        elif CURRENT_OS == "Linux":
            # game_path = os.path.join(os.getcwd(), DIST_FOLDER, f"{project_name}.linux")
            game_path = Path.cwd() / DIST_FOLDER / f"{project_name}.linux"            
        elif CURRENT_OS == "Darwin":
            # game_path = os.path.join(os.getcwd(), DIST_FOLDER, f"{project_name}.app")
            game_path = Path.cwd() / DIST_FOLDER / f"{project_name}.app"
            subprocess.run(["open", game_path])
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


# Mostrar GIF animado en ventana Tkinter
def show_modal_with_animation(gif_path):
    try:
        if not gif_path.exists():
            messagebox.showerror(_("error"), _("file_not_found", gif_path))
            return

        win = tk.Toplevel(root)
        win.title(_("preview"))
        win.transient(root)  # Ventana hija
        win.grab_set()       # Modal
        win.attributes('-topmost', True)  # Siempre encima
        lbl = tk.Label(win)
        lbl.pack()

        pil_img = Image.open(gif_path)
        scale = 2  # Factor de escala (2x)
        frames = []
        durations = []
        try:
            while True:
                frame = pil_img.copy()
                w, h = frame.size
                frame = frame.resize((w*scale, h*scale), Image.NEAREST)
                frames.append(ImageTk.PhotoImage(frame))
                durations.append(pil_img.info.get('duration', 100))
                pil_img.seek(len(frames))
        except EOFError:
            pass
        if not frames:
            messagebox.showerror(_("error"), _("gif_no_frames"))
            win.destroy()
            return

        def update(idx=0):
            lbl.config(image=frames[idx])
            win.after(durations[idx], update, (idx + 1) % len(frames))

        update()
    except Exception as e:
        messagebox.showerror(_("error"), _("could_not_open_gif", e))

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
        if CURRENT_OS == "Windows":
            os.startfile(image_path)
        elif CURRENT_OS == "Linux":
            subprocess.Popen(["xdg-open", image_path])
        elif CURRENT_OS == "Darwin":  # macOS
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
    elif CURRENT_OS == "Darwin":  # macOS
        applications = "/Applications" # Ruta standard en MacOS
        tiled_path = os.path.join(applications, "Tiled.app/Contents/MacOS/Tiled")
        if os.path.exists(tiled_path):
            command = f'"{tiled_path}" "{MAPS_PROJECT}"'
        else:
            print("Error: Tiled no está instalado en /Applications/Tiled.app")
            exit(1)
    else:
        command = "tiled " + str(MAPS_PROJECT)
    
    subprocess.Popen(command, shell=True)

def open_hud_tmx():
    """Abre el fichero assets/screens/hud.tmx con la aplicación por defecto."""
    try:
        hud_path = ASSETS_FOLDER / "screens" / "hud.tmx"
        if not hud_path.exists():
            messagebox.showerror("Error", f"No se encontró el fichero: {hud_path}")
            return

        if CURRENT_OS == "Windows":
            os.startfile(str(hud_path))
        elif CURRENT_OS == "Linux":
            subprocess.Popen(["xdg-open", str(hud_path)])
        elif CURRENT_OS == "Darwin":
            subprocess.Popen(["open", str(hud_path)])
        else:
            messagebox.showerror("Error", "El sistema operativo no es compatible.")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir HUD: {e}")

def open_hud_scr():
    """Abre el fichero assets/screens/hud.scr con la aplicación por defecto."""
    try:
        hud_path = ASSETS_FOLDER / "screens" / "hud.scr"
        if not hud_path.exists():
            messagebox.showerror("Error", f"No se encontró el fichero: {hud_path}")
            return

        if CURRENT_OS == "Windows":
            os.startfile(str(hud_path))
        elif CURRENT_OS == "Linux":
            subprocess.Popen(["xdg-open", str(hud_path)])
        elif CURRENT_OS == "Darwin":
            subprocess.Popen(["open", str(hud_path)])
        else:
            messagebox.showerror("Error", "El sistema operativo no es compatible.")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir HUD: {e}")

def show_hud_menu(event):
    """Muestra un menú con opciones para abrir el HUD: Background (.scr) y Elements (.tmx)."""
    hud_menu = tk.Menu(root, tearoff=0)
    hud_menu.add_command(label=_("menu_background"), command=open_hud_scr)
    hud_menu.add_command(label=_("menu_elements"), command=open_hud_tmx)
    hud_menu.post(event.x_root, event.y_root)

def open_project_folder():
    """Abre la carpeta raíz del proyecto en el explorador de archivos."""
    try:
        # Al inicio del script hacemos chdir a la carpeta `src`, por eso el padre es la raíz del proyecto
        project_dir = Path.cwd().parent
        if not project_dir.exists():
            messagebox.showerror("Error", f"No se encontró la carpeta del proyecto: {project_dir}")
            return

        if CURRENT_OS == "Windows":
            os.startfile(str(project_dir))
        elif CURRENT_OS == "Linux":
            subprocess.Popen(["xdg-open", str(project_dir)])
        elif CURRENT_OS == "Darwin":
            subprocess.Popen(["open", str(project_dir)])
        else:
            messagebox.showerror("Error", "El sistema operativo no es compatible.")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir la carpeta del proyecto: {e}")

def showFolderSelectionModal():
    import tkinter as tk

    global root

    # selected_folder = filedialog.askdirectory(initialdir=folder_path, title="Select Language Folder")

    folder_path = ASSETS_FOLDER / "texts"
    if len(os.listdir(folder_path)) > 0:
        folders = [d for d in os.listdir(folder_path) if os.path.isdir(os.path.join(folder_path, d))]

        # keep only folder with 2 letters
        folders = [f for f in folders if len(f) == 2]

    # buscar carpetas tambien en screens de 2 letras y añadirlas si no estan ya
    screens_path = ASSETS_FOLDER / "screens"
    if len(os.listdir(screens_path)) > 0:
        screens_folders = [d for d in os.listdir(screens_path) if os.path.isdir(os.path.join(screens_path, d))]

        # keep only folder with 2 letters
        screens_folders = [f for f in screens_folders if len(f) == 2]

        for folder in screens_folders:
            if folder not in folders:
                folders.append(folder)

    # Crear ventana modal
    folders.insert(0, "default")

    selection = tk.StringVar(value="default")

    def on_ok():
        win.destroy()

    win = tk.Toplevel(root)
    win_width = 400
    win_height = 60 + len(folders) * 30  # 60 para el label y botón, 30 por opción
    win.geometry(f"{win_width}x{win_height}")
    win.title(_("select_language_folder_title"))
    tk.Label(win, text=_("select_language_folder")).pack(anchor="w", padx=10, pady=5)
    for folder in folders:
        tk.Radiobutton(win, text=folder, variable=selection, value=folder).pack(anchor="w", padx=20)
    tk.Button(win, text=_("btn_ok"), command=on_ok).pack(pady=10)
    win.grab_set()
    win.protocol("WM_DELETE_WINDOW", on_ok)
    root.wait_window(win)

    selected_folder = selection.get()

    if selected_folder in folders:
        return selected_folder
    else:
        return None

def fxBuild():
    if PlayerFxBuilder.build():
        messagebox.showinfo(_("success"), _("fx_built_success"))
    else:
        messagebox.showerror(_("error"), _("error_building_fx"))

TOOLTIPS = {
    "128Kenabled": "Activa o desactiva las características exclusivas de 128K.",
    "ammo": "Munición inicial del jugador.",
    "animatePeriodMain": "Período de animación para el personaje principal.",
    "animatePeriodTile": "Período de animación para los tiles del mapa.",
    "backgroundAttribute": "Atributo de color del fondo de la pantalla (0-255).",
    "borderColorItem": "Color del borde de la pantalla al recoger un objeto (0-7).",
    "borderColorKey": "Color del borde al recoger una llave (0-7).",
    "borderColorLife": "Color del borde al perder/ganar vida (0-7).",
    "bulletDistance": "Distancia máxima que recorre una bala.",
    "damageAmount": "Cantidad de daño que recibe el jugador.",
    "dashEnabled": "Habilita la habilidad de hacer 'dash'.",
    "disableContinuousJump": "El jugador debe soltar el botón de salto antes de volver a saltar.",
    "enemiesRespawn": "Los enemigos vuelven a aparecer al reentrar en la pantalla.",
    "enemyShootEnabled": "Permite a los enemigos disparar proyectiles.",
    "enemyShootSolidCollide": "Los disparos de los enemigos chocan contra las paredes.",
    "finishGameEnemy": "ID del enemigo que, al ser derrotado, finaliza el juego.",
    "finishGameObjective": "Tipo de objetivo para terminar el juego (ej. itemsAndKillEnemy).",
    "gameName": "El nombre del juego.",
    "goalItems": "Número de objetos (items) requeridos.",
    "hiScore": "Activa la puntuación máxima (hi-score).",
    "idleTime": "Tiempo de inactividad antes de la animación 'idle'.",
    "initialLife": "Cantidad de vida inicial del jugador.",
    "itemsCountdown": "Los items funcionan como un contador decreciente.",
    "itemsEnabled": "Activa la recolección de objetos.",
    "itemsToOpenDoors": "Número de objetos necesarios para abrir puertas.",
    "jumpType": "Tipo de salto (ej. constant, accelerated).",
    "keysEnabled": "Activa el uso de llaves para abrir puertas.",
    "killJumpingOnTop": "Permite matar enemigos saltando sobre ellos.",
    "laddersEnabled": "Activa las escaleras.",
    "lifeAmount": "Número de vidas extra disponibles.",
    "mainCharacterExtraFrame": "Añade un frame extra de animación al personaje principal.",
    "mainCharacterInvincible": "El personaje principal es invencible.",
    "maxAnimatedTilesPerScreen": "Máximo de tiles animados simultáneamente en pantalla.",
    "maxEnemiesPerScreen": "Máximo de enemigos activos simultáneamente en pantalla.",
    "messagesEnabled": "Activa los mensajes en pantalla.",
    "messagesFlashEnabled": "Los mensajes parpadean.",
    "musicEnabled": "Activa la música.",
    "newBeeperPlayer": "Usa el nuevo reproductor de beeper.",
    "redefineKeysEnabled": "Permite al jugador redefinir las teclas.",
    "shooting": "Activa el disparo del personaje.",
    "shouldKillEnemies": "El jugador debe matar todos los enemigos.",
    "swordEnabled": "Activa la espada.",
    "textsEnabled": "Activa el sistema de textos en pantalla.",
    "timerSeconds": "Tiempo límite en segundos (0 = sin límite).",
    "useBreakableTile": "Modo de tiles rompibles.",
    "useBreakableTileByTouch": "Los tiles rompibles se rompen al tocarse.",
    "wallJumpEnabled": "Activa el salto en pared."
}

def open_configuration_editor():
    if not MAPS_FILE.exists():
        messagebox.showerror(_("error"), _("file_not_found", MAPS_FILE))
        return

    # Load enum values from tiled-project
    from configuration.folders import MAPS_PROJECT as TILED_PROJECT
    enum_values = {}
    try:
        with open(TILED_PROJECT, "r", encoding="utf-8-sig") as f:
            project_data = json.load(f)
        for pt in project_data.get("propertyTypes", []):
            if pt.get("type") == "enum":
                enum_values[pt["name"]] = pt.get("values", [])
    except Exception as e:
        print(f"Warning: could not load tiled-project enum types: {e}")

    try:
        with open(MAPS_FILE, "r", encoding="utf-8-sig") as f:
            xml_content = f.read()
        xml_root = ET.fromstring(xml_content)
        properties_node = xml_root.find('properties')
        if properties_node is None:
            messagebox.showerror(_("error"), "No properties found in maps.tmx")
            return
    except Exception as e:
        messagebox.showerror(_("error"), f"Error parsing XML: {e}")
        return

    win = tk.Toplevel(root)
    win.title(_("config_editor_title"))
    win.geometry("1050x700")
    win.transient(root)
    win.grab_set()

    from tkinter import ttk

    # ── Search bar ───────────────────────────────────────────────────────────
    search_frame = tk.Frame(win)
    search_frame.pack(side="top", fill="x", padx=10, pady=(8, 4))
    tk.Label(search_frame, text="🔍", font=("Segoe UI Emoji", 11)).pack(side="left")
    search_var = tk.StringVar()
    search_entry = tk.Entry(search_frame, textvariable=search_var, font=("Segoe UI", 10), width=40)
    search_entry.pack(side="left", padx=6, ipady=3)
    search_entry.focus_set()

    # ── Separator ────────────────────────────────────────────────────────────
    ttk.Separator(win, orient="horizontal").pack(fill="x", padx=10, pady=(0, 4))

    # ── Scrollable area ──────────────────────────────────────────────────────
    scroll_container = tk.Frame(win)
    scroll_container.pack(side="top", fill="both", expand=True)

    canvas = tk.Canvas(scroll_container)
    scrollbar = tk.Scrollbar(scroll_container, orient="vertical", command=canvas.yview)
    scrollable_frame = tk.Frame(canvas)

    scrollable_frame.bind(
        "<Configure>",
        lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
    )

    canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
    canvas.configure(yscrollcommand=scrollbar.set)

    canvas.pack(side="left", fill="both", expand=True)
    scrollbar.pack(side="right", fill="y")

    # Mouse wheel scroll
    def _on_mousewheel(event):
        canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")
    canvas.bind_all("<MouseWheel>", _on_mousewheel)
    win.bind("<Destroy>", lambda e: canvas.unbind_all("<MouseWheel>"))

    ROW_FONT = ("Segoe UI", 11)
    HELP_FONT = ("Segoe UI", 10)
    STRIPE_ODD  = "#f0f4f8"
    STRIPE_EVEN = "#ffffff"

    controls = {}
    # rows stores (prop_name, label_lower, row_frame)
    rows = []

    all_props = properties_node.findall('property')
    for i, prop in enumerate(all_props):
        prop_name = prop.get('name')
        prop_type = prop.get('type', 'string')
        prop_propertytype = prop.get('propertytype', None)
        prop_value = prop.get('value', '')
        bg = STRIPE_ODD if i % 2 == 0 else STRIPE_EVEN

        prop_label_text = _(f"prop_{prop_name}") if f"prop_{prop_name}" in translations else prop_name

        # Row frame — spans full width, gives uniform stripe background
        row_frame = tk.Frame(scrollable_frame, bg=bg)
        row_frame.pack(fill="x", side="top")
        # Fixed column widths so every row aligns perfectly
        row_frame.columnconfigure(0, minsize=220)
        row_frame.columnconfigure(1, minsize=160)
        row_frame.columnconfigure(2, weight=1)

        tk.Label(row_frame, text=prop_label_text, width=30, anchor="w",
                 bg=bg, font=ROW_FONT).grid(row=0, column=0, padx=(8, 4), pady=4, sticky="w")

        if prop_type == 'bool':
            var = tk.BooleanVar(value=(prop_value.lower() == 'true'))
            ctrl = tk.Checkbutton(row_frame, variable=var, bg=bg)
            ctrl.grid(row=0, column=1, sticky="w", padx=4)
            controls[prop] = ('bool', var)
        elif prop_propertytype and prop_propertytype in enum_values:
            values = enum_values[prop_propertytype]
            var = tk.StringVar(value=prop_value)
            ctrl = ttk.Combobox(row_frame, textvariable=var, values=values,
                                state="readonly", width=16, font=ROW_FONT)
            ctrl.grid(row=0, column=1, sticky="w", padx=4)
            controls[prop] = ('text', var)
        else:
            var = tk.StringVar(value=prop_value)
            ctrl = tk.Entry(row_frame, textvariable=var, width=16, font=ROW_FONT)
            ctrl.grid(row=0, column=1, sticky="w", padx=4)
            controls[prop] = ('text', var)

        help_text = TOOLTIPS.get(prop_name, "")
        tk.Label(row_frame, text=help_text, anchor="w", justify="left",
                 fg="#555e6b", wraplength=520, bg=bg,
                 font=HELP_FONT).grid(row=0, column=2, sticky="w", padx=(14, 8))

        rows.append((prop_name, prop_label_text.lower(), row_frame))

    # ── Live filter ──────────────────────────────────────────────────────────
    def on_search(*_):
        query = search_var.get().lower().strip()
        for prop_name, label_lower, row_frame in rows:
            match = (not query) or (query in label_lower) or (query in prop_name.lower())
            if match:
                row_frame.pack(fill="x", side="top")
            else:
                row_frame.pack_forget()

    search_var.trace_add("write", on_search)


    # ── Save button ──────────────────────────────────────────────────────────
    def save_config():
        import re
        try:
            with open(MAPS_FILE, "r", encoding="utf-8-sig") as f:
                content = f.read()

            for prop, (ctype, var) in controls.items():
                prop_name = prop.get('name')
                if ctype == 'bool':
                    new_value = 'true' if var.get() else 'false'
                else:
                    new_value = var.get()

                pattern = r'(<property\s+name="' + re.escape(prop_name) + r'"[^>]*?\bvalue=")[^"]*(")'
                content = re.sub(pattern, r'\g<1>' + str(new_value) + r'\2', content)

            with open(MAPS_FILE, "w", encoding="utf-8") as f:
                f.write(content)

            messagebox.showinfo(_("success"), _("config_saved"), parent=win)
            win.destroy()
        except Exception as e:
            messagebox.showerror(_("error"), f"Error saving XML: {e}", parent=win)

    tk.Button(win, text=_("btn_save"), command=save_config).pack(side="bottom", pady=10)

# Crear la ventana principal
root = tk.Tk()
root.title(_("app_title"))
root.geometry("600x750")
root.resizable(False, False)

from builder.ZXPWatcher import ZXPWatcher
from builder.ZXPHandler import ZXPHandler
from configuration.folders import MAP_FOLDER

# Procesar archivos ZXP inicialmente
handler = ZXPHandler()
for zxp_file in ["tiles.zxp", "sprites.zxp"]:
    zxp_path = MAP_FOLDER / zxp_file
    if zxp_path.exists():
        class FakeEvent:
            def __init__(self, path):
                self.src_path = str(path)
                self.is_directory = False
        handler.on_modified(FakeEvent(zxp_path))

# Iniciar el watcher
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
# Crear un frame horizontal para logo y botones
top_frame = tk.Frame(root)
top_frame.pack(pady=10, fill="x")

# Logo alineado a la izquierda
if logo_path.exists():
    logo = PhotoImage(file=logo_path)
    logo_label = tk.Label(top_frame, image=logo)
    logo_label.grid(row=0, column=0, rowspan=2, sticky="w", padx=10)
else:
    logo_label = tk.Label(top_frame, text=_("app_title"), font=("Arial", 16))
    logo_label.grid(row=0, column=0, rowspan=2, sticky="w", padx=10)

# Detectar idiomas disponibles
idiomas = []
idiomas_path = ASSETS_FOLDER / "texts"
if idiomas_path.exists():
    idiomas = [d for d in os.listdir(idiomas_path) if os.path.isdir(idiomas_path / d) and len(d) == 2]
idiomas.sort()

settings_icon_path = Path.cwd() / "ui/settings.png"
settings_icon = PhotoImage(file=settings_icon_path) if settings_icon_path.exists() else None
open_map_icon_path = Path.cwd() / "ui/map.png"
open_map_icon = PhotoImage(file=open_map_icon_path) if open_map_icon_path.exists() else None
game_icon_path = Path.cwd() / "ui/game.png"
game_icon = PhotoImage(file=game_icon_path) if game_icon_path.exists() else None
doc_icon_path = Path.cwd() / "ui/doc.png"
doc_icon = PhotoImage(file=doc_icon_path) if doc_icon_path.exists() else None

# Frame para los botones a la derecha del logo
button_frame = tk.Frame(top_frame)
button_frame.grid(row=0, column=1, sticky="ne", padx=10)

# Frame para la botonera izquierda (Open Game, Open Map, Open Doc)
left_buttons_frame = tk.Frame(button_frame)
left_buttons_frame.pack(side="left", anchor="n", padx=(0, 20))

# Open Game
open_game_button = tk.Button(
    left_buttons_frame,
    width=18,
    text=_("btn_open_game"),
    font=("Segoe UI Emoji", 10),
    anchor="w",
    command=lambda: open_game_variant("normal")
)
open_game_button.pack(anchor="w", pady=(0, 10))

# Helper functions for quick-open tiles/sprites
def open_tiles_zxp():
    try:
        path = MAP_FOLDER / "tiles.zxp"
        if not path.exists():
            messagebox.showerror("Error", f"No se encontró el fichero: {path}")
            return
        if CURRENT_OS == "Windows":
            os.startfile(str(path))
        elif CURRENT_OS == "Linux":
            subprocess.Popen(["xdg-open", str(path)])
        elif CURRENT_OS == "Darwin":
            subprocess.Popen(["open", str(path)])
        else:
            messagebox.showerror("Error", "El sistema operativo no es compatible.")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir tiles.zxp: {e}")

def open_sprites_zxp():
    try:
        path = MAP_FOLDER / "sprites.zxp"
        if not path.exists():
            messagebox.showerror("Error", f"No se encontró el fichero: {path}")
            return
        if CURRENT_OS == "Windows":
            os.startfile(str(path))
        elif CURRENT_OS == "Linux":
            subprocess.Popen(["xdg-open", str(path)])
        elif CURRENT_OS == "Darwin":
            subprocess.Popen(["open", str(path)])
        else:
            messagebox.showerror("Error", "El sistema operativo no es compatible.")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir sprites.zxp: {e}")

# Open Map
open_map_button = tk.Button(
    left_buttons_frame,
    width=18,
    text=_("btn_open_map"),
    font=("Segoe UI Emoji", 10),
    anchor="w",
    command=open_map_with_tiled
)
open_map_button.pack(anchor="w", pady=(0, 10))

# Quick buttons under Open Map
tk.Button(
    left_buttons_frame,
    width=18,
    text=_("btn_open_tiles"),
    font=("Segoe UI Emoji", 10),
    anchor="w",
    command=lambda: open_tiles_zxp()
).pack(anchor="w", pady=(0, 6))

tk.Button(
    left_buttons_frame,
    width=18,
    text=_("btn_open_sprites"),
    font=("Segoe UI Emoji", 10),
    anchor="w",
    command=lambda: open_sprites_zxp()
).pack(anchor="w", pady=(0, 10))

# Open HUD (abre el archivo assets/screens/hud.tmx)
open_hud_button = tk.Button(
    left_buttons_frame,
    width=18,
    text=_("btn_open_hud"),
    font=("Segoe UI Emoji", 10),
    anchor="w",
)
open_hud_button.pack(anchor="w", pady=(0, 10))
open_hud_button.bind("<Button-1>", show_hud_menu)

# Open Project (abre la carpeta raíz del proyecto) — usa el mismo icono que Open Doc
open_project_button = tk.Button(
    left_buttons_frame,
    text=_("btn_open_project"),
    width=18,
    font=("Segoe UI Emoji", 10),
    anchor="w",
    command=open_project_folder
)
open_project_button.pack(anchor="w", pady=(0, 10))

# Frame para la botonera derecha (un botón por idioma)
right_buttons_frame = tk.Frame(button_frame)
right_buttons_frame.pack(side="left", anchor="n")

def build_for_language(lang):
    os.environ["ZXSGM_I18N_FOLDER"] = lang
    executeBuild(False, lang)

tk.Button(
    right_buttons_frame,
    text=_("btn_build_default"),
    width=18,
    font=("Segoe UI Emoji", 10),
    anchor="w",
    command=lambda l="default": build_for_language(l)
).pack(anchor="w", pady=(0, 10))

for lang in idiomas:
    tk.Button(
        right_buttons_frame,
        text=_("btn_build_lang", lang.upper()),
        width=18,
        font=("Segoe UI Emoji", 10),
        anchor="w",
        command=lambda l=lang: build_for_language(l)
    ).pack(anchor="w", pady=(0, 10))

# Crear el menú de barras
menu_bar = tk.Menu(root)

# Menú "Build"
build_menu = tk.Menu(menu_bar, tearoff=0)
build_menu.add_command(label=_("menu_game"), command=lambda: executeBuild())
build_menu.add_command(label=_("menu_game_verbose"), command=lambda: executeBuild(verbose=True))
build_menu.add_command(label=_("menu_fx"), command=lambda: fxBuild())
build_menu.add_separator()
build_menu.add_command(label=_("menu_exit"), command=root.quit)
menu_bar.add_cascade(label=_("menu_build"), menu=build_menu)

# Menú "Configuration"
config_menu = tk.Menu(menu_bar, tearoff=0)
config_menu.add_command(label=_("menu_edit"), command=open_configuration_editor)
menu_bar.add_cascade(label=_("menu_configuration"), menu=config_menu)

# Menú "Map"
map_menu = tk.Menu(menu_bar, tearoff=0)
map_menu.add_command(label=_("menu_open_map"), command=open_map_with_tiled)
menu_bar.add_cascade(label=_("menu_map"), menu=map_menu)

# Menú "Sprites"
sprites_menu = tk.Menu(menu_bar, tearoff=0)

# Submenú para "Main Character"
main_character_menu = tk.Menu(sprites_menu, tearoff=0)
main_character_menu.add_command(label=_("menu_running"), command=open_main_character_running_preview)
main_character_menu.add_command(label=_("menu_idle"), command=open_main_character_idle_preview)
sprites_menu.add_cascade(label=_("menu_main_character"), menu=main_character_menu)

# Submenú para "Platforms"
platforms_menu = tk.Menu(sprites_menu, tearoff=0)
platforms_menu.add_command(label=_("menu_platform_1"), command=open_first_platform_preview)
platforms_menu.add_command(label=_("menu_platform_2"), command=open_second_platform_preview)
sprites_menu.add_cascade(label=_("menu_platforms"), menu=platforms_menu)

# Submenú para "Enemies"
enemies_menu = tk.Menu(sprites_menu, tearoff=0)
for i in range(1, 9):  # Generar dinámicamente las opciones de enemigos del 1 al 8
    enemies_menu.add_command(label=_("menu_enemy_num", i), command=lambda i=i: open_enemy_preview(i))
sprites_menu.add_cascade(label=_("menu_enemies"), menu=enemies_menu)

menu_bar.add_cascade(label=_("menu_sprites_preview"), menu=sprites_menu)

# Menú "Game"
game_menu = tk.Menu(menu_bar, tearoff=0)
game_menu.add_command(label=_("menu_normal"), command=lambda: open_game_variant("normal"))
game_menu.add_command(label=_("menu_rf"), command=lambda: open_game_variant("rf"))
menu_bar.add_cascade(label=_("menu_game"), menu=game_menu)

# Menú "Memory Usage"
memory_menu = tk.Menu(menu_bar, tearoff=0)
memory_menu.add_command(label=_("menu_bank_0_48k"), command=lambda: open_memory_bank_image("memory-bank-0-48K.png"))
memory_menu.add_command(label=_("menu_bank_0_128k"), command=lambda: open_memory_bank_image("memory-bank-0-128K.png"))
memory_menu.add_command(label=_("menu_bank_3"), command=lambda: open_memory_bank_image("memory-bank-3.png"))
memory_menu.add_command(label=_("menu_bank_4"), command=lambda: open_memory_bank_image("memory-bank-4.png"))
memory_menu.add_command(label=_("menu_bank_6"), command=lambda: open_memory_bank_image("memory-bank-6.png"))
menu_bar.add_cascade(label=_("menu_memory_usage"), menu=memory_menu)

# Menú "Help"
help_menu = tk.Menu(menu_bar, tearoff=0)
help_menu.add_command(label=_("menu_documentation"), command=lambda: webbrowser.open("https://gm.retrojuegos.org/"))
help_menu.add_command(label=_("menu_telegram"), command=lambda: webbrowser.open("https://t.me/zx_spectrum_game_maker"))
help_menu.add_command(label=_("menu_github"), command=lambda: webbrowser.open("https://github.com/rtorralba/zx-game-maker"))
menu_bar.add_cascade(label=_("menu_help"), menu=help_menu)

# Menú "Language"
lang_menu = tk.Menu(menu_bar, tearoff=0)
lang_menu.add_command(label="English", command=lambda: set_saved_language("en"))
lang_menu.add_command(label="Español", command=lambda: set_saved_language("es"))
lang_menu.add_command(label="Português", command=lambda: set_saved_language("pt"))
menu_bar.add_cascade(label=_("menu_language"), menu=lang_menu)

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
