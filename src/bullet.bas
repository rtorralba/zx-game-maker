const BURST_SPRITE_ID as ubyte = 15
const BULLET_SPEED as ubyte = 2

dim bulletPositionX as ubyte = 0
dim bulletPositionY as ubyte = 0
dim bulletDirection as ubyte = 0
dim bulletEndPositionX as ubyte = 0
dim bulletEndPositionY as ubyte = 0

dim bullet(7) as ubyte

bullet(0) = tileSet(1, 0)
bullet(1) = tileSet(1, 1)
bullet(2) = tileSet(1, 2)
bullet(3) = tileSet(1, 3)
bullet(4) = tileSet(1, 4)
bullet(5) = tileSet(1, 5)
bullet(6) = tileSet(1, 6)
bullet(7) = tileSet(1, 7)

spritesSet(BULLET_SPRITE_RIGHT_ID) = Create1x1Sprite(@bullet)

bullet(0) = tileSet(192, 0)
bullet(1) = tileSet(192, 1)
bullet(2) = tileSet(192, 2)
bullet(3) = tileSet(192, 3)
bullet(4) = tileSet(192, 4)
bullet(5) = tileSet(192, 5)
bullet(6) = tileSet(192, 6)
bullet(7) = tileSet(192, 7)

spritesSet(BULLET_SPRITE_LEFT_ID) = Create1x1Sprite(@bullet)

#ifdef OVERHEAD_VIEW
    bullet(0) = tileSet(193, 0)
    bullet(1) = tileSet(193, 1)
    bullet(2) = tileSet(193, 2)
    bullet(3) = tileSet(193, 3)
    bullet(4) = tileSet(193, 4)
    bullet(5) = tileSet(193, 5)
    bullet(6) = tileSet(193, 6)
    bullet(7) = tileSet(193, 7)

    spritesSet(BULLET_SPRITE_UP_ID) = Create1x1Sprite(@bullet)

    bullet(0) = tileSet(194, 0)
    bullet(1) = tileSet(194, 1)
    bullet(2) = tileSet(194, 2)
    bullet(3) = tileSet(194, 3)
    bullet(4) = tileSet(194, 4)
    bullet(5) = tileSet(194, 5)
    bullet(6) = tileSet(194, 6)
    bullet(7) = tileSet(194, 7)

    spritesSet(BULLET_SPRITE_DOWN_ID) = Create1x1Sprite(@bullet)
#endif

' sub createBullet(directionRight as ubyte)
'     if directionRight
'         spritesSet(BULLET_SPRITE_RIGHT_ID) = Create1x1Sprite(@bulletRight)
'     else
'         spritesSet(BULLET_SPRITE_RIGHT_ID) = Create1x1Sprite(@bulletLeft)
'     end if
' end sub

dim maxXScreenRight as ubyte = 60
dim maxXScreenLeft as ubyte = 2
#ifdef OVERHEAD_VIEW
    dim maxYScreenBottom as ubyte = 40
    dim maxYScreenTop as ubyte = 2
#endif

sub moveBullet()
    dim limit as ubyte = 0

    if bulletPositionX = 0 then
        return
    end if

    #ifdef OVERHEAD_VIEW
        if bulletPositionY = 0 then
            return
        end if
    #endif

    if bulletDirection = 1 then
        if bulletPositionX >= bulletEndPositionX then
            resetBullet()
            return
        end if
        bulletPositionX = bulletPositionX + BULLET_SPEED
    elseif bulletDirection = 0 then
        if bulletPositionX <= bulletEndPositionX then
            resetBullet()
            return
        end if
        bulletPositionX = bulletPositionX - BULLET_SPEED
    #ifdef OVERHEAD_VIEW
    elseif bulletDirection = 2 then
        if bulletPositionY >= bulletEndPositionY then
            resetBullet()
            return
        end if
        bulletPositionY = bulletPositionY + BULLET_SPEED
    elseif bulletDirection = 8
        if bulletPositionY <= bulletEndPositionY then
            resetBullet()
            return
        end if
        bulletPositionY = bulletPositionY - BULLET_SPEED
    #endif
    endif

    checkBulletCollision()
end sub

sub checkBulletCollision()
    if bulletPositionY = maxYScreenTop or bulletPositionY = maxYScreenBottom then
        resetBullet()
        return
    end if

    dim xToCheck as ubyte

    if bulletDirection = 1 then
        xToCheck = bulletPositionX + 1
    else
        xToCheck = bulletPositionX
    end if

    dim tile as ubyte = isSolidTileByXY(xToCheck, bulletPositionY)
    if tile then
        resetBullet()
        #ifdef USE_BREAKABLE_TILE
            if tile = 62 then
                brokenTiles(currentScreen) = 1
                BeepFX_Play(0)
                removeTilesFromScreen(62)
            end if
        #endif
        return
    else
        tile = isSolidTileByXY(xToCheck, bulletPositionY + 1)
        if tile then
            resetBullet()
            #ifdef USE_BREAKABLE_TILE
                if tile = 62 then
                    brokenTiles(currentScreen) = 1
                    BeepFX_Play(0)
                    removeTilesFromScreen(62)
                end if
            #endif
            return
        end if
    end if

    #ifdef ENEMIES_NOT_RESPAWN_ENABLED
        if screensWon(currentScreen) then return
    #endif
    
    for enemyId=0 TO MAX_ENEMIES_PER_SCREEN - 1
        if decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 then continue for ' not enemy
        if decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) = 0 then continue for

        dim bulletX0, bulletX1, bulletY0, bulletY1, enemyX0, enemyX1, enemyY0, enemyY1 as ubyte

        bulletX0 = bulletPositionX
        bulletX1 = bulletPositionX + 1
        bulletY0 = bulletPositionY
        bulletY1 = bulletPositionY + 1
        enemyX0 = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
        enemyX1 = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) + 2
        enemyY0 = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
        enemyY1 = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) + 2

        if bulletX1 < enemyX0 then continue for
        if bulletX0 > enemyX1 then continue for
        if bulletY1 < enemyY0 then continue for
        if bulletY0 > enemyY1 then continue for

        damageEnemy(enemyId)
        resetBullet()
    next enemyId
end sub

sub resetBullet()
    bulletPositionX = 0
    bulletPositionY = 0
    bulletDirection = 0
end sub

sub damageEnemy(enemyToKill as Ubyte)
    if decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = 99 then return 'invincible enemies

    decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) - 1
    #ifdef HISCORE_ENABLED
        score = score + 5
        printLife()
    #endif

    if decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = 0 then
        dim attr, tile, x, y, col, lin, tmpX, tmpY as ubyte

        x = decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_COL)
        y = decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_LIN)
        saveSprite(enemyToKill, 0, 0, 0, 0)
        Draw2x2Sprite(spritesSet(BURST_SPRITE_ID), x, y)
        
        BeepFX_Play(0)

        #ifdef SHOULD_KILL_ENEMIES_ENABLED
            if not screensWon(currentScreen) then
                if allEnemiesKilled() then
                    screensWon(currentScreen) = 1
                    removeTilesFromScreen(63)
                end if
            end if
            return ' to prevent check twice if ENEMIES_NOT_RESPAWN_ENABLED is defined'
        #endif

        #ifdef ENEMIES_NOT_RESPAWN_ENABLED
            if not screensWon(currentScreen) then
                if allEnemiesKilled() then
                    screensWon(currentScreen) = 1
                    removeTilesFromScreen(63)
                end if
            end if
        #endif
    else
        BeepFX_Play(1)
    end if
end sub