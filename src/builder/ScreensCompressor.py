from pathlib import Path
import shutil
from builder.helper import *

class ScreensCompressor:
    def execute(self, is128k):
        self.__compressScreen("title")
        self.__compressScreen("ending")
        self.__compressScreen("hud")

        if is128k:
            if screenExists("intro"):
                self.__compressScreen("intro")
            if screenExists("gameover"):
                self.__compressScreen("gameover")


        shutil.copy(SCREENS_FOLDER / "loading.scr", OUTPUT_FOLDER / "loading.bin")

    def __compressScreen(self, screen_name):
        scrFile = str((SCREENS_FOLDER / screen_name).with_suffix(".scr"))
        
        language = os.getenv("ZXSGM_I18N_FOLDER", "default")
        if language != "default":
            file = str((SCREENS_FOLDER / language / screen_name).with_suffix(".scr"))
            if Path(file).exists():
                scrFile = file

        runCommand(str(BIN_FOLDER / getZx0()) + " " + scrFile + " " + str((OUTPUT_FOLDER / screen_name).with_suffix(".scr.zx0")))
