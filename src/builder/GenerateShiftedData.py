from builder.PreshiftedSprite import PreshiftedSprite

class GenerateShiftedData:
    @staticmethod
    def shiftRight(bytes_array):
        """
        Shifts an array of bytes to the right by 1 bit, propagating carry bits between bytes.
        - bytes_array: List of integers (bytes) to shift.
        Returns:
            bool: True if there was a carry from the rightmost bit, False otherwise.
        """
        right_most_carry_flag = False
        right_end = len(bytes_array) - 1

        # Iterate through the elements of the array right to left.
        for index in range(right_end, -1, -1):
            # If the rightmost bit of the current byte is 1 then we have a carry.
            carry_flag = (bytes_array[index] & 0x01) > 0

            if index < right_end:
                if carry_flag:
                    # Apply the carry to the leftmost bit of the current byte's neighbor to the right.
                    bytes_array[index + 1] |= 0x80

            else:
                right_most_carry_flag = carry_flag

            # Shift the current byte to the right by 1 bit.
            bytes_array[index] >>= 1

        return right_most_carry_flag

    @staticmethod
    def generate(set):
        """
        Generates shifted data for a sprite set.
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
        shifted_data = []

        # Step 1: Generate the vertically shifted sprite
        for x in range(set.Width):
            # Add four empty bytes to the column
            shifted_data.extend([0, 0, 0, 0])

            # Add the unshifted bytes
            for y in range(set.Height):
                shifted_data.extend(byte_data[set.get_char_index(x, y)])

            # Add the final four empty bytes
            shifted_data.extend([0, 0, 0, 0])

        # Step 2: Create the real shifted sprites
        shifted_rows = []
        row_width = set.Width + 1  # Add one empty column for shifting
        empty_row = [0] * row_width

        # Add four empty rows
        shifted_rows.extend([empty_row.copy() for _ in range(4)])

        # Shift the data
        for y in range(set.Height):
            for char_row in range(8):  # Each character has 8 rows
                new_row = [0] * row_width
                for x in range(set.Width):
                    new_row[x] = byte_data[set.get_char_index(x, y)][char_row]

                # Perform 4 right bit shifts using the shift_right function
                for _ in range(4):
                    GenerateShiftedData.shiftRight(new_row)

                shifted_rows.append(new_row)

        # Add four empty rows at the end
        shifted_rows.extend([empty_row.copy() for _ in range(4)])

        # Reorder rows into columns
        for x in range(row_width):
            for y in range(len(shifted_rows)):
                shifted_data.append(shifted_rows[y][x])

        return PreshiftedSprite(shifted_data, set.Width, set.Height)
