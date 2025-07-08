import os
from pathlib import Path
import subprocess

class MusicSetup:

    def __tapsplitCommandByOS(self):
        if os.name == "nt":
            return r"py .\venv\Scripts\tapsplit --outdir output "
        else:
            return "tapsplit --outdir output "
        
    def splitSongs(self):
        musicFile = Path("../assets/music/music.tap")
        if musicFile.is_file():
            tapsplitCommand = self.__tapsplitCommandByOS() + str(musicFile)
            subprocess.run(tapsplitCommand, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            os.rename("output/music-001.tap", "output/music.tap")

        titleMusicFile = Path("../assets/music/title.tap")
        if titleMusicFile.is_file():
            tapsplitCommand = self.__tapsplitCommandByOS() + str(titleMusicFile)
            subprocess.run(tapsplitCommand, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            os.rename("output/title-000.tap", "output/vtplayer.tap")
            os.rename("output/title-001.tap", "output/music-title.tap")

        musicFile = Path("../assets/music/music2.tap")
        if musicFile.is_file():
            tapsplitCommand = self.__tapsplitCommandByOS() + str(musicFile)
            subprocess.run(tapsplitCommand, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            os.rename("output/music2-001.tap", "output/music2.tap")
        
        musicFile = Path("../assets/music/music3.tap")
        if musicFile.is_file():
            tapsplitCommand = self.__tapsplitCommandByOS() + str(musicFile)
            subprocess.run(tapsplitCommand, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            os.rename("output/music3-001.tap", "output/music3.tap")
        
        musicFile = Path("../assets/music/ending.tap")
        if musicFile.is_file():
            tapsplitCommand = self.__tapsplitCommandByOS() + str(musicFile)
            subprocess.run(tapsplitCommand, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            os.rename("output/ending-001.tap", "output/music-ending.tap")
        
        musicFile = Path("../assets/music/gameover.tap")
        if musicFile.is_file():
            tapsplitCommand = self.__tapsplitCommandByOS() + str(musicFile)
            subprocess.run(tapsplitCommand, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            os.rename("output/gameover-001.tap", "output/music-gameover.tap")