from pathlib import Path
from PIL import Image
from GenerateShiftedData import GenerateShiftedData
from Charset import CharSet
from ZXPToSpritesConversor import ZXPToSpritesConversor
from PreshiftedSpritesWriter import PreshiftedSpritesWriter

def preshiftSprites(sprites, charWidth=2, charHeight=2):
    preshiftedSprites = []
    for sprite in sprites:
        charset = CharSet.createFromSprite(sprite, charWidth, charHeight)
        preshiftedSprites.append(GenerateShiftedData.generate(charset))
    
    return preshiftedSprites

output_file = "boriel/lib/Sprites.zxbas"

sprites = ZXPToSpritesConversor.convert(str(Path("../assets/map/sprites.zxp")))
#sprites.append(ZXPToSpritesConversor.convert(str(Path("../assets/map/bullet.zxp")), 2, 8, 8))

preshiftedSprites = preshiftSprites(sprites, 2, 2)

PreshiftedSpritesWriter.write(preshiftedSprites, output_file)