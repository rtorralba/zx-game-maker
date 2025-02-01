#include "../output/config.bas"

const PROTA_SPRITE as ubyte = 6
const BULLET_SPRITE_RIGHT_ID as ubyte = 48
const BULLET_SPRITE_LEFT_ID as ubyte = 49
#ifdef OVERHEAD_VIEW
    const BULLET_SPRITE_UP_ID as ubyte = 50
    const BULLET_SPRITE_DOWN_ID as ubyte = 51
#endif
#ifdef SIDE_VIEW
    const jumpStopValue as ubyte = 255
    const jumpStepsCount as ubyte = 5
    dim landed as UBYTE = 1
    dim jumpCurrentKey as ubyte = jumpStopValue
    dim jumpArray(jumpStepsCount - 1) AS byte = {-2, -2, -2, -2, -2}
#endif
const LEFT as uByte = 0
const RIGHT as uByte = 1
const UP as uByte = 2
const DOWN as uByte = 3
const FIRE as uByte = 4

dim currentLife as UBYTE = 100
dim currentKeys as UBYTE = 0
dim moveScreen as ubyte
dim currentScreen as UBYTE = 0
dim currentBulletSpriteId as ubyte

dim protaFrame as ubyte = 0 
dim enemFrame as ubyte = 0 

dim kempston as uByte
dim keyOption as String
dim keyArray(4) as uInteger

dim framec AS ubyte AT 23672

dim lastFrameProta as ubyte = 0
dim lastFrameEnemies as ubyte = 0
dim lastFrameTiles as ubyte = 0

const INVINCIBLE_FRAMES as ubyte = 25
dim invincible as ubyte = 0
dim invincibleFrame as ubyte = 0
dim invincibleBlink as ubyte = 0

dim protaX as ubyte
dim protaY as ubyte
dim protaDirection as ubyte

dim soundToPlay as ubyte = 1

#ifdef SHOOTING_ENABLED
    dim noKeyPressedForShoot as UBYTE = 1
#endif
#ifdef ENABLED_128k
    PaginarMemoria(3)
    load "" CODE $c000 ' Load fx
    PaginarMemoria(0)
#else
    load "" CODE ' Load fx
#endif

load "" CODE ' Load files

#ifdef ENABLED_128k
    #include "128/im2.bas"
    #include "128/vortexTracker.bas"
    #include "128/functions.bas"
    PaginarMemoria(4)
    load "" CODE ' Load vtplayer
    load "" CODE ' Load music
    PaginarMemoria(0)
    PaginarMemoria(3)
    load "" CODE TITLE_SCREEN_ADDRESS ' Load title screen
    load "" CODE ENDING_SCREEN_ADDRESS ' Load ending screen
    load "" CODE HUD_SCREEN_ADDRESS ' Load hud screen
    #ifdef INTRO_SCREEN_ENABLED
        load "" CODE INTRO_SCREEN_ADDRESS ' Load intro screen
    #endif
    #ifdef GAMEOVER_SCREEN_ENABLED
        load "" CODE GAMEOVER_SCREEN_ADDRESS ' Load game over screen
    #endif
    PaginarMemoria(0)
#endif

#include "GuSprites.zxbas"

#ifdef SIDE_VIEW
    dim tileSet(192, 7) as ubyte at TILESET_DATA_ADDRESS
#else
    dim tileSet(194, 7) as ubyte at TILESET_DATA_ADDRESS
#endif
dim attrSet(191) as ubyte at ATTR_DATA_ADDRESS
dim sprites(47, 31) as ubyte at SPRITES_DATA_ADDRESS
dim screenObjectsInitial(SCREENS_COUNT, 4) as ubyte at SCREEN_OBJECTS_INITIAL_DATA_ADDRESS
dim screensOffsets(SCREENS_COUNT) as uInteger at SCREEN_OFFSETS_DATA_ADDRESS
dim enemiesInScreenOffsets(SCREENS_COUNT) as uInteger at ENEMIES_IN_SCREEN_OFFSETS_DATA_ADDRESS
dim animatedTilesInScreen(SCREENS_COUNT, MAX_ANIMATED_TILES_PER_SCREEN, 3) as ubyte at ANIMATED_TILES_IN_SCREEN_DATA_ADDRESS
dim damageTiles(DAMAGE_TILES_COUNT) as ubyte at DAMAGE_TILES_DATA_ADDRESS
dim enemiesPerScreen(SCREENS_COUNT) as ubyte at ENEMIES_PER_SCREEN_DATA_ADDRESS
dim enemiesPerScreenInitial(SCREENS_COUNT) as ubyte at ENEMIES_PER_SCREEN_INITIAL_DATA_ADDRESS
dim screenObjects(SCREENS_COUNT, 4) as ubyte at SCREEN_OBJECTS_DATA_ADDRESS
dim screensWon(SCREENS_COUNT) as ubyte at SCREENS_WON_DATA_ADDRESS
dim decompressedEnemiesScreen(MAX_ENEMIES_PER_SCREEN, 11) as byte at DECOMPRESSED_ENEMIES_SCREEN_DATA_ADDRESS

