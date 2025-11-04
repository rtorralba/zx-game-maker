from pathlib import Path
from configuration.folders import FX_FOLDER, SRC_FOLDER
import subprocess

class PlayerFxBuilder:
    @classmethod
    def build(cls):
        TAP_PATH = Path('..', FX_FOLDER, 'fx.tap')
        BORIEL_PATH = Path(SRC_FOLDER, 'boriel')
        
        try:
            result = subprocess.run(
                ["zxbasm", "-t", "-o", str(TAP_PATH), 'player.asm'],
                cwd=str(BORIEL_PATH)
            )
            return result.returncode == 0
        except Exception:
            return False