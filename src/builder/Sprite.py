class Sprite:
    def __init__(self, data, width, height):
        self.data = data
        self.width = width
        self.height = height
    
    def __str__(self):
        return f"Sprite(width={self.width}, height={self.height})"