#ifdef USE_BREAKABLE_TILE
dim brokenTiles(SCREENS_COUNT) as ubyte at BROKEN_TILES_DATA_ADDRESS
#endif

InitGFXLib()
SetTileset(@tileSet)

dim spritesSet(51) as ubyte
dim spriteAddressIndex as uInteger = 0
for i = 0 to 47
    spritesSet(i) = Create2x2Sprite(@sprites + (32 * spriteAddressIndex))
    ' Draw2x2Sprite(spritesSet(i), 20, 20)
    spriteAddressIndex = spriteAddressIndex + 1
next i

#include "beepFx.bas"

#include <zx0.bas>
#include <retrace.bas>
#include <keys.bas>
#include "functions.bas"
#include "spritesTileAndPosition.bas"
#include "enemies.bas"
#include "bullet.bas"
#include "draw.bas"
#include "protaMovement.bas"

menu:
    #ifdef WAIT_PRESS_KEY_AFTER_LOAD
        if firstLoad
            firstLoad = 0
            DO
            LOOP UNTIL GetKeyScanCode()
        end if
    #endif
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            VortexTracker_Stop()
        #endif
        PaginarMemoria(3)
            dzx0Standard(TITLE_SCREEN_ADDRESS, $4000)
        PaginarMemoria(0)
    #else
        dzx0Standard(TITLE_SCREEN_ADDRESS, $4000)
    #endif

    #ifdef HISCORE_ENABLED
        if score > hiScore
            hiScore = score
        end if
        PRINT AT 0, 22; "HI:"
        PRINT AT 0, 26; hiScore
    #endif

    do
        let keyOption = Inkey$
    loop until keyOption = "1" OR keyOption = "2" OR keyOption = "3" 

    if keyOption = "1"
        let keyArray(LEFT) = KEYO
        let keyArray(RIGHT) = KEYP
        let keyArray(UP) = KEYQ
        let keyArray(DOWN) = KEYA
        let keyArray(FIRE) = KEYSPACE
    elseif keyOption = "2"
        kempston = 1
    elseif keyOption = "3"
        let keyArray(LEFT)=KEY6
        let keyArray(RIGHT)=KEY7
        let keyArray(UP)=KEY9
        let keyArray(DOWN)=KEY8
        let keyArray(FIRE)=KEY0
    end if

#ifdef PASSWORD_ENABLED
function readKey() as ubyte
    let k = GetKey
    let keyOption = chr(k)
    if keyOption = " " then go to menu
    return k
end function

passwordScreen:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    PRINT AT 10, 10; "INSERT PASSWORD"
    PRINT AT 18, 0; "PRESS SPACE TO RETURN TO MENU"
    for i=0 to 7
        PRINT AT 12, 10 + i; "*"
    next i

    let keyOption = ""
    dim pass(7) as ubyte
    dim passwordIndex as ubyte = 0

    for i=0 to 7
        WHILE GetKeyScanCode() <> 0
        WEND
        pass(i) = readKey()
        PRINT AT 12, 10 + i; chr(pass(i))
    next i

    for i=0 to 7
        if chr(pass(i)) <> password(i)
            go to passwordScreen
        end if
    next i

    go to playGame
#endif

#ifdef ENABLED_128k
    #ifdef INTRO_SCREEN_ENABLED
        PaginarMemoria(3)
            dzx0Standard(INTRO_SCREEN_ADDRESS, $4000)
        PaginarMemoria(0)
        DO
        LOOP UNTIL MultiKeys(KEYENTER)
    #endif
#endif

