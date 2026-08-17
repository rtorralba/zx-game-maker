#include "enemies/enemiesShared.bas"

Sub moveEnemies()
    If enemiesPerScreen(currentScreen) = 0 Then Return
    
    Dim enemyPtr As Uinteger = @decompressedEnemiesScreen(0, 0)
    For enemyId=0 To enemiesPerScreen(currentScreen) - 1
        Dim enemyLife As Ubyte = Peek(enemyPtr + ENEMY_LIFE)
        
        If isEnemyDeath(enemyLife) Then Goto next_enemy
        
        Dim tile As Ubyte = Peek(enemyPtr + ENEMY_TILE) + 1
        
        If tile = 0 Then Goto next_enemy
        
        Dim enemyCol As Byte = Peek(enemyPtr + ENEMY_CURRENT_COL)
        Dim enemyLin As Byte = Peek(enemyPtr + ENEMY_CURRENT_LIN)
        Dim enemySpeed As Byte = Peek(enemyPtr + ENEMY_SPEED)
        Dim enemyColIni As Byte = Peek(enemyPtr + ENEMY_COL_INI)
        Dim enemyLinIni As Byte = Peek(enemyPtr + ENEMY_LIN_INI)
        Dim enemyColEnd As Byte = Peek(enemyPtr + ENEMY_COL_END)
        Dim enemyLinEnd As Byte = Peek(enemyPtr + ENEMY_LIN_END)
        Dim enemyBehaviour As Byte = Peek(enemyPtr + ENEMY_MOVE)
        Dim enemyHorizontalDirection As Byte = Peek(enemyPtr + ENEMY_HORIZONTAL_DIRECTION)
        Dim enemyVerticalDirection As Byte = Peek(enemyPtr + ENEMY_VERTICAL_DIRECTION)
        
        If enemyColIni = enemyColEnd Then enemyHorizontalDirection = 0
        If enemyLinIni = enemyLinEnd Then enemyVerticalDirection = 0
        
        ' Platforms
        #ifdef SIDE_VIEW
            If isPlatform(tile) Then
                setEnemyDirectionForDefaulMovement(enemyCol, enemyLin, enemyColIni, enemyLinIni, enemyColEnd, enemyLinEnd, enemyHorizontalDirection, enemyVerticalDirection)
                
                moveEnemyPosition(enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection)
                
                ' Platform enemy: move the player if standing on top
                If checkPlatformHasProtaOnTop(enemyCol, enemyLin) Then
                    stopJump()
                    Dim snapLin As Byte = enemyLin
                    If checkShouldSkipMoveBySpeed(enemySpeed) Then
                        snapLin = Peek(enemyPtr + ENEMY_CURRENT_LIN)
                    End If
                    If enemyVerticalDirection Then
                        If Not CheckCollision(protaX, snapLin - 4, 1) Then
                            protaY = snapLin - 4
                        End If
                    End If
                    If enemyHorizontalDirection Then
                        If Not checkShouldSkipMoveBySpeed(enemySpeed) Then
                            If Not CheckCollision(protaX + enemyHorizontalDirection, protaY, 1) Then
                                protaX = protaX + enemyHorizontalDirection
                            End If
                        End If
                    End If
                End If
                
                saveAndDraw(enemyId, enemyPtr, tile, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin, enemySpeed)
                
                Goto next_enemy
            End If
        #endif
        
        #ifdef ENEMIES_NOT_RESPAWN_ENABLED
            If isEnemyVulnerable(enemyLife) And screensWon(currentScreen) Then Goto next_enemy
        #endif
        
        #ifdef ENEMY_SHOOT_ENABLED
            Dim enemyShootingTrigger As Ubyte = enemyId * 50
            
            If enemyShouldShoot(enemyBehaviour) And mainLoopCounter = enemyShootingTrigger Then
                shootEnemyBullet(enemyCol, enemyLin)
            End If
            
            If enemyShouldShoot(enemyBehaviour) And mainLoopCounter - enemyShootingTrigger < ENEMY_STOP_FRAMES Then
                #ifdef ENEMY_STOPPED_SHOULD_LOOK_AT_PLAYER
                    If isEnemyStopped(enemyLinEnd, enemyBehaviour) Then
                        enemyHorizontalDirection = Sgn(protaX - enemyCol)
                    End If
                #endif
                checkLeftDirection(enemyHorizontalDirection, tile)
                checkCollisionSaveAndDraw(enemyId, enemyPtr, tile, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin, enemySpeed)
                Goto next_enemy
            End If
        #endif
        
        If isEnemyStopped(enemyLinEnd, enemyBehaviour) Then
            #ifdef ENEMY_STOPPED_SHOULD_LOOK_AT_PLAYER
                enemyHorizontalDirection = sgn8(protaX - enemyCol)
                checkLeftDirection(enemyHorizontalDirection, tile)
            #endif
            checkCollisionSaveAndDraw(enemyId, enemyPtr, tile, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin, enemySpeed)
            Goto next_enemy
        ElseIf hasStalkerBehaviour(enemyBehaviour) Then
            enemyHorizontalDirection = sgn8(protaX - enemyCol)
            enemyVerticalDirection = sgn8(protaY - enemyLin)
            
            #ifndef FREEZE_ON_SIGHT_ENABLED
                calculatePositionAndTile(tile, enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection)
            #else
                If freezeOnSight(enemyColEnd) <> 1 Or areLookingAtEachOther(enemyHorizontalDirection) <> 1 Then
                    calculatePositionAndTile(tile, enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection)
                Else
                    checkLeftDirection(enemyHorizontalDirection, tile)
                End If
            #endif
        Elseif hasDefaultBehaviour(enemyBehaviour) Then
            setEnemyDirectionForDefaulMovement(enemyCol, enemyLin, enemyColIni, enemyLinIni, enemyColEnd, enemyLinEnd, enemyHorizontalDirection, enemyVerticalDirection)
            calculatePositionAndTile(tile, enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection)
        Elseif hasNoReturnBehaviour(enemyBehaviour) Then
            setEnemyDirectionForDefaulMovement(enemyCol, enemyLin, enemyColIni, enemyLinIni, enemyColEnd, enemyLinEnd, enemyHorizontalDirection, enemyVerticalDirection)
            
            moveEnemyPosition(enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection)
            
            Dim objectiveAxisY As Ubyte = 1
            
            If Abs(enemyColEnd - enemyColIni) > Abs(enemyLinEnd - enemyLinIni) Then
                objectiveAxisY = 0
            End If
            
            If resetReturnMovement(enemyId) Then
                enemyCol = enemyColIni
                enemyLin = enemyLinIni
                
                If enemyColIni < enemyColEnd Then
                    enemyHorizontalDirection = 255
                Else
                    enemyHorizontalDirection = 1
                End If
                
                If enemyLinIni > enemyLinEnd Then
                    enemyVerticalDirection = 1
                Else
                    enemyVerticalDirection = 255
                End If
                
                ' Forze save because maybe speed skip it
                saveData(enemyPtr, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin)
                
                tile = tile + 16
                resetReturnMovement(enemyId) = 0
            Elseif objectiveAxisY = 1 And enemyLin = enemyLinEnd Or objectiveAxisY = 0 And enemyCol = enemyColEnd Then
                tile = tile + 17
                resetReturnMovement(enemyId) = 1
            End If
            #ifdef RECTANGULAR_MOVE_ENABLED
            Elseif hasRectangularBehaviour(enemyBehaviour) Then
                ' Rectangular clockwise movement
                ' Normalize rectangle corners to min/max
                Dim rectMinCol As Byte
                Dim rectMaxCol As Byte
                Dim rectMinLin As Byte
                Dim rectMaxLin As Byte
                If enemyColIni < enemyColEnd Then
                    rectMinCol = enemyColIni
                    rectMaxCol = enemyColEnd
                Else
                    rectMinCol = enemyColEnd
                    rectMaxCol = enemyColIni
                End If
                If enemyLinIni < enemyLinEnd Then
                    rectMinLin = enemyLinIni
                    rectMaxLin = enemyLinEnd
                Else
                    rectMinLin = enemyLinEnd
                    rectMaxLin = enemyLinIni
                End If
                ' Clockwise: top→right, right→down, bottom→left, left→up
                If enemyLin = rectMinLin And enemyCol < rectMaxCol Then
                    ' Top edge: move right
                    enemyHorizontalDirection = 1
                    enemyVerticalDirection = 0
                Elseif enemyCol = rectMaxCol And enemyLin < rectMaxLin Then
                    ' Right edge: move down
                    enemyHorizontalDirection = 0
                    enemyVerticalDirection = 1
                Elseif enemyLin = rectMaxLin And enemyCol > rectMinCol Then
                    ' Bottom edge: move left
                    enemyHorizontalDirection = -1
                    enemyVerticalDirection = 0
                Else
                    ' Left edge: move up
                    enemyHorizontalDirection = 0
                    enemyVerticalDirection = -1
                End If
                calculatePositionAndTile(tile, enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection)
            #endif
        End If
        
        checkCollisionSaveAndDraw(enemyId, enemyPtr, tile, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin, enemySpeed)
next_enemy:
        enemyPtr = enemyPtr + 13
    Next enemyId
End Sub