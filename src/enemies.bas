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

#ifdef SIDE_VIEW
    function checkPlatformHasProtaOnTop(x as ubyte, y as ubyte) as ubyte
        dim protaX1 as ubyte = protaX + 2

        if protaX1 < x then return 0
        if protaX > x + 4 then return 0
        if protaY <> y - 4 then return 0

        return 1
    end function
#endif

sub moveEnemies()
    dim maxEnemiesCount as ubyte = 0

    if enemiesPerScreen(currentScreen) > 0 then maxEnemiesCount = enemiesPerScreen(currentScreen) - 1
    for enemyId=0 TO maxEnemiesCount
        if decompressedEnemiesScreen(enemyId, ENEMY_TILE) = 0
            continue for
        end if
        #ifdef ENEMIES_NOT_RESPAWN_ENABLED
            if decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) <> 99 and decompressedEnemiesScreen(enemyId, ENEMY_TILE) > 15
                if screensWon(currentScreen) then continue for
            end if
        #endif
        
        if decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) > 0 'In the screen and still live
            dim tile as BYTE
            dim enemyCol as BYTE = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) 
            dim enemyLin as BYTE = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)

            tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE)

            if decompressedEnemiesScreen(enemyId, ENEMY_COL_INI) = decompressedEnemiesScreen(enemyId, ENEMY_COL_END) then decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 0
            if decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) = decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) then decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = 0

            if decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
                if decompressedEnemiesScreen(enemyId, ENEMY_COL_INI) = enemyCol or decompressedEnemiesScreen(enemyId, ENEMY_COL_END) = enemyCol
                    decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) * -1
                end if
            end if
            
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)

            if decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 ' Is a platform not an enemy, only 2 frames, 1 direction
                #ifdef SIDE_VIEW
                    if checkPlatformHasProtaOnTop(decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
                        if decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 1
                            if not CheckCollision(protaX + 1, protaY)
                                spritesLinColTileAndFrame(PROTA_SPRITE, 1) = protaX + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
                                protaX = spritesLinColTileAndFrame(PROTA_SPRITE, 1)
                            end if
                        elseif decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = -1
                            if not CheckCollision(protaX - 1, protaY)
                                spritesLinColTileAndFrame(PROTA_SPRITE, 1) = protaX + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)                       
                                protaX = spritesLinColTileAndFrame(PROTA_SPRITE, 1)
                            end if
                        end if
                    end if
                    tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
                #endif
            elseif decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 1
                tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
            elseif decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = -1
                tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 16
            end if

            if decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)
                if decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) = enemyLin or decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) = enemyLin
                    decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) * -1
                end if
            end if
            
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) + decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)

            ' if decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16
            '     saveSpriteLin(PROTA_SPRITE, protaY + decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION))
            ' end if

            if enemFrame
                tile = tile + 1
            end if

            saveSprite(enemyId, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), tile, decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION))

            if decompressedEnemiesScreen(enemyId, ENEMY_TILE) > 15
                checkProtaCollision(enemyId)
            end if
        end if
    next enemyId
end sub

sub checkProtaCollision(enemyId as ubyte)
    if invincible = 1 then return

    dim protaX1 as ubyte = protaX + 2
    dim protaY1 as ubyte = protaY + 2

    dim enemyX0 as ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
    dim enemyY0 as ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
    dim enemyX1 as ubyte = enemyX0 + 2
    dim enemyY1 as ubyte = enemyY0 + 2

    #ifdef SIDE_VIEW
        #ifdef KILL_JUMPING_ON_TOP
            if not landed
                if (protaY1 + 2) = enemyY0
                    if protaX >= (enemyX0-1) and protaX <= (enemyX1+1)
                        damageEnemy(enemyId)
                        landed = 1
                        jump()
                        return
                    end if
                end if
            end if
        #endif
    #endif

    if protaX1 < enemyX0 then return
    if protaX > enemyX1 then return
    if protaY1 < enemyY0 then return
    if protaY > enemyY1 then return

    protaTouch(DAMAGE_AMOUNT)
end sub

#ifdef SIDE_VIEW
    function checkPlatformByXY(x as ubyte, y as ubyte) as ubyte
        if enemiesPerScreen(currentScreen) = 0 then return 0

        for enemyId=0 TO enemiesPerScreen(currentScreen) - 1
            if decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 then
                dim enemyCol as ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) 
                dim enemyLin as ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)

                if x < enemyCol - 2 then continue for
                if x > enemyCol + 4 then continue for
                if y <> enemyLin then continue for
                
                return 1
            end if
        next enemyId

        return 0
    end function
#endif