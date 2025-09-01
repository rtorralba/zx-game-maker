import os
from pathlib import Path
from builder.HudMessage import HudMessage
import tomllib

from configuration.folders import ASSETS_FOLDER, CONFIG_FILE, I18N_FOLDER

class TranslationsRetriever:
    def execute(self):
        language = os.getenv("ZXSGM_I18N_FOLDER", "default")

        messagesFile = ASSETS_FOLDER / "texts" / "messages.toml"
        if language != "default":
            file = ASSETS_FOLDER / "texts" / language / "messages.toml"
            if file.exists():
                messagesFile = file

        item_found = HudMessage("ITEM", "FOUND!", "green", "black")
        key_found = HudMessage("KEY", "FOUND!", "green", "black")
        ammo_found = HudMessage("AMMO", "FOUND!", "green", "black")
        life_found = HudMessage("LIFE", "FOUND!", "green", "black")
        no_keys = HudMessage("NO KEYS", "LEFT!", "red", "black")
        no_ammo = HudMessage("NO AMMO", "LEFT!", "red", "black")
        should_kill_all_enemies = HudMessage("KILL ALL", "ENEMIES!", "red", "black")

        if Path(messagesFile).exists():
            with open(messagesFile, mode="rb") as f:
                messages = tomllib.load(f)
            item_found = HudMessage(messages.get("item_found", {}).get("line1", "ITEM"),
                                    messages.get("item_found", {}).get("line2", "FOUND!"),
                                    messages.get("item_found", {}).get("ink", "green"),
                                    messages.get("item_found", {}).get("paper", "black"))
            key_found = HudMessage(messages.get("key_found", {}).get("line1", "KEY"),
                                    messages.get("key_found", {}).get("line2", "FOUND!"),
                                        messages.get("key_found", {}).get("ink", "green"),
                                        messages.get("key_found", {}).get("paper", "black"))
            ammo_found = HudMessage(messages.get("ammo_found", {}).get("line1", "AMMO"),
                                    messages.get("ammo_found", {}).get("line2", "FOUND!"),
                                    messages.get("ammo_found", {}).get("ink", "green"),
                                    messages.get("ammo_found", {}).get("paper", "black"))
            life_found = HudMessage(messages.get("life_found", {}).get("line1", "LIFE"),
                                    messages.get("life_found", {}).get("line2", "FOUND!"),
                                    messages.get("life_found", {}).get("ink", "green"),
                                    messages.get("life_found", {}).get("paper", "black"))
            no_keys = HudMessage(messages.get("no_keys", {}).get("line1", "NO KEYS"),
                                    messages.get("no_keys", {}).get("line2", "LEFT!"),
                                    messages.get("no_keys", {}).get("ink", "red"),
                                    messages.get("no_keys", {}).get("paper", "black"))
            no_ammo = HudMessage(messages.get("no_ammo", {}).get("line1", "NO AMMO"),
                                    messages.get("no_ammo", {}).get("line2", "LEFT!"),
                                    messages.get("no_ammo", {}).get("ink", "red"),
                                    messages.get("no_ammo", {}).get("paper", "black"))
            should_kill_all_enemies = HudMessage(messages.get("kill_all_enemies", {}).get("line1", "KILL ALL"),
                                                    messages.get("kill_all_enemies", {}).get("line2", "ENEMIES!"),
                                                    messages.get("kill_all_enemies", {}).get("ink", "red"),
                                                    messages.get("kill_all_enemies", {}).get("paper", "black"))
        # Write message config into boriel config file as a constants
        with open(CONFIG_FILE, "a") as config_file:
            config_file.write(f"\n' Messages\n")
            config_file.write(f"#define ITEM_FOUND_LINE1 \"{item_found.Line1}\"\n")
            config_file.write(f"#define ITEM_FOUND_LINE2 \"{item_found.Line2}\"\n")
            config_file.write(f"#define ITEM_FOUND_INK {item_found.Ink}\n")
            config_file.write(f"#define ITEM_FOUND_PAPER {item_found.Paper}\n")
            config_file.write(f"#define KEY_FOUND_LINE1 \"{key_found.Line1}\"\n")
            config_file.write(f"#define KEY_FOUND_LINE2 \"{key_found.Line2}\"\n")
            config_file.write(f"#define KEY_FOUND_INK {key_found.Ink}\n")
            config_file.write(f"#define KEY_FOUND_PAPER {key_found.Paper}\n")
            config_file.write(f"#define AMMO_FOUND_LINE1 \"{ammo_found.Line1}\"\n")
            config_file.write(f"#define AMMO_FOUND_LINE2 \"{ammo_found.Line2}\"\n")
            config_file.write(f"#define AMMO_FOUND_INK {ammo_found.Ink}\n")
            config_file.write(f"#define AMMO_FOUND_PAPER {ammo_found.Paper}\n")
            config_file.write(f"#define LIFE_FOUND_LINE1 \"{life_found.Line1}\"\n")
            config_file.write(f"#define LIFE_FOUND_LINE2 \"{life_found.Line2}\"\n")
            config_file.write(f"#define LIFE_FOUND_INK {life_found.Ink}\n")
            config_file.write(f"#define LIFE_FOUND_PAPER {life_found.Paper}\n")
            config_file.write(f"#define NO_KEYS_LINE1 \"{no_keys.Line1}\"\n")
            config_file.write(f"#define NO_KEYS_LINE2 \"{no_keys.Line2}\"\n")
            config_file.write(f"#define NO_KEYS_INK {no_keys.Ink}\n")
            config_file.write(f"#define NO_KEYS_PAPER {no_keys.Paper}\n")
            config_file.write(f"#define NO_AMMO_LINE1 \"{no_ammo.Line1}\"\n")
            config_file.write(f"#define NO_AMMO_LINE2 \"{no_ammo.Line2}\"\n")
            config_file.write(f"#define NO_AMMO_INK {no_ammo.Ink}\n")
            config_file.write(f"#define NO_AMMO_PAPER {no_ammo.Paper}\n")
            config_file.write(f"#define KILL_ALL_ENEMIES_LINE1 \"{should_kill_all_enemies.Line1}\"\n")
            config_file.write(f"#define KILL_ALL_ENEMIES_LINE2 \"{should_kill_all_enemies.Line2}\"\n")
            config_file.write(f"#define KILL_ALL_ENEMIES_INK {should_kill_all_enemies.Ink}\n")
            config_file.write(f"#define KILL_ALL_ENEMIES_PAPER {should_kill_all_enemies.Paper}\n\n")