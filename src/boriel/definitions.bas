#include "../output/config.bas"

' #ifdef ENABLED_128k
'     dim isAmstrad as ubyte = 0
'     if peek(23312) = 1
'         isAmstrad = 1
'     end if
' #endif

const PROTA_SPRITE as ubyte = 5
const BULLET_SPRITE_RIGHT_ID as ubyte = 49
const BULLET_SPRITE_LEFT_ID as ubyte = 50
#ifdef OVERHEAD_VIEW
    const BULLET_SPRITE_UP_ID as ubyte = 51
    const BULLET_SPRITE_DOWN_ID as ubyte = 52
#endif
#ifdef SIDE_VIEW
    const jumpStopValue as ubyte = 255
    dim landed as UBYTE = 1
    dim jumpCurrentKey as ubyte = jumpStopValue
    #ifndef JETPACK_FUEL
        const jumpStepsCount as ubyte = 5
        dim jumpArray(jumpStepsCount - 1) AS byte = {-2, -2, -2, -2, -2}
    #else 
        const jumpStepsCount as ubyte = JETPACK_FUEL
        dim jumpEnergy as ubyte = jumpStepsCount
    #endif
#endif

dim protaLastFrame as ubyte

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
#ifndef JETPACK_FUEL
    dim keyArray(4) as uInteger
#else 
    dim keyArray(3) as uInteger
#endif

dim framec AS ubyte AT 23672

#ifdef NEW_BEEPER_PLAYER
    const BEEP_PERIOD as ubyte = 1
    dim lastFrameBeep as ubyte = 0
#endif

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

dim animatedFrame as ubyte = 0

dim inMenu as ubyte = 1

#ifdef IDLE_ENABLED
    dim protaLoopCounter as ubyte = 0
#endif

#ifdef SHOOTING_ENABLED
    dim noKeyPressedForShoot as UBYTE = 1
#endif
#ifdef ENABLED_128k
    #define DATA_BANK 4
    #define MUSIC_BANK 3
#endif

#ifdef SIDE_VIEW
    dim tileSet(192, 7) as ubyte at TILESET_DATA_ADDRESS
#else
    dim tileSet(194, 7) as ubyte at TILESET_DATA_ADDRESS
#endif
dim attrSet(191) as ubyte at ATTR_DATA_ADDRESS
' dim sprites(47, 31) as ubyte at SPRITES_DATA_ADDRESS
dim screenObjectsInitial(SCREENS_COUNT, 4) as ubyte at SCREEN_OBJECTS_INITIAL_DATA_ADDRESS
dim screensOffsets(SCREENS_COUNT) as uInteger at SCREEN_OFFSETS_DATA_ADDRESS
dim enemiesInScreenOffsets(SCREENS_COUNT) as uInteger at ENEMIES_IN_SCREEN_OFFSETS_DATA_ADDRESS
dim animatedTilesInScreen(SCREENS_COUNT, MAX_ANIMATED_TILES_PER_SCREEN, 2) as ubyte at ANIMATED_TILES_IN_SCREEN_DATA_ADDRESS
dim damageTiles(DAMAGE_TILES_COUNT) as ubyte at DAMAGE_TILES_DATA_ADDRESS
dim enemiesPerScreen(SCREENS_COUNT) as ubyte at ENEMIES_PER_SCREEN_DATA_ADDRESS
dim enemiesPerScreenInitial(SCREENS_COUNT) as ubyte at ENEMIES_PER_SCREEN_INITIAL_DATA_ADDRESS
dim screenObjects(SCREENS_COUNT, 4) as ubyte at SCREEN_OBJECTS_DATA_ADDRESS
dim screensWon(SCREENS_COUNT) as ubyte at SCREENS_WON_DATA_ADDRESS
dim decompressedEnemiesScreen(MAX_ENEMIES_PER_SCREEN, 11) as byte at DECOMPRESSED_ENEMIES_SCREEN_DATA_ADDRESS

#ifdef USE_BREAKABLE_TILE
dim brokenTiles(SCREENS_COUNT) as ubyte at BROKEN_TILES_DATA_ADDRESS
#endif

dim spritesSet(51) as ubyte
dim spriteAddressIndex as uInteger = 0

Dim bullet(7) As Ubyte

const FIRST_RUNNING_PROTA_SPRITE_RIGHT as ubyte = 1
const FIRST_RUNNING_PROTA_SPRITE_LEFT as ubyte = 5

DIM spritesLinColTileAndFrame(MAX_ENEMIES_PER_SCREEN, 4) as ubyte

CONST ENEMY_TILE as UBYTE = 0
CONST ENEMY_LIN_INI as UBYTE = 1
CONST ENEMY_COL_INI as UBYTE = 2
CONST ENEMY_LIN_END as UBYTE = 3
CONST ENEMY_COL_END as UBYTE = 4
CONST ENEMY_HORIZONTAL_DIRECTION as UBYTE = 5
CONST ENEMY_CURRENT_LIN as UBYTE = 6
CONST ENEMY_CURRENT_COL as UBYTE = 7
CONST ENEMY_ALIVE as UBYTE = 8
' CONST ENEMY_SPRITE as UBYTE = 9
CONST ENEMY_VERTICAL_DIRECTION as UBYTE = 10
'CONST ENEMY_COLOR as UBYTE = 11

#ifdef ARCADE_MODE
    dim currentScreenKeyX as ubyte
    dim currentScreenKeyY as ubyte
#endif