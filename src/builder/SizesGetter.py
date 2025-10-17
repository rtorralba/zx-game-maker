import os
from pathlib import Path
from builder.Sizes import Sizes
from builder.helper import ASSETS_FOLDER, BIN_FOLDER, OUTPUT_FOLDER, musicExists, screenExists

class SizesGetter:
    def __init__(self, outputFolder, is128k, useBreakableTile):
        self.outputFolder = outputFolder
        self.is128k = is128k
        self.useBreakableTile = useBreakableTile

    def execute(self):
        sizes = Sizes()

        sizes.BEEP_FX = self.__getFileSize(ASSETS_FOLDER / "fx/fx.tap")
        sizes.TITLE_SCREEN = self.__getOutputFileSize("title.scr.zx0")
        sizes.ENDING_SCREEN = self.__getOutputFileSize("ending.scr.zx0")
        sizes.HUD_SCREEN = self.__getOutputFileSize("hud.scr.zx0")
        sizes.MAPS_DATA = self.__getOutputFileSize("map.bin.zx0")
        sizes.ENEMIES_DATA = self.__getOutputFileSize("enemies.bin.zx0")
        sizes.TILESET_DATA = self.__getOutputFileSize("tiles.bin")
        sizes.ATTR_DATA = self.__getOutputFileSize("attrs.bin")
        sizes.SCREEN_OFFSETS_DATA = self.__getOutputFileSize("screenOffsets.bin")
        sizes.ENEMIES_IN_SCREEN_OFFSETS_DATA = self.__getOutputFileSize("enemiesInScreenOffsets.bin")
        sizes.ANIMATED_TILES_IN_SCREEN_DATA = self.__getOutputFileSize("animatedTilesInScreen.bin")
        sizes.DAMAGE_TILES_DATA = self.__getOutputFileSize("damageTiles.bin")
        sizes.ENEMIES_PER_SCREEN_DATA = self.__getOutputFileSize("enemiesPerScreen.bin")
        sizes.ENEMIES_PER_SCREEN_INITIAL_DATA = self.__getOutputFileSize("enemiesPerScreen.bin")
        sizes.SCREEN_OBJECTS_DATA = self.__getOutputFileSize("screenObjects.bin")
        sizes.SCREENS_WON_DATA = self.__getOutputFileSize("screensWon.bin")
        sizes.DECOMPRESSED_ENEMIES_SCREEN_DATA = self.__getOutputFileSize("decompressedEnemiesScreen.bin")

        if self.useBreakableTile == 'all':
            sizes.BROKEN_TILES_DATA = self.__getOutputFileSize("brokenTiles.bin")
        
        if self.is128k:
            sizes.VTPLAYER = self.__getFileSize(BIN_FOLDER / "vtplayer.tap")
            sizes.MUSIC = self.__getFileSize(OUTPUT_FOLDER / "music.tap")
            sizes.MUSIC_TITLE = self.__getFileSize(OUTPUT_FOLDER / "music-title.tap") if musicExists("title") else 0
            sizes.MUSIC_2 = self.__getFileSize(OUTPUT_FOLDER / "music2.tap") if musicExists("music2") else 0
            sizes.MUSIC_3 = self.__getFileSize(OUTPUT_FOLDER / "music3.tap") if musicExists("music3") else 0
            sizes.MUSIC_ENDING = self.__getFileSize(OUTPUT_FOLDER / "music-ending.tap") if musicExists("ending") else 0
            sizes.MUSIC_GAMEOVER = self.__getFileSize(OUTPUT_FOLDER / "music-gameover.tap") if musicExists("gameover") else 0
            sizes.MUSIC_ARCADE_GOAL_ACHIEVED = self.__getFileSize(OUTPUT_FOLDER / "music-arcade-goal-achieved.tap") if musicExists("arcade-goal-achieved") else 0
            sizes.MUSIC_INTRO = self.__getFileSize(OUTPUT_FOLDER / "music-intro.tap") if musicExists("intro") else 0
            sizes.INTRO_SCREEN = self.__getOutputFileSize("intro.scr.zx0") if screenExists("intro") else 0
            sizes.GAMEOVER_SCREEN = self.__getOutputFileSize("gameover.scr.zx0") if screenExists("gameover") else 0

        return sizes
    
    def __getFileSize(self, file):
        return os.path.getsize(Path(file))

    def __getOutputFileSize(self, file):
        return self.__getFileSize(self.outputFolder / file)
