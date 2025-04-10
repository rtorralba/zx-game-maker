class PreshiftedSprite:
    """
    A class representing a sprite with pre-shifted pixels.
    
    Attributes:
        pixels (list): A list of pixel values representing the sprite.
        width (int): The width of the sprite.
        height (int): The height of the sprite.
    """

    def __init__(self, pixels, width, height):
        """
        Initializes the PreshiftedSprite with given pixel data, width, and height.

        Args:
            pixels (list): A list of pixel values representing the sprite.
            width (int): The width of the sprite.
            height (int): The height of the sprite.
        """
        self.pixels = pixels
        self.width = width
        self.height = height