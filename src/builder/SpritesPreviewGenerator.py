from pathlib import Path
from PIL import Image
import webbrowser

from builder.helper import MAP_FOLDER, OUTPUT_FOLDER

sprite_width = 16
sprite_height = 16

class SpritesPreviewGenerator:
    @staticmethod
    def generateMainPreview():
        gif_path = OUTPUT_FOLDER / 'main.gif'
        SpritesPreviewGenerator.generateGif(0, 0, 2, gif_path)
        return gif_path
    
    @staticmethod
    def generateFirstPreview():
        gif_path = OUTPUT_FOLDER / 'first-platform.gif'
        SpritesPreviewGenerator.generateGif(0, 8, 9, gif_path)
        return gif_path
    
    @staticmethod
    def generateSecondPreview():
        gif_path = OUTPUT_FOLDER / 'second-platform.gif'
        SpritesPreviewGenerator.generateGif(0, 10, 11, gif_path)
        return gif_path

    @staticmethod
    def generateIdlePreview():
        gif_path = OUTPUT_FOLDER / 'idle.gif'
        SpritesPreviewGenerator.generateGif(0, 12, 13, gif_path)
        return gif_path
    
    @staticmethod
    def generateEnemy(enemyNumber):
        gif_path = OUTPUT_FOLDER / ('enemy' + str(enemyNumber) + '.gif')
        
        #calculate spriteFrom knowing that each enemy has 2 sprites
        spriteFrom = (enemyNumber - 1) * 2
        spriteTo = spriteFrom + 1
        
        SpritesPreviewGenerator.generateGif(1, spriteFrom, spriteTo, gif_path)
        return gif_path
    
    @staticmethod
    def generateGif(row, spriteFrom, spriteTo, gifPath):
        spritesheet = Image.open(MAP_FOLDER / 'sprites.png')
        
        sprites = []
        
        for i in range(spriteFrom, spriteTo + 1):
            sprite = spritesheet.crop((i * sprite_width, row * sprite_height, (i + 1) * sprite_width, (row + 1) * sprite_height))
            sprites.append(sprite)

        for i in range(len(sprites)):
            sprites[i] = sprites[i].resize((sprite_width * 5, sprite_height * 5), Image.NEAREST)
        
        sprites[0].save(str(gifPath), save_all=True, append_images=sprites[1:], duration=300, loop=0)
