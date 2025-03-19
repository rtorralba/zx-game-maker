#!/usr/bin/env python3

import json
import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from helper import getOsSeparator, getZx0, getPythonExecutable
from filesModule import *
from configGeneratorModule import *

generateScreensFiles()

generateTilesAndSpritesFiles()

concatenateBinariesIntoFileAndGenerateTap()

generateMemoryConfigAndCharts()
