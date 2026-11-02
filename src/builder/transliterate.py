import unicodedata

TRANSLITERATION_MAP = {
    '\u00bf': '?',       # ¿
    '\u00a1': '!',       # ¡
    '\u00ab': '"',       # «
    '\u00bb': '"',       # »
    '\u201c': '"',       # “
    '\u201d': '"',       # ”
    '\u2018': "'",       # ‘
    '\u2019': "'",       # ’
    '\u2013': '-',       # –
    '\u2014': '-',       # —
    '\u2026': '...',     # …
    '\u00df': 'ss',      # ß
    '\u00e6': 'ae',      # æ
    '\u00c6': 'AE',      # Æ
    '\u0153': 'oe',      # œ
    '\u0152': 'OE',      # Œ
}

def transliterate(text):
    """
    Transliterates unicode text to standard ASCII compatible with ZX Spectrum.
    Removes accents/diacritics (e.g. camión -> camion, Maçã -> Maca) and maps
    special punctuation like inverted question/exclamation marks.
    """
    if text is None:
        return ""
    if not isinstance(text, str):
        text = str(text)
    for src, dst in TRANSLITERATION_MAP.items():
        text = text.replace(src, dst)
    # Decompose unicode into base characters and diacritical marks (NFD)
    nfd = unicodedata.normalize('NFD', text)
    # Filter out non-spacing mark characters (accents, tildes, cedillas...)
    clean = "".join(c for c in nfd if unicodedata.category(c) != 'Mn')
    # Encode to ASCII, discarding any remaining non-ASCII characters
    return clean.encode('ascii', 'ignore').decode('ascii')

