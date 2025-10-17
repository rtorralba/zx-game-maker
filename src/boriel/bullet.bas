const BURST_SPRITE_ID as ubyte = 16
const BULLET_SPEED as ubyte = 2

dim maxXScreenRight as ubyte = 60
dim maxXScreenLeft as ubyte = 2
#ifdef OVERHEAD_VIEW
    dim maxYScreenBottom as ubyte = 40
    dim maxYScreenTop as ubyte = 2
#endif

#ifdef SHOOTING_ENABLED
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

        dim tile as ubyte = isSolidTileByColLin(xToCheck >> 1, bulletPositionY >> 1)
        if tile then
            #ifdef USE_BREAKABLE_TILE_ALL
                if tile = BREAKABLE_BY_BULLET_TILE then
                    brokenTiles(currentScreen) = 1
                    BeepFX_Play(0)
                    removeTilesFromScreen(BREAKABLE_BY_BULLET_TILE)
                end if
            #endif
            #ifdef USE_BREAKABLE_TILE_INDIVIDUAL
                if tile = BREAKABLE_BY_BULLET_TILE then
                    brokenTiles(brokenTilesCurrentIndex, 0) = currentScreen
                    brokenTiles(brokenTilesCurrentIndex, 1) = xToCheck >> 1
                    brokenTiles(brokenTilesCurrentIndex, 2) = bulletPositionY >> 1
                    If brokenTilesCurrentIndex < BREAKABLE_TILES_COUNT - 1 Then
                        brokenTilesCurrentIndex = brokenTilesCurrentIndex + 1
                    End If

                    BeepFX_Play(0)
                    SetTile(0, BACKGROUND_ATTRIBUTE, xToCheck >> 1, bulletPositionY >> 1)
                end if
            #endif
            resetBullet()
            return
        else
            tile = isSolidTileByColLin(xToCheck >> 1, (bulletPositionY + 1) >> 1)
            if tile then
                #ifdef USE_BREAKABLE_TILE_ALL
                    if tile = BREAKABLE_BY_BULLET_TILE then
                        brokenTiles(currentScreen) = 1
                        BeepFX_Play(0)
                        removeTilesFromScreen(BREAKABLE_BY_BULLET_TILE)
                    end if
                #endif
                #ifdef USE_BREAKABLE_TILE_INDIVIDUAL
                    if tile = BREAKABLE_BY_BULLET_TILE then
                        brokenTiles(brokenTilesCurrentIndex, 0) = currentScreen
                        brokenTiles(brokenTilesCurrentIndex, 1) = xToCheck >> 1
                        brokenTiles(brokenTilesCurrentIndex, 2) = (bulletPositionY + 1) >> 1
                        If brokenTilesCurrentIndex < BREAKABLE_TILES_COUNT - 1 Then
                            brokenTilesCurrentIndex = brokenTilesCurrentIndex + 1
                        End If
                        BeepFX_Play(0)
                        SetTile(0, BACKGROUND_ATTRIBUTE, xToCheck >> 1, (bulletPositionY + 1) >> 1)
                    end if
                #endif
                resetBullet()
                return
            end if
        end if
    end sub

    sub resetBullet()
        bulletPositionX = 0
        bulletPositionY = 0
        bulletDirection = 0
    end sub
#endif

sub damageEnemy(enemyToKill as Ubyte)
    if decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = 99 then return 'invincible enemies

    decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) - 1
    #ifdef HISCORE_ENABLED
        incrementScore(5)
        printHud()
    #endif

    if decompressedEnemiesScreen(enemyToKill, ENEMY_ALIVE) = 0 then
        dim attr, tile, x, y, col, lin, tmpX, tmpY as ubyte

        #ifdef FINISH_GAME_OBJECTIVE_ENEMY
            If decompressedEnemiesScreen(enemyToKill, ENEMY_ID) = ENEMY_TO_KILL and enemyToKillAlreadyKilled = 0 Then
                enemyToKillAlreadyKilled = 1
            End If
        #endif
        #ifdef FINISH_GAME_OBJECTIVE_ITEMS_AND_ENEMY
            If decompressedEnemiesScreen(enemyToKill, ENEMY_ID) = ENEMY_TO_KILL and enemyToKillAlreadyKilled = 0 Then
                enemyToKillAlreadyKilled = 1
            End If
        #endif

        x = decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_COL)
        y = decompressedEnemiesScreen(enemyToKill, ENEMY_CURRENT_LIN)
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