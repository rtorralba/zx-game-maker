#include "../output/config.bas"

#ifdef ENABLED_128k
    Dim screensBank As Ubyte = 3
    Dim musicBank As Ubyte = 4
    Dim fxBank As Ubyte = 6
    If Peek(23312) = 1 Then ' Amstrad
        screensBank = 4
        musicBank = 3
        fxBank = 1
    End If
#endif

' GuSprites
#define PRECOMPUTED_SPRITES
#define STORE_UNSHIFTED_SPRITES
#define SPRITES_FILE "sprites.bas"
' #define SPRITE_XY_IN_PIXELS
#define ENABLE_1x1_SPRITES
' #define ENABLE_1x2_SPRITES
#define ENABLE_2x2_SPRITES
#ifdef SIDE_VIEW
    #define TOTAL_1x1_SPRITES 2
#else
    #define TOTAL_1x1_SPRITES 4
#endif
' #define TOTAL_1x2_SPRITES 0
#define TOTAL_2x2_SPRITES 48
#define ONSCREEN_1x1_SPRITES 1
' #define ONSCREEN_1x2_SPRITES 0
' #define ONSCREEN_2x2_SPRITES 4 Defined dinamically from Tiled
#define ENABLE_TILES
#define MERGE_TILES
' #define MAX_ANIMATED_TILES_PER_SCREEN 48 Defined dinamically from Tiled
#define ALL_NEEDED_PARAMETERS_ALREADY_DEFINED
#define ENABLE_INTERRUPTS

Const BULLET_SPRITE_RIGHT_ID As Ubyte = 49
Const BULLET_SPRITE_LEFT_ID As Ubyte = 50
#ifdef OVERHEAD_VIEW
    Const BULLET_SPRITE_UP_ID As Ubyte = 51
    Const BULLET_SPRITE_DOWN_ID As Ubyte = 52
#endif

#ifdef SWORD_ENABLED
    Const SWORD_SPRITE_RIGHT_ID As Ubyte = 52
    Const SWORD_SPRITE_LEFT_ID As Ubyte = 51
#endif


Dim protaLastFrame As Ubyte

Const LEFT As Ubyte = 0
Const RIGHT As Ubyte = 1
Const UP As Ubyte = 2
Const DOWN As Ubyte = 3
Const FIRE As Ubyte = 4

Dim currentLife As Ubyte = 100
Dim currentKeys As Ubyte = 0
Dim moveScreen As Ubyte
Dim currentScreen As Ubyte = 0
Dim currentBulletSpriteId As Ubyte

Dim protaFrame As Ubyte = 0
Dim enemFrame As Ubyte = 0

Dim kempston As Ubyte
Dim keyOption As String
Dim keyArray(4) As Uinteger

Dim framec As Ubyte AT 23672

#ifdef NEW_BEEPER_PLAYER
    Const BEEP_PERIOD As Ubyte = 1
    Dim lastFrameBeep As Ubyte = 0
#endif

Dim lastFrameProta As Ubyte = 0
Dim lastFrameEnemies As Ubyte = 0
Dim lastFrameTiles As Ubyte = 0

Const INVINCIBLE_FRAMES As Ubyte = 25
Dim invincible As Ubyte = 0
Dim invincibleFrame As Ubyte = 0
Dim invincibleBlink As Ubyte = 0

Dim protaX As Ubyte
Dim protaY As Ubyte
Dim protaDirection As Ubyte
Dim protaTile As Ubyte

#ifdef LIVES_MODE_ENABLED
    dim protaXRespawn as ubyte
    dim protaYRespawn as ubyte
#endif

Dim animatedFrame As Ubyte = 1

Dim inMenu As Ubyte = 1

#ifdef IDLE_ENABLED
    Dim protaLoopCounter As Ubyte = 0
#endif

#ifdef SHOOTING_ENABLED
    Dim noKeyPressedForShoot As Ubyte = 1
#endif

#ifdef SIDE_VIEW
    Dim tileSet(192, 7) As Ubyte at TILESET_DATA_ADDRESS
    #ifdef DISABLE_CONTINUOUS_JUMP
        Dim noKeyPressedForJump As Ubyte = 1
    #endif
#Else
    Dim tileSet(194, 7) As Ubyte at TILESET_DATA_ADDRESS
#endif
Dim attrSet(191) As Ubyte at ATTR_DATA_ADDRESS
Dim screensOffsets(SCREENS_COUNT) As Uinteger at SCREEN_OFFSETS_DATA_ADDRESS
Dim enemiesInScreenOffsets(SCREENS_COUNT) As Uinteger at ENEMIES_IN_SCREEN_OFFSETS_DATA_ADDRESS
Dim animatedTilesInScreen(MAX_ANIMATED_TILES_PER_SCREEN, 2) As Ubyte at ANIMATED_TILES_IN_SCREEN_DATA_ADDRESS
Dim damageTiles(DAMAGE_TILES_COUNT) As Ubyte at DAMAGE_TILES_DATA_ADDRESS
Dim enemiesPerScreen(SCREENS_COUNT) As Ubyte at ENEMIES_PER_SCREEN_DATA_ADDRESS
Dim screenObjects(SCREEN_OBJECTS_COUNT - 1, 3) As Ubyte at SCREEN_OBJECTS_DATA_ADDRESS
Dim screenObjectsCurrentIndex As Ubyte = 0
Dim screensWon(SCREENS_COUNT) As Ubyte at SCREENS_WON_DATA_ADDRESS
Dim decompressedEnemiesScreen(MAX_ENEMIES_PER_SCREEN, 12) As Ubyte at DECOMPRESSED_ENEMIES_SCREEN_DATA_ADDRESS

