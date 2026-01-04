#include <zx0.bas>
#include <retrace.bas>
#include <keys.bas>
#include "definitions.bas"
#include "dataLoader.bas"
#include "im2.bas"

#ifdef ENABLED_128k
    #include "128/vortexTracker.bas"
    #include <memorybank.bas>
    
    #ifdef MUSIC_ENABLED
        VortexTracker_Init()
    #endif
#endif

#include "im2Functions.bas"
IM2_Setup()

loadDataFromTape()

#include "lib/GuSprites.zxbas"
#include "graphicsInitializer.bas"
#include "beepFx.bas"
#include "functions.bas"
#include "enemies.bas"
#include "bullet.bas"
#include "draw.bas"
#include "protaMovement.bas"
#include "screensFlow.bas"

Print getTextByTextId(0)
stop

initGraphics()

#ifdef WAIT_PRESS_KEY_AFTER_LOAD
    If firstLoad Then
        firstLoad = 0
        pauseUntilPressKey()
    End If
#endif

waitretrace
Dim p As Ubyte = In 31

If (p bAND %11111) < 31 Then kempstonInterfaceAvailable = 1

showMenu()