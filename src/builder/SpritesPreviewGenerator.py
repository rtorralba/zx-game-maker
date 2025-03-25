from pathlib import Path
from PIL import Image
import webbrowser

sprite_width = 16
sprite_height = 16

class SpritesPreviewGenerator:
    @staticmethod
    def generateMainPreview():
        gif_path = 'assets/map/previews/main.gif'
        SpritesPreviewGenerator.generateGif(0, 0, 2, gif_path)
        webbrowser.open('file://' + str(Path(gif_path).resolve()))
    
    @staticmethod
    def generateFirstPreview():
        gif_path = 'assets/map/previews/first-platform.gif'
        SpritesPreviewGenerator.generateGif(0, 8, 9, gif_path)
        webbrowser.open('file://' + str(Path(gif_path).resolve()))
    
    @staticmethod
    def generateSecondPreview():
        gif_path = 'assets/map/previews/second-platform.gif'
        SpritesPreviewGenerator.generateGif(0, 10, 11, gif_path)
        webbrowser.open('file://' + str(Path(gif_path).resolve()))

    @staticmethod
    def generateIdlePreview():
        gif_path = 'assets/map/previews/idle.gif'
        SpritesPreviewGenerator.generateGif(0, 12, 13, gif_path)
        webbrowser.open('file://' + str(Path(gif_path).resolve()))
    
    @staticmethod
    def generateEnemy(enemyNumber):
        gif_path = 'assets/map/previews/enemy' + str(enemyNumber) + '.gif'
        
        #calculate spriteFrom knowing that each enemy has 2 sprites
        spriteFrom = (enemyNumber - 1) * 2
        spriteTo = spriteFrom + 1
        
        SpritesPreviewGenerator.generateGif(1, spriteFrom, spriteTo, gif_path)
        webbrowser.open('file://' + str(Path(gif_path).resolve()))
    
    @staticmethod
    def generateGif(row, spriteFrom, spriteTo, gifPath):
        spritesheet = Image.open('assets/map/sprites.png')
        
        sprites = []
        
        for i in range(spriteFrom, spriteTo + 1):
            sprite = spritesheet.crop((i * sprite_width, row * sprite_height, (i + 1) * sprite_width, (row + 1) * sprite_height))
            sprites.append(sprite)

        for i in range(len(sprites)):
            sprites[i] = sprites[i].resize((sprite_width * 5, sprite_height * 5), Image.NEAREST)
        
        if not Path('assets/map/previews').exists():
            Path('assets/map/previews').mkdir()
        
        sprites[0].save(gifPath, save_all=True, append_images=sprites[1:], duration=200, loop=0)