import contextlib
from dataclasses import dataclass
import os
from pathlib import Path
import sys

from configuración.folders import OUTPUT_FOLDER
from zxtaputils import tapsplit

@dataclass
class TapItem:
    tapfile: str
    outdir: str

class MusicSetup:

    def __tapsplitCommandByOS(self):  # ???
        if os.name == "nt":
            return rf"py .\venv\Scripts\tapsplit --outdir {OUTPUT_FOLDER} "
        else:
            return ["tapsplit", "--outdir", f"{OUTPUT_FOLDER}"]
        
    def splitSongs(self):
        musicFile = Path("../assets/music/music.tap")
        if musicFile.is_file():
            with contextlib.redirect_stdout(None):
                tapsplit.tapsplit(TapItem(tapfile=str(musicFile), outdir=str(OUTPUT_FOLDER)))
            (OUTPUT_FOLDER / "music-001.tap").rename(OUTPUT_FOLDER / "music.tap")

        titleMusicFile = Path("../assets/music/title.tap")  # ??? "music-title.tap"
        if titleMusicFile.is_file():
            with contextlib.redirect_stdout(None):
                tapsplit.tapsplit(TapItem(tapfile=str(titleMusicFile), outdir=str(OUTPUT_FOLDER)))  
            (OUTPUT_FOLDER / "title-000.tap").rename(OUTPUT_FOLDER / "vtplayer.tap")
            (OUTPUT_FOLDER / "title-001.tap").rename(OUTPUT_FOLDER / "music-title.tap")

        musicFile = Path("../assets/music/music2.tap")
        if musicFile.is_file():
            with contextlib.redirect_stdout(None):
                tapsplit.tapsplit(TapItem(tapfile=str(musicFile), outdir=str(OUTPUT_FOLDER)))
            (OUTPUT_FOLDER / "music2-001.tap").rename(OUTPUT_FOLDER / "music2.tap")
        
        musicFile = Path("../assets/music/music3.tap")
        if musicFile.is_file():
            with contextlib.redirect_stdout(None):
                tapsplit.tapsplit(TapItem(tapfile=str(musicFile), outdir=str(OUTPUT_FOLDER)))
            (OUTPUT_FOLDER / "music3-001.tap").rename(OUTPUT_FOLDER / "music3.tap")
        
        musicFile = Path("../assets/music/ending.tap")  # ??? "music-ending.tap"
        if musicFile.is_file():
            with contextlib.redirect_stdout(None):
                tapsplit.tapsplit(TapItem(tapfile=str(musicFile), outdir=str(OUTPUT_FOLDER)))
            (OUTPUT_FOLDER / "ending-001.tap").rename(OUTPUT_FOLDER / "music-ending.tap")    
        
        musicFile = Path("../assets/music/gameover.tap")  # ??? "music-gameover.tap"
        if musicFile.is_file():
            with contextlib.redirect_stdout(None):
                tapsplit.tapsplit(TapItem(tapfile=str(musicFile), outdir=str(OUTPUT_FOLDER)))
            (OUTPUT_FOLDER / "gameover-001.tap").rename(OUTPUT_FOLDER / "music-gameover.tap")