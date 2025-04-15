from builder.Sprite import Sprite

class ZXPToSpritesConversor:
    @staticmethod
    def convert(zxp_file, num_sprites_per_row = 16, sprite_size = 16, rows_per_sprite_group = 16):
        with open(zxp_file, 'r') as f:
            lines = f.readlines()

        # Separar las líneas de bits
        bit_lines = [line.strip() for line in lines if line.strip() and all(c in "01" for c in line.strip())]

        # Validar que el número de líneas sea múltiplo de 16
        if len(bit_lines) % sprite_size != 0:
            raise ValueError("El archivo ZXP no contiene un número válido de filas para sprites de 16x16.")

        sprites = []

        for row_start in range(0, len(bit_lines), rows_per_sprite_group):  # Procesar cada grupo de 16 filas
            for col in range(num_sprites_per_row):  # Procesar cada columna de sprites (16 columnas por fila)
                sprite = []
                for row in range(sprite_size):  # Usar las 16 filas completas
                    line = bit_lines[row_start + row]
                    # Extraer los 16 bits correspondientes a la columna actual
                    sprite_row = [int(bit) for bit in line[col * sprite_size:(col + 1) * sprite_size]]
                    sprite.append(sprite_row)
                sprites.append(Sprite(sprite, sprite_size, sprite_size))
        
        return sprites