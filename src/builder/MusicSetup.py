import os
from pathlib import Path
from argparse import Namespace
from zxtaputils import tapsplit
import sys

from configuration.folders import OUTPUT_FOLDER

class MusicSetup:
    def __tapsplit(self, musicFile):
        args = Namespace()
        args.tapfile = str(musicFile)
        args.outdir = str(OUTPUT_FOLDER)
        with open(os.devnull, 'w') as devnull:
            old_stdout = sys.stdout
            old_stderr = sys.stderr
            sys.stdout = devnull
            sys.stderr = devnull
            try:
                tapsplit.tapsplit(args)
            finally:
                sys.stdout = old_stdout
                sys.stderr = old_stderr

    def splitSongs(self):
        musicFile = Path("../assets/music/music.tap")
        if musicFile.is_file():
            self.__tapsplit(musicFile)
            os.rename("output/music-001.tap", "output/music.tap")

        titleMusicFile = Path("../assets/music/title.tap")
        if titleMusicFile.is_file():
            self.__tapsplit(titleMusicFile)

            os.rename("output/title-000.tap", "output/vtplayer.tap")
            os.rename("output/title-001.tap", "output/music-title.tap")

        musicFile = Path("../assets/music/music2.tap")
        if musicFile.is_file():
            self.__tapsplit(musicFile)

            os.rename("output/music2-001.tap", "output/music2.tap")
        
        musicFile = Path("../assets/music/music3.tap")
        if musicFile.is_file():
            self.__tapsplit(musicFile)

            os.rename("output/music3-001.tap", "output/music3.tap")
        
        musicFile = Path("../assets/music/ending.tap")
        if musicFile.is_file():
            self.__tapsplit(musicFile)

            os.rename("output/ending-001.tap", "output/music-ending.tap")
        
        musicFile = Path("../assets/music/gameover.tap")
        if musicFile.is_file():
            self.__tapsplit(musicFile)

            os.rename("output/gameover-001.tap", "output/music-gameover.tap")
        
        musicFile = Path("../assets/music/stage-clear.tap")
        if musicFile.is_file():
            self.__tapsplit(musicFile)

            os.rename("output/stage-clear-001.tap", "output/music-stage-clear.tap")
        
        musicFile = Path("../assets/music/intro.tap")
        if musicFile.is_file():
            self.__tapsplit(musicFile)

            os.rename("output/intro-001.tap", "output/music-intro.tap")