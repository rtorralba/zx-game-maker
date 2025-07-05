import os
import sys
from pathlib import Path

with Path("output", "map.txt").open("r") as file:
    lines = file.readlines()
    last_line = lines[-1]

memoryAddress = last_line.split(":")[0]

if int(memoryAddress, 16) > 0xC000:
    print("")
    print("========================================================")
    print("ERROR: Memory address " + memoryAddress + " is greater than $C000")
    print("Try to disable some features in the map configuration")
    print("========================================================")
    print("")
    sys.exit(1)
