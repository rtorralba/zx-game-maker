from pathlib import Path
from PIL import Image
from generateShiftedData import generate_shifted_data  # Import the new function

def generate_charset(sprite):
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
    return charset

# Leer el archivo ZXP
inFile = str(Path("/home/raul/dev/spectrum/zxbasic/zx-game-maker/assets/map/sprites.zxp"))
with open(inFile, 'r') as f:
    lines = f.readlines()

# Separar las líneas de bits
bit_lines = [line.strip() for line in lines if line.strip() and all(c in "01" for c in line.strip())]

# Validar que el número de líneas sea múltiplo de 16
if len(bit_lines) % 16 != 0:
    raise ValueError("El archivo ZXP no contiene un número válido de filas para sprites de 16x16.")

# Procesar los sprites
sprites = []
num_sprites_per_row = 16  # Número de sprites por fila
sprite_size = 16  # Tamaño de cada sprite (16x16)
rows_per_sprite_group = 16  # Número de filas por grupo de sprites (16 filas por cada fila de sprites)

for row_start in range(0, len(bit_lines), rows_per_sprite_group):  # Procesar cada grupo de 16 filas
    for col in range(num_sprites_per_row):  # Procesar cada columna de sprites (16 columnas por fila)
        sprite = []
        for row in range(sprite_size):  # Usar las 16 filas completas
            line = bit_lines[row_start + row]
            # Extraer los 16 bits correspondientes a la columna actual
            sprite_row = [int(bit) for bit in line[col * sprite_size:(col + 1) * sprite_size]]
            sprite.append(sprite_row)
        sprites.append(sprite)

def write_shifted_sprites_to_file(sprites, output_file):
    """
    Writes the shifted sprites to the Sprites.zxbas file.
    - Each sprite is processed with generate_shifted_data to create shifted data.
    - The shifted data is written in 15 lines of 8 bytes (120 bytes total).
    """

    with open(output_file, "w") as f:
        f.write("'REM --SPRITE SECTION--\n\n")
        f.write("asm\n\n")

        # Write SPRITE_BUFFER
        f.write("SPRITE_BUFFER:\n")
        for sprite_index, sprite in enumerate(sprites):
            f.write(f"S{sprite_index:02}_ADDRESS:\n")  # Add sprite label
            charset = generate_charset(sprite)  # Generate charset for the sprite

            # Create a mock CharSet object to pass to generate_shifted_data
            class CharSet:
                def __init__(self, data, width, height):
                    self.Sort = "UpDown"
                    self.Data = data
                    self.Width = width
                    self.Height = height

                def get_char_index(self, x, y):
                    return x * self.Width + y

            charset_object = CharSet(charset, 2, 2)  # Create the CharSet object

            shifted_data = generate_shifted_data(charset_object)  # Use the new function

            print(f"Sprite {sprite_index}: {shifted_data}")  # Debug print

            for i in range(0, len(shifted_data), 8):  # Write 8 bytes per line
                f.write("    DEFB " + ", ".join(f"{byte:03X}h" for byte in shifted_data[i:i+8]) + "\n")
            if sprite_index < len(sprites) - 1:  # Add a blank line between sprites
                f.write("\n")

        # Write SPRITE_INDEX
        f.write("\nSPRITE_INDEX:\n")
        for i in range(len(sprites)):
            f.write(f"    DEFW (SPRITE_BUFFER + {i * 120})\n")  # 120 bytes per sprite

        # Write SPRITE_COUNT
        f.write("\nSPRITE_COUNT:\n")
        f.write(f"    DEFB {len(sprites)}\n")  # Total number of sprites

        f.write("\nend asm\n")

# Replace the existing call to write the sprites
output_file = "/home/raul/dev/spectrum/zxbasic/zx-game-maker/src/boriel/lib/Sprites.zxbas"
write_shifted_sprites_to_file(sprites, output_file)