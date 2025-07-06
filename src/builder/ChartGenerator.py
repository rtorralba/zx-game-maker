
from builder import Sizes
from builder.helper import BIN_FOLDER, runPythonScript

class ChartGenerator:
    def execute(self, sizes: Sizes, is128k):
        enemiesSize = sizes.ENEMIES_DATA + sizes.ENEMIES_IN_SCREEN_OFFSETS_DATA + sizes.ENEMIES_PER_SCREEN_DATA + sizes.ENEMIES_PER_SCREEN_INITIAL_DATA + sizes.DECOMPRESSED_ENEMIES_SCREEN_DATA
        mapsSize = sizes.MAPS_DATA + sizes.SCREEN_OFFSETS_DATA + sizes.SCREEN_OBJECTS_DATA + sizes.SCREENS_WON_DATA
        if is128k:
            paramsMap0 = "Maps:" + str(mapsSize) + ",Enemies:" + str(enemiesSize) + ",Tileset:" + str(sizes.TILESET_DATA) + ",Attributes:" + str(sizes.ATTR_DATA) + ",Objects:" + str(sizes.SCREEN_OBJECTS_INITIAL_DATA) + ",Damage-Tiles:" + str(sizes.DAMAGE_TILES_DATA) + ",Animated-Tiles:" + str(sizes.ANIMATED_TILES_IN_SCREEN_DATA) + " memory-bank-0-128K.png"
            paramsMap3 = "Vortex-Player:" + str(sizes.VTPLAYER) + ",Title-Music:" + str(sizes.TITLE_MUSIC) + ",Ingame-Music:" + str(sizes.MUSIC) + ",Ingame-2-Music:" + str(sizes.MUSIC_2) + ",Ingame-3-Music:" + str(sizes.MUSIC_3) + " memory-bank-3.png"
            paramsMap4 = "Title-Screen:" + str(sizes.TITLE_SCREEN) + ",End-Screen:" + str(sizes.ENDING_SCREEN) + ",HUD:" + str(sizes.HUD_SCREEN) + ",Intro-Screen:" + str(sizes.INTRO_SCREEN) + ",GameOver-Screen:" + str(sizes.GAMEOVER_SCREEN) + " memory-bank-4.png"
            paramsMap6 = "FX:" + str(sizes.BEEP_FX) + " memory-bank-6.png"

            self.__generateMemoryChart(paramsMap3)
            self.__generateMemoryChart(paramsMap4)
            self.__generateMemoryChart(paramsMap6)
        else:
            paramsMap0 = "FX:" + str(sizes.BEEP_FX) + ",Title-Screen:" + str(sizes.TITLE_SCREEN) + ",End-Screen:" + str(sizes.ENDING_SCREEN) + ",HUD:" + str(sizes.HUD_SCREEN) + ",Maps:" + str(mapsSize) + ",Enemies:" + str(enemiesSize) + ",Tileset:" + str(sizes.TILESET_DATA) + ",Attributes:" + str(sizes.ATTR_DATA) + ",Objects:" + str(sizes.SCREEN_OBJECTS_INITIAL_DATA) + ",Damage-Tiles:" + str(sizes.DAMAGE_TILES_DATA) + ",Animated-Tiles:" + str(sizes.ANIMATED_TILES_IN_SCREEN_DATA) + " memory-bank-0-48K.png"

        self.__generateMemoryChart(paramsMap0)
    
    def __generateMemoryChart(self, params):
        runPythonScript(BIN_FOLDER + "memoryImageGenerator.py " + params)