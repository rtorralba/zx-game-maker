class HudMessage:
    def __init__(self, line1, line2, ink="green", paper="black"):
        self.Line1 = line1.ljust(8)[:8]
        self.Line2 = line2.ljust(8)[:8]
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