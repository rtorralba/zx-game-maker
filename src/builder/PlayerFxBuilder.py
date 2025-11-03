
import os
from pathlib import Path
import sys
sys.path.append(str(Path(__file__).parent.parent))
from configuration.folders import OUTPUT_FOLDER, SRC_FOLDER, FX_FOLDER

class PlayerFxBuilder:
    PLAYER_PATH = SRC_FOLDER / 'boriel' / 'player.asm'
    FX_PATH = FX_FOLDER / 'fx.asm'
    OUTPUT_PATH = OUTPUT_FOLDER / 'playerWithFx.asm'
    TAP_PATH = FX_FOLDER / 'fx.tap'

    def build(self):
        try:
            with open(self.PLAYER_PATH, 'r') as f_player, open(self.FX_PATH, 'r') as f_fx, open(self.OUTPUT_PATH, 'w') as f_out:
                f_out.write(f_player.read())
                f_out.write('\n')
                f_out.write(f_fx.read())
            result = os.system(f"zxbasm -t -o {self.TAP_PATH} {self.OUTPUT_PATH}")
            return result == 0
        except Exception:
            return False