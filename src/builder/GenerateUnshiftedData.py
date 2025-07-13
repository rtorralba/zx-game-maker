from builder.PreshiftedSprite import PreshiftedSprite

class GenerateUnshiftedData:
    @staticmethod
    def generate(set):
        """
        Generates unshifted data for a sprite set.
        - charset: An object with attributes:
            - Sort: Specifies the sorting type (must be 'UpDown').
            - Data: 2D array of byte data for the sprite set.
            - Width: Width of the sprite set in characters.
            - Height: Height of the sprite set in characters.
            - get_char_index(x, y): Function to get the character index in the set.
        """
        if set.Sort != "UpDown":
            return []

        byte_data = set.Data
        unshifted_data = []

        # Step 1: Generate the unshifted sprite
        for x in range(set.Width):
            # Add the unshifted bytes
            for y in range(set.Height):
                unshifted_data.extend(byte_data[set.get_char_index(x, y)])

        return PreshiftedSprite(unshifted_data, set.Width, set.Height)
