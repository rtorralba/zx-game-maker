from Charset import CharSet

class PreshiftedSpritesWriter:
    @staticmethod
    def write(preshiftedSprites, outputFile):
        if not preshiftedSprites or not isinstance(preshiftedSprites, list):
            raise TypeError("preshiftedSprites must be a non-empty list.")

        with open(outputFile, "w") as f:
            f.write("'REM --SPRITE SECTION--\n\n")
            f.write("asm\n\n")

            # Write SPRITE_BUFFER
            f.write("SPRITE_BUFFER:\n")
            for sprite_index, sprite in enumerate(preshiftedSprites):
                f.write(f"S{sprite_index:02}_ADDRESS:\n")  # Add sprite label

                for i in range(0, len(sprite.pixels), 8):  # Write 8 bytes per line
                    f.write("    DEFB " + ", ".join(f"{byte:03X}h" for byte in sprite.pixels[i:i+8]) + "\n")
                if sprite_index < len(preshiftedSprites) - 1:  # Add a blank line between preshiftedSprites
                    f.write("\n")

            # Write SPRITE_INDEX
            f.write("\nSPRITE_INDEX:\n")
            for i in range(len(preshiftedSprites)):
                f.write(f"    DEFW (SPRITE_BUFFER + {i * 120})\n")  # 120 bytes per sprite

            # Write SPRITE_COUNT
            f.write("\nSPRITE_COUNT:\n")
            f.write(f"    DEFB {len(preshiftedSprites)}\n")  # Total number of preshiftedSprites

            f.write("\nend asm\n")