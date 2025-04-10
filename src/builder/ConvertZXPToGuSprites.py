from pathlib import Path
from builder.GenerateShiftedData import GenerateShiftedData
from builder.Charset import CharSet
from builder.ZXPToSpritesConversor import ZXPToSpritesConversor
from builder.PreshiftedSpritesWriter import PreshiftedSpritesWriter

class ConvertZXPToGuSprites:
    @staticmethod
    def preshiftSprites(sprites):
        preshiftedSprites = []
        for sprite in sprites:
            charset = CharSet.createFromSprite(sprite.data, sprite.width // 8, sprite.height // 8)
            preshiftedSprites.append(GenerateShiftedData.generate(charset))
        
        return preshiftedSprites
    
    @staticmethod
    def convert():
        output_file = "boriel/lib/Sprites.zxbas"

        sprites = ZXPToSpritesConversor.convert(str(Path("../assets/map/sprites.zxp")))
        sprites.extend(ZXPToSpritesConversor.convert(str(Path("../assets/map/bullet.zxp")), 2, 8, 8))  # Use extend instead of append

        preshiftedSprites = ConvertZXPToGuSprites.preshiftSprites(sprites)

        PreshiftedSpritesWriter.write(preshiftedSprites, output_file)