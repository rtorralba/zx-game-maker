
from builder.Sizes import Sizes
from builder.helper import getEnabled128K, getUseBreakableTile, musicExists, screenExists

class ConfigWriter:
    def __init__(self, basicConfigPath, initialAddress, sizes: Sizes):
        self.initialAddress = initialAddress
        self.basicConfigPath = basicConfigPath
        self.sizes = sizes

    def execute(self):
        currentAddress = self.initialAddress
        with open(self.basicConfigPath, 'a') as config_bas:
            self.__setFileHandler(config_bas)
            if getEnabled128K():
                self.__write("\n' Memory bank 3\n")
                currentAddress = self.__writeDeclarationAndIncrement(Sizes.TITLE_SCREEN_STRING(), currentAddress)
                currentAddress = self.__writeDeclarationAndIncrement(Sizes.ENDING_SCREEN_STRING(), currentAddress)
                currentAddress = self.__writeDeclarationAndIncrement(Sizes.HUD_SCREEN_STRING(), currentAddress)

                if screenExists("intro"):
                    currentAddress = self.__writeDeclarationAndIncrement(Sizes.INTRO_SCREEN_STRING(), currentAddress)
                    self.__write("#DEFINE INTRO_SCREEN_ENABLED\n")
                
                if screenExists("gameover"):
                    currentAddress = self.__writeDeclarationAndIncrement(Sizes.GAMEOVER_SCREEN_STRING(), currentAddress)
                    self.__write("#DEFINE GAMEOVER_SCREEN_ENABLED\n")
                
                if musicExists("title"):
                    self.__write("#DEFINE TITLE_MUSIC_ENABLED\n")
                
                self.__write("\n")
                currentAddress = self.initialAddress
            else:
                currentAddress += self.sizes.BEEP_FX
                currentAddress = self.__writeDeclarationAndIncrement(Sizes.TITLE_SCREEN_STRING(), currentAddress)
                currentAddress = self.__writeDeclarationAndIncrement(Sizes.ENDING_SCREEN_STRING(), currentAddress)
                currentAddress = self.__writeDeclarationAndIncrement(Sizes.HUD_SCREEN_STRING(), currentAddress)

            for key, value in vars(self.sizes).items():
                if key in Sizes.getKeysToMemoryBank():
                    continue
                currentAddress = self.__writeDeclarationAndIncrement(key, currentAddress)

            if getUseBreakableTile():
                self.__writeDeclarationAndIncrement(Sizes.BROKEN_TILES_DATA_STRING(), currentAddress)

    def __setFileHandler(self, fileHandler):
        self.fileHandler = fileHandler

    def __getDeclaration(self, name, address):
        return "const {}_ADDRESS as uinteger={}\n".format(name, address)

    def __write(self, content):
        self.fileHandler.write(content)

    def __writeDeclarationAndIncrement(self, name, address):
        self.__write(self.__getDeclaration(name, address))
        return address + getattr(self.sizes, name)
