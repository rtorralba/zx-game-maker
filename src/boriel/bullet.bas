const BURST_SPRITE_ID as ubyte = 16
const BULLET_SPEED as ubyte = 2

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
        If score > hiScore Then
            hiScore = score
        End If
        printLife()
    #endif

    if decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = 0 then
        dim attr, tile, x, y, col, lin, tmpX, tmpY as ubyte

        x = decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_COL)
        y = decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_LIN)
        saveSprite(enemyToKill, 0, 0, 0, 0)
        Draw2x2Sprite(BURST_SPRITE_ID, x, y)
        
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