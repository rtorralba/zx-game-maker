from builder.ConvertZXPToGuSprites import ConvertZXPToGuSprites
from builder.MusicSetup import MusicSetup
from builder.ScreensCompressor import ScreensCompressor
from builder.TilesGenerator import TilesGenerator
from builder.SpritesGenerator import SpritesGenerator
from builder.BinaryFilesToTapMerger import BinaryFilesToTapMerger
from builder.SizesGetter import SizesGetter
from builder.ChartGenerator import ChartGenerator
from builder.ConfigWriter import ConfigWriter
from builder.helper import *

class Builder:
    def execute(self):
        is128K = getEnabled128K()
        useBreakableTile = getUseBreakableTile()

        ScreensCompressor().execute(is128K, screenExists("intro"), screenExists("gameover"))
        TilesGenerator().execute()
        SpritesGenerator().execute()
        MusicSetup().splitSongs()
        ConvertZXPToGuSprites.convert()
        BinaryFilesToTapMerger().execute(is128K, useBreakableTile)
        sizes = SizesGetter(OUTPUT_FOLDER, is128K, useBreakableTile).execute()
        ChartGenerator().execute(sizes, is128K)
        ConfigWriter(OUTPUT_FOLDER / "config.bas", INITIAL_ADDRESS, sizes).execute()

        return sizes
