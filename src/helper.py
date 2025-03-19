import os
import sys

# create function to get os separator
def getOsSeparator():
    if os.name == "nt":
        return "\\"
    else:
        return "/"

def getZx0():
    if os.name == "nt":
        return "zx0.exe"
    else:
        return "zx0"