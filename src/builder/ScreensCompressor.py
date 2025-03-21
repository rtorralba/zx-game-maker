from pathlib import Path
import shutil
from builder.helper import *

class ScreensCompressor:
    def execute(self, is128k, introScreenExists, gameoverScreenExists):
        self.__compressScreen("title")
        self.__compressScreen("ending")
        self.__compressScreen("hud")

        if is128k:
            if introScreenExists:
                self.__compressScreen("intro")
            if gameoverScreenExists:
                self.__compressScreen("gameover")


        shutil.copy(SCREENS_FOLDER + "loading.scr", OUTPUT_FOLDER + "loading.bin")

    def __compressScreen(self, screen_name):
        runCommand(BIN_FOLDER + getZx0() + " -f " + SCREENS_FOLDER + screen_name + ".scr " + OUTPUT_FOLDER + screen_name + ".scr.zx0")