playGame:
    INK INK_VALUE: PAPER PAPER_VALUE: BORDER BORDER_VALUE
    currentScreen = INITIAL_SCREEN

    #ifdef INIT_TEXTS
        for i=0 to 2
            showInitTexts(initTexts(i))
        next i
    #endif

    #ifdef ENABLED_128k
        PaginarMemoria(3)
        dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
        PaginarMemoria(0)
        #ifdef MUSIC_ENABLED
            VortexTracker_Inicializar(1)
        #endif
    #else
        dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
    #endif
    
    resetValues()

    let lastFrameProta = framec
    let lastFrameEnemies = framec
    let lastFrameTiles = framec

    #ifdef HISCORE_ENABLED
        PRINT AT 23, 20; "00000"
    #endif
    do
        waitretrace

        if framec - lastFrameProta >= ANIMATE_PERIOD_MAIN
            protaFrame = getNextFrameRunning()
            let lastFrameProta = framec
        end if

        if framec - lastFrameEnemies >= ANIMATE_PERIOD_ENEMY
            animateEnemies()
            let lastFrameEnemies = framec
        end if

        if framec - lastFrameTiles >= ANIMATE_PERIOD_TILE
            animateAnimatedTiles()
            let lastFrameTiles = framec
        end if

        protaMovement()
        checkDamageByTile()
        moveEnemies()
        moveBullet()
        drawSprites()

        if moveScreen <> 0
            moveToScreen(moveScreen)
            moveScreen = 0
        end if

        if currentLife = 0 then go to gameOver

        if invincible = 1
            if framec - invincibleFrame >= INVINCIBLE_FRAMES
                invincible = 0
                invincibleFrame = 0
            end if
        end if
    loop

ending:
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            VortexTracker_Stop()
        #endif
        PaginarMemoria(3)
            dzx0Standard(ENDING_SCREEN_ADDRESS, $4000)
        PaginarMemoria(0)
    #else
        dzx0Standard(ENDING_SCREEN_ADDRESS, $4000)
    #endif
    DO
    LOOP UNTIL MultiKeys(KEYENTER)
    go to menu

gameOver:
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            VortexTracker_Stop()
        #endif
    #endif

    #ifdef ENABLED_128k
        #ifdef GAMEOVER_SCREEN_ENABLED
            PaginarMemoria(3)
                dzx0Standard(GAMEOVER_SCREEN_ADDRESS, $4000)
            PaginarMemoria(0)
        #else
            PRINT AT 7, 12; "GAME OVER"
        #endif
    #else
        print at 7, 12; "GAME OVER"
    #endif
    
    DO
    LOOP UNTIL MultiKeys(KEYENTER)
    go to menu

sub resetValues()
    swapScreen()

    bulletPositionX = 0
    #ifdef SIDE_VIEW
        jumpCurrentKey = jumpStopValue
    #endif

    invincible = 0
    invincibleFrame = 0
    invincibleBlink = 0

    currentLife = INITIAL_LIFE
    currentKeys = 2 mod 2
    currentKeys = 0
    if ITEMS_COUNTDOWN
        currentItems = ITEMS_TO_FIND
    else
        currentItems = 0
    end if
    ' removeScreenObjectFromBuffer()
    saveSprite(PROTA_SPRITE, INITIAL_MAIN_CHARACTER_Y, INITIAL_MAIN_CHARACTER_X, 0, 1)
    screenObjects = screenObjectsInitial
    enemiesPerScreen = enemiesPerScreenInitial
    for i = 0 to SCREENS_COUNT
        screensWon(i) = 0
    next i
    #ifdef USE_BREAKABLE_TILE
        for i = 0 to SCREENS_COUNT
            brokenTiles(i) = 0
        next i
    #endif
    #ifdef HISCORE_ENABLED
        score = 0
    #endif
    redrawScreen()
    ' drawSprites()
end sub

sub animateEnemies()
    enemFrame = not enemFrame
end sub

sub swapScreen()
    dzx0Standard(MAPS_DATA_ADDRESS + screensOffsets(currentScreen), @decompressedMap)
    dzx0Standard(ENEMIES_DATA_ADDRESS + enemiesInScreenOffsets(currentScreen), @decompressedEnemiesScreen)
    bulletPositionX = 0
end sub

sub animateAnimatedTiles()
    for i=0 to MAX_ANIMATED_TILES_PER_SCREEN:
        if animatedTilesInScreen(currentScreen, i, 0) <> 0
            dim tile as ubyte = animatedTilesInScreen(currentScreen, i, 0) + animatedTilesInScreen(currentScreen, i, 3) + 1
            SetTileChecked(tile, attrSet(tile), animatedTilesInScreen(currentScreen, i, 1), animatedTilesInScreen(currentScreen, i, 2))
            let animatedTilesInScreen(currentScreen, i, 3) = not animatedTilesInScreen(currentScreen, i, 3)
        end if
    next i
end sub

sub debugA(value as UBYTE)
    PRINT AT 18, 10; "----"
    PRINT AT 18, 10; value
end sub

sub debugB(value as UBYTE)
    PRINT AT 18, 15; "  "
    PRINT AT 18, 15; value
end sub

' sub debugC(value as UBYTE)
'     PRINT AT 18, 20; "  "
'     PRINT AT 18, 20; value
' end sub

' sub debugD(value as UBYTE)
'     PRINT AT 18, 25; "  "
'     PRINT AT 18, 25; value
' end sub