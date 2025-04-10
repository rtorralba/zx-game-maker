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
        Generates a charset representation for a 16x16 sprite.
        The sprite is divided into 4 arrays of 8 bytes each, reordered as:
        [top-left, bottom-left, top-right, bottom-right].
        """
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