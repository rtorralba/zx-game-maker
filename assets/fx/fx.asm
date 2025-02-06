SoundEffectsData:
	defw SoundEffect0Data
	defw SoundEffect1Data
	defw SoundEffect2Data
	defw SoundEffect3Data
	defw SoundEffect4Data
	defw SoundEffect5Data
	defw SoundEffect6Data

SoundEffect0Data:
	defb 2 ;noise
	defw 5,1000,5124
	defb 1 ;tone
	defw 50,100,200,65534,128
	defb 0
SoundEffect1Data:
	defb 2 ;noise
	defw 1,1000,10
	defb 1 ;tone
	defw 20,100,400,65526,128
	defb 2 ;noise
	defw 1,2000,1
	defb 0
SoundEffect2Data:
	defb 2 ;noise
	defw 1,1000,10
	defb 2 ;noise
	defw 1,1000,1
	defb 0
SoundEffect3Data:
	defb 1 ;tone
	defw 4,1000,500,100,384
	defb 1 ;tone
	defw 4,1000,500,100,64
	defb 1 ;tone
	defw 4,1000,500,100,64
	defb 0
SoundEffect4Data:
	defb 1 ;tone
	defw 4,1000,500,100,128
	defb 1 ;tone
	defw 4,1000,500,100,64
	defb 1 ;tone
	defw 4,1000,500,100,16
	defb 0
SoundEffect5Data:
	defb 1 ;tone
	defw 1,2000,400,0,128
	defb 1 ;tone
	defw 1,2000,400,0,16
	defb 1 ;tone
	defw 1,2000,600,0,128
	defb 1 ;tone
	defw 1,2000,600,0,16
	defb 1 ;tone
	defw 1,2000,800,0,128
	defb 1 ;tone
	defw 1,2000,800,0,16
	defb 0
SoundEffect6Data:
	defb 1 ;tone
	defw 1,2000,400,0,128
	defb 1 ;tone
	defw 1,2000,400,0,16
	defb 1 ;tone
	defw 1,2000,600,0,128
	defb 1 ;tone
	defw 1,2000,600,0,16
	defb 1 ;tone
	defw 1,2000,800,0,128
	defb 1 ;tone
	defw 1,2000,800,0,16
	defb 0
