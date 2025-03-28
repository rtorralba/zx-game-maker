import sys
from pathlib import Path

# Agregar el directorio 'src' a la ruta de búsqueda de módulos de Python
sys.path.append(str(Path(__file__).resolve().parent / 'src'))

from builder.SpritesGenerator import SpritesGenerator
from builder.SpritesPreviewGenerator import SpritesPreviewGenerator

if __name__ == "__main__":
    SpritesGenerator().execute()
    # Menú principal
    print("Choose a category to generate a sprite preview:")
    print("1. Character")
    print("2. Platform")
    print("3. Enemy")

    category = int(input("Enter the number of the category: "))

    if category == 1:
        # Menú de personajes
        print("Choose a character sprite preview to generate:")
        print("1. Main character")
        print("2. Idle animation")

        option = int(input("Enter the number of the sprite preview to generate: "))

        if option == 1:
            SpritesPreviewGenerator.generateMainPreview()
        elif option == 2:
            SpritesPreviewGenerator.generateIdlePreview()
        else:
            print("Invalid option")

    elif category == 2:
        # Menú de plataformas
        print("Choose a platform sprite preview to generate:")
        print("1. First platform")
        print("2. Second platform")

        option = int(input("Enter the number of the sprite preview to generate: "))

        if option == 1:
            SpritesPreviewGenerator.generateFirstPreview()
        elif option == 2:
            SpritesPreviewGenerator.generateSecondPreview()
        else:
            print("Invalid option")

    elif category == 3:
        # Menú de enemigos
        print("Choose an enemy sprite preview to generate:")
        for i in range(1, 9):
            print(f"{i}. Enemy {i}")

        option = int(input("Enter the number of the enemy sprite preview to generate: "))

        if option >= 1 and option <= 8:
            SpritesPreviewGenerator.generateEnemy(option)
        else:
            print("Invalid option")

    else:
        print("Invalid category")
