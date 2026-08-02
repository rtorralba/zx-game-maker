import os
from pathlib import Path
from builder.HudMessage import HudMessage
import tomllib

from builder.helper import getArcadeModeEnabled, getDashEnabled
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
        need_items = HudMessage("NEED", "ITEMS!", "red", "black")
        hurry_up = HudMessage("HURRY UP", "HURRY UP", "red", "black")
        arcade_goal = HudMessage("REACH", "THE KEY!", "blue", "black")
        dash_active = HudMessage("DASH", "ACTIVE", "green", "black")

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
            should_kill_all_enemies = HudMessage(messages.get("should_kill_all_enemies", {}).get("line1", "KILL ALL"),
                                                    messages.get("should_kill_all_enemies", {}).get("line2", "ENEMIES!"),
                                                    messages.get("should_kill_all_enemies", {}).get("ink", "red"),
                                                    messages.get("should_kill_all_enemies", {}).get("paper", "black"))
            need_items = HudMessage(messages.get("need_items", {}).get("line1", "NEED"),
                                    messages.get("need_items", {}).get("line2", "ITEMS!"),
                                    messages.get("need_items", {}).get("ink", "red"),
                                    messages.get("need_items", {}).get("paper", "black"))
            if getArcadeModeEnabled():
                hurry_up = HudMessage(messages.get("hurry_up", {}).get("line1", "HURRY UP"),
                                        messages.get("hurry_up", {}).get("line2", "HURRY UP"),
                                        messages.get("hurry_up", {}).get("ink", "red"),
                                        messages.get("hurry_up", {}).get("paper", "black"))
                arcade_goal = HudMessage(messages.get("arcade_goal", {}).get("line1", "REACH"),
                                        messages.get("arcade_goal", {}).get("line2", "THE KEY!"),
                                        messages.get("arcade_goal", {}).get("ink", "blue"),
                                        messages.get("arcade_goal", {}).get("paper", "black"))
            if getDashEnabled():
                dash_active = HudMessage(messages.get("dash_active", {}).get("line1", "DASH"),
                                        messages.get("dash_active", {}).get("line2", "ACTIVE"),
                                        messages.get("dash_active", {}).get("ink", "green"),
                                        messages.get("dash_active", {}).get("paper", "black"))

        # Write message config into boriel config file as a constants
        with open(CONFIG_FILE, "a") as config_file:
            config_file.write(f"\n' Messages\n")

            def write_msg(prefix, msg):
                if msg.Line1 != "" or msg.Line2 != "":
                    config_file.write(f"#define {prefix}_LINE1 \"{msg.Line1}\"\n")
                    config_file.write(f"#define {prefix}_LINE2 \"{msg.Line2}\"\n")
                    config_file.write(f"#define {prefix}_INK {msg.Ink}\n")
                    config_file.write(f"#define {prefix}_PAPER {msg.Paper}\n")

            write_msg("ITEM_FOUND", item_found)
            write_msg("KEY_FOUND", key_found)
            write_msg("AMMO_FOUND", ammo_found)
            write_msg("LIFE_FOUND", life_found)
            write_msg("NO_KEYS", no_keys)
            write_msg("NO_AMMO", no_ammo)
            write_msg("KILL_ALL_ENEMIES", should_kill_all_enemies)
            write_msg("NEED_ITEMS", need_items)
            if getArcadeModeEnabled():
                write_msg("HURRY_UP", hurry_up)
                write_msg("ARCADE_GOAL", arcade_goal)
            if getDashEnabled():
                write_msg("DASH_ACTIVE", dash_active)