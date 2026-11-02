from builder.transliterate import transliterate

class HudMessage:
    def __init__(self, line1, line2, ink="green", paper="black"):
        clean1 = transliterate(line1)
        clean2 = transliterate(line2)
        self.Line1 = clean1.ljust(8)[:8] if clean1 != "" else ""
        self.Line2 = clean2.ljust(8)[:8] if clean2 != "" else ""
        self.Ink = self.__colorToSpectrum(ink)
        self.Paper = self.__colorToSpectrum(paper)

    def __colorToSpectrum(self, color):
        # Convert color name to Spectrum color code
        colors = {
            "black": 0,
            "blue": 1,
            "red": 2,
            "magenta": 3,
            "green": 4,
            "cyan": 5,
            "yellow": 6,
            "white": 7
        }
        return colors.get(color.lower(), 0)