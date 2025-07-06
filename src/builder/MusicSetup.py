import os
import glob
from pathlib import Path

class MusicSetup:

    def splitSongs(self):
        musicFile = Path("../assets/music/music.tap")
        if musicFile.is_file():
            tapsplitCommand = "tapsplit --outdir output " + str(musicFile)
            os.system(tapsplitCommand)

            os.rename("output/music-001.tap", "output/music.tap")

        titleMusicFile = Path("../assets/music/title.tap")
        if titleMusicFile.is_file():
            tapsplitCommand = "tapsplit --outdir output " + str(titleMusicFile)
            os.system(tapsplitCommand)

            os.rename("output/title-000.tap", "output/vtplayer.tap")
            os.rename("output/title-001.tap", "output/music-title.tap")

        musicFile = Path("../assets/music/music_2.tap")
        if musicFile.is_file():
            tapsplitCommand = "tapsplit --outdir output " + str(musicFile)
            os.system(tapsplitCommand)

            os.rename("output/music_2-001.tap", "output/music_2.tap")
        
        musicFile = Path("../assets/music/music_3.tap")
        if musicFile.is_file():
            tapsplitCommand = "tapsplit --outdir output " + str(musicFile)
            os.system(tapsplitCommand)

            os.rename("output/music_3-001.tap", "output/music_3.tap")