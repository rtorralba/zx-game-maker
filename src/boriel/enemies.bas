#include "enemies/enemiesShared.bas"

Sub moveEnemies()
    If enemiesPerScreen(currentScreen) = 0 Then Return
    
    For enemyId=0 To enemiesPerScreen(currentScreen) - 1
        Dim enemyCol As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
        Dim enemyLin As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
        Dim enemySpeed As Byte = decompressedEnemiesScreen(enemyId, ENEMY_SPEED)
        Dim enemyColIni As Byte = decompressedEnemiesScreen(enemyId, ENEMY_COL_INI)
        Dim enemyLinIni As Byte = decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI)
        Dim enemyColEnd As Byte = decompressedEnemiesScreen(enemyId, ENEMY_COL_END)
        Dim enemyLinEnd As Byte = decompressedEnemiesScreen(enemyId, ENEMY_LIN_END)
        Dim enemyBehaviour As Byte = decompressedEnemiesScreen(enemyId, ENEMY_MOVE)
        Dim enemyHorizontalDirection As Byte = decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
        Dim enemyVerticalDirection As Byte = decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)
        Dim enemyLife As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_LIFE)
        Dim tile As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 1
        
        If isEnemyDeath(enemyLife) Then continue For
        If tile = 0 Then continue For
        
        If enemyColIni = enemyColEnd Then enemyHorizontalDirection = 0
        If enemyLinIni = enemyLinEnd Then enemyVerticalDirection = 0
        
        ' Platforms
        #ifdef SIDE_VIEW
            If isPlatform(tile) Then
                setEnemyDirectionForDefaulMovement(enemyCol, enemyLin, enemyColIni, enemyLinIni, enemyColEnd, enemyLinEnd, enemyHorizontalDirection, enemyVerticalDirection)
                
                moveEnemyPosition(enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection)
                
                ' Platform enemy: move the player if standing on top
                If checkPlatformHasProtaOnTop(enemyCol, enemyLin) Then
                    jumpCurrentKey = jumpStopValue
                    If enemyVerticalDirection Then
                        If Not CheckCollision(protaX, enemyLin - 4, 1) Then
                            protaY = enemyLin - 4
                        End If
                    End If
                    If enemyHorizontalDirection Then
                        If Not CheckCollision(protaX + enemyHorizontalDirection, protaY, 1) Then
                            If Not checkShouldSkipMoveBySpeed(enemySpeed) Then
                                protaX = protaX + enemyHorizontalDirection
                            End If
                        End If
                    End If
                End If
                
                saveAndDraw(enemyId, tile, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin, enemySpeed)
                
                Continue For
            End If
        #endif
        
        #ifdef ENEMIES_NOT_RESPAWN_ENABLED
            If isEnemyVulnerable(enemyLife) Then If screensWon(currentScreen) Then continue For
        #endif
        
        #ifdef ENEMY_SHOOT_ENABLED
            Dim enemyShootingTrigger As Ubyte = enemyId * 50
            
            If enemyShouldShoot(enemyBehaviour) And mainLoopCounter = enemyShootingTrigger Then
                shootEnemyBullet(enemyCol, enemyLin)
            End If
            
            If enemyShouldShoot(enemyBehaviour) And mainLoopCounter - enemyShootingTrigger < ENEMY_STOP_FRAMES Then
                checkLeftDirection(enemyHorizontalDirection, tile)
                checkCollisionSaveAndDraw(enemyId, tile, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin, enemySpeed)
                Continue For
            End If
        #endif
        
        If isEnemyStopped(enemyLinEnd, enemyBehaviour) Then
            #ifdef ENEMY_STOPPED_SHOULD_LOOK_AT_PLAYER
                enemyHorizontalDirection = Sgn(protaX - enemyCol)
                checkLeftDirection(enemyHorizontalDirection, tile)
            #endif
            checkCollisionSaveAndDraw(enemyId, tile, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin, enemySpeed)
            Continue For
        ElseIf hasStalkerBehaviour(enemyBehaviour) Then
            enemyHorizontalDirection = Sgn(protaX - enemyCol)
            enemyVerticalDirection = Sgn(protaY - enemyLin)
            
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
                saveData(enemyId, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin)
                
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
        
        checkCollisionSaveAndDraw(enemyId, tile, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin, enemySpeed)
    Next enemyId
End Sub