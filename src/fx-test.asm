SoundEffectsData:
	defw SoundEffect0Data

SoundEffect0Data:
	defb 1 ;tone
	defw 1,500,440,0,128
	defb 1 ;tone
	defw 1,500,440,0,128
	defb 1 ;pause
	defw 1,500,0,0,0
	defb 1 ;pause
	defw 1,500,0,0,0
	defb 2 ;noise
	defw 1,500,100
	defb 2 ;noise
	defw 1,500,100
	defb 0
