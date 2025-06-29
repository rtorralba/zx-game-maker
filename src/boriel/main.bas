#include <zx0.bas>
#include <retrace.bas>
#include <keys.bas>
#include "definitions.bas"
#include "dataLoader.bas"
#ifdef ENABLED_128k
    #include "128/im2.bas"
    #include "128/vortexTracker.bas"
    #include "128/functions.bas"
#endif

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

initGraphics()

#ifdef WAIT_PRESS_KEY_AFTER_LOAD
    If firstLoad Then
        firstLoad = 0
        pauseUntilPressKey()
    End If
#endif

showMenu()