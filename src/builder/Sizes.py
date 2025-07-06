from builder.helper import MEMORY_BANK_SIZE


class Sizes:
    def __init__(self):
        self.BEEP_FX = 0
        self.TITLE_SCREEN = 0
        self.ENDING_SCREEN = 0
        self.HUD_SCREEN = 0
        self.MAPS_DATA = 0
        self.ENEMIES_DATA = 0
        self.TILESET_DATA = 0
        self.ATTR_DATA = 0
        self.SCREEN_OBJECTS_INITIAL_DATA = 0
        self.SCREEN_OFFSETS_DATA = 0
        self.ENEMIES_IN_SCREEN_OFFSETS_DATA = 0
        self.ANIMATED_TILES_IN_SCREEN_DATA = 0
        self.DAMAGE_TILES_DATA = 0
        self.ENEMIES_PER_SCREEN_DATA = 0
        self.ENEMIES_PER_SCREEN_INITIAL_DATA = 0
        self.SCREEN_OBJECTS_DATA = 0
        self.SCREENS_WON_DATA = 0
        self.DECOMPRESSED_ENEMIES_SCREEN_DATA = 0
        self.BROKEN_TILES_DATA = 0
        self.MUSIC = 0
        self.INTRO_SCREEN = 0
        self.GAMEOVER_SCREEN = 0
        self.TITLE_MUSIC = 0
        self.VTPLAYER = 0
        self.MUSIC_2 = 0
        self.MUSIC_3 = 0
    
    @staticmethod
    def BEEP_FX_STRING():
        return "BEEP_FX"
    
    @staticmethod
    def TITLE_SCREEN_STRING():
        return "TITLE_SCREEN"
    
    @staticmethod
    def ENDING_SCREEN_STRING():
        return "ENDING_SCREEN"
    
    @staticmethod
    def HUD_SCREEN_STRING():
        return "HUD_SCREEN"
    
    @staticmethod
    def MAPS_DATA_STRING():
        return "MAPS_DATA"
    
    @staticmethod
    def ENEMIES_DATA_STRING():
        return "ENEMIES_DATA"
    
    @staticmethod
    def TILESET_DATA_STRING():
        return "TILESET_DATA"
    
    @staticmethod
    def ATTR_DATA_STRING():
        return "ATTR_DATA"
    
    @staticmethod
    def SCREEN_OBJECTS_INITIAL_DATA_STRING():
        return "SCREEN_OBJECTS_INITIAL_DATA"
    
    @staticmethod
    def SCREEN_OFFSETS_DATA_STRING():
        return "SCREEN_OFFSETS_DATA"
    
    @staticmethod
    def ENEMIES_IN_SCREEN_OFFSETS_DATA_STRING():
        return "ENEMIES_IN_SCREEN_OFFSETS_DATA"
    
    @staticmethod
    def ANIMATED_TILES_IN_SCREEN_DATA_STRING():
        return "ANIMATED_TILES_IN_SCREEN_DATA"
    
    @staticmethod
    def DAMAGE_TILES_DATA_STRING():
        return "DAMAGE_TILES_DATA"

    @staticmethod
    def ENEMIES_PER_SCREEN_DATA_STRING():
        return "ENEMIES_PER_SCREEN_DATA"
    
    @staticmethod
    def ENEMIES_PER_SCREEN_INITIAL_DATA_STRING():
        return "ENEMIES_PER_SCREEN_INITIAL_DATA"
    
    @staticmethod
    def SCREEN_OBJECTS_DATA_STRING():
        return "SCREEN_OBJECTS_DATA"
    
    @staticmethod
    def SCREENS_WON_DATA_STRING():
        return "SCREENS_WON_DATA"
    
    @staticmethod
    def DECOMPRESSED_ENEMIES_SCREEN_DATA_STRING():
        return "DECOMPRESSED_ENEMIES_SCREEN_DATA"
    
    @staticmethod
    def BROKEN_TILES_DATA_STRING():
        return "BROKEN_TILES_DATA"
    
    @staticmethod
    def MUSIC_STRING():
        return "MUSIC"
    
    @staticmethod
    def INTRO_SCREEN_STRING():
        return "INTRO_SCREEN"
    
    @staticmethod
    def GAMEOVER_SCREEN_STRING():
        return "GAMEOVER_SCREEN"
    
    @staticmethod
    def TITLE_MUSIC_STRING():
        return "TITLE_MUSIC"

    @staticmethod
    def VTPLAYER_STRING():
        return "VTPLAYER"

    @staticmethod
    def MUSIC_2_STRING():
        return "MUSIC_2"

    @staticmethod
    def MUSIC_3_STRING():
        return "MUSIC_3"

    @staticmethod
    def getKeysToMemoryBank():
        return ["BEEP_FX", "TITLE_SCREEN", "ENDING_SCREEN", "HUD_SCREEN", "INTRO_SCREEN", "GAMEOVER_SCREEN", "MUSIC", "BROKEN_TILES_DATA", "TITLE_MUSIC", "MUSIC_2", "MUSIC_3", "VTPLAYER"]

    def printAllSizesByMemoryBankFor128(self):

        self.__printSizesArraySum([
            self.MAPS_DATA_STRING(),
            self.SCREEN_OFFSETS_DATA_STRING(),
            self.SCREEN_OBJECTS_DATA_STRING(),
            self.SCREENS_WON_DATA_STRING(),
            self.ENEMIES_DATA_STRING(),
            self.ENEMIES_IN_SCREEN_OFFSETS_DATA_STRING(),
            self.ENEMIES_PER_SCREEN_DATA_STRING(),
            self.ENEMIES_PER_SCREEN_INITIAL_DATA_STRING(),
            self.DECOMPRESSED_ENEMIES_SCREEN_DATA_STRING(),
            self.TILESET_DATA_STRING(),
            self.ATTR_DATA_STRING(),
            self.SCREEN_OBJECTS_INITIAL_DATA_STRING(),
            self.DAMAGE_TILES_DATA_STRING(),
            self.ANIMATED_TILES_IN_SCREEN_DATA_STRING()
        ], "0")

        self.__printSizesArraySum([self.TITLE_SCREEN_STRING(), self.ENDING_SCREEN_STRING(), self.HUD_SCREEN_STRING(), self.GAMEOVER_SCREEN_STRING(), self.INTRO_SCREEN_STRING()], "3")
        self.__printSizesArraySum([self.VTPLAYER_STRING(), self.TITLE_MUSIC_STRING(), self.MUSIC_STRING(), self.MUSIC_2_STRING(), self.MUSIC_3_STRING()], "4")
        self.__printSizesArraySum([self.BEEP_FX_STRING()], "6")


    def printAllSizesByMemoryBankFor48(self):
        self.__printSizesArraySum([
            self.MAPS_DATA_STRING(),
            self.SCREEN_OFFSETS_DATA_STRING(),
            self.SCREEN_OBJECTS_DATA_STRING(),
            self.SCREENS_WON_DATA_STRING(),
            self.ENEMIES_DATA_STRING(),
            self.ENEMIES_IN_SCREEN_OFFSETS_DATA_STRING(),
            self.ENEMIES_PER_SCREEN_DATA_STRING(),
            self.ENEMIES_PER_SCREEN_INITIAL_DATA_STRING(),
            self.DECOMPRESSED_ENEMIES_SCREEN_DATA_STRING(),
            self.TILESET_DATA_STRING(),
            self.ATTR_DATA_STRING(),
            self.SCREEN_OBJECTS_INITIAL_DATA_STRING(),
            self.DAMAGE_TILES_DATA_STRING(),
            self.ANIMATED_TILES_IN_SCREEN_DATA_STRING(),
            self.BEEP_FX_STRING(),
            self.TITLE_SCREEN_STRING(),
            self.ENDING_SCREEN_STRING(),
            self.HUD_SCREEN_STRING(),
        ], "0")

    def __printSizesArraySum(self, sizesArray, name):
        memoryBankSize = 0
        for key in sizesArray:
            memoryBankSize += getattr(self, key)
        
        memoryBankSizeStr = str(memoryBankSize).rjust(5)
        freeMemoryStr = str(MEMORY_BANK_SIZE - memoryBankSize).rjust(5)
        
        print("Bank " + name + ".." + memoryBankSizeStr + "/" + str(MEMORY_BANK_SIZE) + " bytes. Free: " + freeMemoryStr + " bytes")