#ifdef USE_BREAKABLE_TILE_ALL
    Dim brokenTiles(SCREENS_COUNT) As Ubyte at BROKEN_TILES_DATA_ADDRESS
#endif

#ifdef USE_BREAKABLE_TILE_INDIVIDUAL
    Dim brokenTiles(BREAKABLE_TILES_COUNT, 2) As Ubyte at BROKEN_TILES_DATA_ADDRESS
    Dim brokenTilesCurrentIndex As Ubyte = 0
#endif

Dim spritesSet(51) As Ubyte
Dim spriteAddressIndex As Uinteger = 0

#ifdef SHOOTING_ENABLED
    Dim bullet(7) As Ubyte

    Dim bulletPositionX as Ubyte = 0
    Dim bulletPositionY as Ubyte = 0
    Dim bulletDirection as Ubyte = 0
    Dim bulletEndPositionX as Ubyte = 0
    Dim bulletEndPositionY as Ubyte = 0
#endif

Const FIRST_RUNNING_PROTA_SPRITE_RIGHT As Ubyte = 1
Const FIRST_RUNNING_PROTA_SPRITE_LEFT As Ubyte = 5

Const ENEMY_TILE As Ubyte = 0
Const ENEMY_LIN_INI As Ubyte = 1
Const ENEMY_COL_INI As Ubyte = 2
Const ENEMY_LIN_END As Ubyte = 3
Const ENEMY_COL_END As Ubyte = 4
Const ENEMY_HORIZONTAL_DIRECTION As Ubyte = 5
Const ENEMY_CURRENT_LIN As Ubyte = 6
Const ENEMY_CURRENT_COL As Ubyte = 7
Const ENEMY_ALIVE As Ubyte = 8
Const ENEMY_MOVE As Ubyte = 9
Const ENEMY_VERTICAL_DIRECTION As Ubyte = 10
Const ENEMY_SPEED As Ubyte = 11
Const ENEMY_ID As Ubyte = 12

#ifdef ARCADE_MODE
    Dim currentScreenKeyX As Ubyte
    Dim currentScreenKeyY As Ubyte
    #ifdef ARCADE_MODE_RESET_ON_KILL
        Dim arcadeModeResetObjects As Ubyte = 0
    #endif
    #ifdef ARCADE_MODE_SPRITE_ID
        Dim showKeySprite As Ubyte = 0
    #endif
#endif

Dim kempstonInterfaceAvailable As Ubyte = 0

Dim resetBorder As Ubyte = 0

Dim skipMove0 As Ubyte = 0
Dim skipMove1 As Ubyte = 0
Dim skipMove2 As Ubyte = 0

Dim mainLoopCounter As Ubyte = 0

#ifdef TIMER_ENABLED
    Dim lastFrameTimer As Ubyte = 0
    Dim timerSeconds as ubyte = initialTimerSeconds
    #ifdef HURRY_UP_SECONDS
        Dim vortexTracker2x As Ubyte = 0
    #endif
#endif

Const ENEMY_DOOR_TILE As Ubyte = 63
Const KEY_DOOR_TILE As Ubyte = 62
Const ITEMS_DOOR_TILE As Ubyte = 61
Const BREAKABLE_BY_BULLET_TILE As Ubyte = 60

#ifdef USE_BREAKABLE_TILE_BY_TOUCH
    Const BREAKABLE_BY_TOUCH_TILE As Ubyte = 59
    Dim tileToBreakByTouchX As Ubyte = 0
    Dim tileToBreakByTouchY As Ubyte = 0
#endif
Dim lastFrameOnBreakableTiles As Ubyte = 0

#Define PROTA_IDLE_SPRITE_ID 13
#define arrayBasePtr(x) (PEEK(Uinteger, @x + 2))

#ifdef AMMO_ENABLED
    Const AMMO_TILE As Ubyte = 187
    Const LAST_PRINTABLE_TILE As Ubyte = 186
#else
    Const AMMO_TILE As Ubyte = 188
    Const LAST_PRINTABLE_TILE As Ubyte = 187
#endif

#ifdef PASSWORD_ENABLED
    Dim passwordOk As Ubyte = 0
#endif

#ifdef WALL_JUMP_ENABLED
    Dim wallJumpTimer As Ubyte = 0
#endif

#ifdef DASH_ENABLED
    Dim hasDashed As Ubyte = 0
    Dim dashTimer As Ubyte = 0
    Const DASH_DURATION As Ubyte = 8
    Dim dashGhostX As Ubyte = 0
    Dim dashGhostY As Ubyte = 0
    Dim dashGhostTile As Ubyte = 0
    Dim dashGhostActive As Ubyte = 0
#endif

#ifdef SWORD_ENABLED
    Dim swordTimer As Ubyte = 0
    Dim swordDirection As Ubyte = 0
    Const SWORD_DURATION As Ubyte = 10
#endif

