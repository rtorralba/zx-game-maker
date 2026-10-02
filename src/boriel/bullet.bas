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
            #ifdef OVERHEAD_VIEW
                if bulletPositionY = maxYScreenTop or bulletPositionY = maxYScreenBottom then
                    resetBullet()
                    return
                end if
            #endif
            
            dim xToCheck as ubyte
            
            if bulletDirection = 1 then
                xToCheck = bulletPositionX + 1
            else
                xToCheck = bulletPositionX
            end if
            
            dim tile as ubyte
            dim xToCheckTile as ubyte = xToCheck >> 1
            dim yToCheckTile as ubyte
            
            tile = isSolidTileByColLin(xToCheckTile, bulletPositionY >> 1)
            if tile then
                yToCheckTile = bulletPositionY >> 1
            else
                tile = isSolidTileByColLin(xToCheckTile, (bulletPositionY + 1) >> 1)
                if tile then
                    yToCheckTile = (bulletPositionY + 1) >> 1
                else
                    return
                end if
            end if
            
            breakTileAt(xToCheckTile, yToCheckTile)
            resetBullet()
        end sub
        
        sub resetBullet()
            bulletPositionX = 0
            bulletPositionY = 0
            bulletDirection = 0
        end sub
    #endif
    
    #ifdef SWORD_KILL_ENEMY
        Sub killEnemy(enemyToKill as Ubyte, enemyPtr As Uinteger)
            Poke enemyPtr + ENEMY_LIFE, 0
            removeEnemy(enemyToKill, enemyPtr)
        End Sub
    #endif
    
    sub damageEnemy(enemyToKill as Ubyte, enemyPtr As Uinteger)
        Dim currentLife As Ubyte = Peek(enemyPtr + ENEMY_LIFE)
        if currentLife > 97 then return 'invincible enemies
        
        currentLife = currentLife - 1
        Poke enemyPtr + ENEMY_LIFE, currentLife
        
        #ifdef HISCORE_ENABLED
            incrementScore(5)
            shouldPrintHud = 1
        #endif
        
        if currentLife = 0 then                        
            removeEnemy(enemyToKill, enemyPtr)
        else
            BeepFX_Play(1)
        end if
    end sub
    
    Sub removeEnemy(enemyToKill as Ubyte, enemyPtr As Uinteger)
        x = Peek(enemyPtr + ENEMY_CURRENT_COL)
        y = Peek(enemyPtr + ENEMY_CURRENT_LIN)
        Draw2x2Sprite(BURST_SPRITE_ID, x, y)
        
        BeepFX_Play(0)
        
        #ifdef SHOULD_CHECK_SCREENS_WON
            if not screensWon(currentScreen) then
                if allEnemiesKilled() then
                    screensWon(currentScreen) = 1
                    removeTilesFromScreen(63)
                end if
            end if
        #endif

        #ifdef FINISH_GAME_OBJECTIVE_ENEMY
            If Peek(enemyPtr + ENEMY_ID) = ENEMY_TO_KILL and enemyToKillAlreadyKilled = 0 Then
                enemyToKillAlreadyKilled = 1
            End If
        #endif
        #ifdef FINISH_GAME_OBJECTIVE_ITEMS_AND_ENEMY
            If Peek(enemyPtr + ENEMY_ID) = ENEMY_TO_KILL and enemyToKillAlreadyKilled = 0 Then
                enemyToKillAlreadyKilled = 1
            End If
        #endif
    End Sub