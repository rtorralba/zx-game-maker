class CharSet:
    def __init__(self, data, width, height):
        self.Sort = "UpDown"
        self.Data = data
        self.Width = width
        self.Height = height

    def get_char_index(self, x, y):
        return x * self.Width + y
    
    @staticmethod
    def createFromSprite(sprite, charWidth, charHeight):
        """
        Generates a charset representation for a sprite.
        Supports both 16x16 and 8x8 sprites.
        - For 16x16 sprites, the sprite is divided into 4 blocks of 8 bytes each:
          [top-left, bottom-left, top-right, bottom-right].
        - For 8x8 sprites, the sprite is treated as a single block.
        """
        if charWidth == 2 and charHeight == 2:  # Case for 16x16 sprites
            charset = [None] * 4  # Placeholder for the 4 blocks
            for block_y in range(2):  # Divide en bloques de 8 filas (2 bloques verticales)
                for block_x in range(2):  # Divide en bloques de 8 columnas (2 bloques horizontales)
                    block = []
                    for row in range(block_y * 8, (block_y + 1) * 8):  # Procesar 8 filas
                        byte = int("".join(map(str, sprite[row][block_x * 8:(block_x + 1) * 8])), 2)  # Convertir 8 bits a byte
                        block.append(byte)
                    # Reordenar los bloques según el formato esperado
                    if block_y == 0 and block_x == 0:
                        charset[0] = block  # Top-left
                    elif block_y == 1 and block_x == 0:
                        charset[1] = block  # Bottom-left
                    elif block_y == 0 and block_x == 1:
                        charset[2] = block  # Top-right
                    elif block_y == 1 and block_x == 1:
                        charset[3] = block  # Bottom-right
            return CharSet(charset, charWidth, charHeight)

        elif charWidth == 1 and charHeight == 1:  # Case for 8x8 sprites
            charset = [None]  # Placeholder for the single block
            block = []
            for row in range(8):  # Procesar las 8 filas completas
                byte = int("".join(map(str, sprite[row])), 2)  # Convertir 8 bits a byte
                block.append(byte)
            charset[0] = block  # Single block for 8x8
            return CharSet(charset, charWidth, charHeight)

        else:
            raise ValueError("Unsupported sprite size. Only 16x16 (charWidth=2, charHeight=2) and 8x8 (charWidth=1, charHeight=1) are supported.")
