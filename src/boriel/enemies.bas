Dim resetReturnMovement As Ubyte = 0

#ifdef SIDE_VIEW
    Function checkPlatformHasProtaOnTop(x As Ubyte, y As Ubyte) As Ubyte
        If jumpCurrentKey <> jumpStopValue Then Return 0
        
        If checkAABB(protaX, protaY, protaX + 2, protaY + 4, x, y - 2, x + 4, y) = 0 Then Return 0
        
        Return 1
    End Function
    
    Function checkPlatformByXY(x As Ubyte, y As Ubyte) As Ubyte
        If enemiesPerScreen(currentScreen) = 0 Then Return 0
        
        For enemyId=0 To enemiesPerScreen(currentScreen) - 1
            If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 Then
                Dim enemyCol As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
                Dim enemyLin As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
                
                If x < enemyCol - 2 Then continue For
                If x > enemyCol + 4 Then continue For
                If y <> enemyLin Then continue For
                
                Return 1
            End If
        Next enemyId
        
        Return 0
    End Function
    
    #ifdef KILL_JUMPING_ON_TOP
        Function checkHitOnTop(enemyId As Ubyte, protaX1 As Ubyte, protaY1 As Ubyte, enemyX0 As Ubyte, enemyY0 As Ubyte, enemyX1 As Ubyte, enemyY1 As Ubyte) As Ubyte
            If jumpCurrentKey <> jumpStopValue Then Return 0
            If landed Then Return 0
            
            If enemyY0 > protaY1 + 2 Then Return 0
            If enemyY0 < protaY1 Then Return 0
            
            If checkAABB(protaX, protaY, protaX1, protaY1, enemyX0, enemyY0, enemyX1, enemyY1) Then
                damageEnemy(enemyId)
                landed = 1
                jumpCurrentKey = jumpStopValue
                jump()
                Return 1
            End If
            
            Return 0
        End Function
    #endif
#endif

#ifdef SHOOTING_ENABLED
    Function checkBulletProtaCollision(enemyX0 As Ubyte, enemyY0 As Ubyte, enemyX1 As Ubyte, enemyY1 As Ubyte, enemyId As Ubyte) As Ubyte
        If bulletPositionX = 0 Then Return 0
        
        If checkAABB(bulletPositionX, bulletPositionY, bulletPositionX + 1, bulletPositionY + 1, enemyX0, enemyY0, enemyX1, enemyY1) Then
            damageEnemy(enemyId)
            resetBullet()
            Return 1
        End If
        
        Return 0
    End Function
#endif

#ifdef SWORD_ENABLED
    Function checkSwordEnemyCollision(enemyX0 As Ubyte, enemyY0 As Ubyte, enemyX1 As Ubyte, enemyY1 As Ubyte, enemyId As Ubyte) As Ubyte
        If swordTimer = 0 Then Return 0
        
        Dim swordX As Ubyte
        If swordDirection = 1 Then
            swordX = protaX + 3
            If swordX >= 60 Then swordX = 60
        Else
            If protaX >= 2 Then swordX = protaX - 2 Else swordX = 0
        End If

        If checkAABB(swordX, protaY + 1, swordX + 1, protaY + 2, enemyX0, enemyY0, enemyX1, enemyY1) = 0 Then Return 0
        
        #ifdef SWORD_KILL_ENEMY
            If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) = 98 Then
                killEnemy(enemyId)
            Else
                damageEnemy(enemyId)
            End If
        #else
            damageEnemy(enemyId)
        #endif
        Return 1
    End Function
#endif

Function checkProtaAndBulletCollision(enemyId As Ubyte) As Ubyte
    If invincible Then Return 0
    
    Dim protaX1 As Ubyte = protaX + SPRITE_COLLISION_SIZE
    Dim protaY1 As Ubyte = protaY + SPRITE_COLLISION_SIZE
    
    Dim enemyX0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
    Dim enemyY0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
    Dim enemyX1 As Ubyte = enemyX0 + SPRITE_COLLISION_SIZE
    Dim enemyY1 As Ubyte = enemyY0 + SPRITE_COLLISION_SIZE
    
    Dim damage As Ubyte = 0
    
    #ifdef SHOOTING_ENABLED
        If checkBulletProtaCollision(enemyX0, enemyY0, enemyX1, enemyY1, enemyId) Then Return 1
    #endif
    
    #ifdef SWORD_ENABLED
        If checkSwordEnemyCollision(enemyX0, enemyY0, enemyX1, enemyY1, enemyId) Then Return 1
    #endif
    
    #ifdef SIDE_VIEW
        #ifdef KILL_JUMPING_ON_TOP
            If checkHitOnTop(enemyId, protaX1, protaY1, enemyX0, enemyY0, enemyX1, enemyY1) Then Return 1
        #endif
    #endif

    If checkAABB(protaX, protaY, protaX1, protaY1, enemyX0, enemyY0, enemyX1, enemyY1) = 0 Then Return 0
    
    decrementLife()
    
    Return 0
End Function

Function checkShouldSkipMoveBySpeed(enemySpeed As Ubyte) As Ubyte
    If enemySpeed > 2 Then Return 0
    Return skipMove(enemySpeed)
End Function

Sub updateEnemyFrame(enemyId As Ubyte)
    If currentEnemyFrame(enemyId) = 0 Then
        currentEnemyFrame(enemyId) = 1
    Else
        currentEnemyFrame(enemyId) = 0
    End If
End Sub

Sub saveAndDraw(enemyId as Ubyte, tile As Ubyte, horizontalDirection As Ubyte, verticalDirection As Ubyte, enemyCol As Byte, enemyLin As Byte, enemySpeed As Ubyte)
    If tile < 16 Then
        updateEnemyFrame(enemyId)
    End If
    If checkShouldSkipMoveBySpeed(enemySpeed) Then
        Draw2x2Sprite(tile + currentEnemyFrame(enemyId), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
    Else
        If tile > 15 Then
            If decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) <> enemyCol Or decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) <> enemyLin Then
                updateEnemyFrame(enemyId)
            End If
        End If
        Draw2x2Sprite(tile + currentEnemyFrame(enemyId), enemyCol, enemyLin)
        decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol
        decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLin
        decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = horizontalDirection
        decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = verticalDirection
    End If
End Sub

Sub checkCollisionSaveAndDraw(enemyId as Ubyte, tile As Ubyte, horizontalDirection As Ubyte, verticalDirection As Ubyte, enemyCol As Byte, enemyLin As Byte, enemySpeed As Ubyte)
    If checkProtaAndBulletCollision(enemyId) Then
        If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) <= 0 Then Return
    End If

    saveAndDraw(enemyId, tile, horizontalDirection, verticalDirection, enemyCol, enemyLin, enemySpeed)
End Sub

' Updates enemy position, checks collision, flips tile for direction, animates frame, and draws.
' Returns 1 if the enemy was killed (caller should Continue For), 0 otherwise.
Sub calculatePositionAndTile(Byref tile As Ubyte, Byref enemyCol As Byte, Byref enemyLin As Byte, enemyHorizontalDirection As Byte, enemyVerticalDirection As Byte)
    enemyCol = enemyCol + enemyHorizontalDirection
    enemyLin = enemyLin + enemyVerticalDirection

    If tile > 15 Then
        If enemyHorizontalDirection = -1 Then
            tile = tile + 16
        End If
    End If
End Sub

#ifdef ENEMY_SHOOT_ENABLED
    Sub shootEnemyBullet(enemyCol As Byte, enemyLin As Byte)
        If enemyBulletX <> 0 Then Return
        Dim dx As Integer = protaX - enemyCol
        Dim dy As Integer = protaY - enemyLin
        If dx = 0 And dy = 0 Then Return
        enemyBulletDirX = Sgn(dx)
        enemyBulletDirY = Sgn(dy)
        enemyBulletX = enemyCol + 1
        enemyBulletY = enemyLin + 1
        enemyBulletSpriteId = ENEMY_BULLET_SPRITE_ID
    End Sub

    Sub moveEnemyBullet()
        If enemyBulletX = 0 Then Return

        Dim newX As Integer = enemyBulletX + enemyBulletDirX
        Dim newY As Integer = enemyBulletY + enemyBulletDirY

        If newX < 2 Or newX > 60 Or newY < 2 Or newY > 40 Then
            enemyBulletX = 0
            Return
        End If

        #ifdef ENEMY_SHOOT_SOLID_COLLIDE
            If isSolidTileByColLin(newX >> 1, newY >> 1) Then
                enemyBulletX = 0
                Return
            End If
        #endif

        enemyBulletX = newX
        enemyBulletY = newY

        If invincible Then Return

        If checkAABB(enemyBulletX, enemyBulletY, enemyBulletX + 1, enemyBulletY + 1, protaX, protaY, protaX + SPRITE_COLLISION_SIZE, protaY + SPRITE_COLLISION_SIZE) Then
            enemyBulletX = 0
            decrementLife()
        End If
    End Sub
#endif

Sub setEnemyDirectionForDefaulMovement(enemyCol As Byte, enemyLin As Byte, enemyColIni As Byte, enemyLinIni As Byte, enemyColEnd As Byte, enemyLinEnd As Byte, ByRef enemyHorizontalDirection As Byte, ByRef enemyVerticalDirection As Byte)
    If enemyHorizontalDirection Then
        If enemyColIni = enemyCol Or enemyColEnd = enemyCol Then
            enemyHorizontalDirection = enemyHorizontalDirection * -1
        End If
    End If
    
    If enemyVerticalDirection Then
        If enemyLinIni = enemyLin Or enemyLinEnd = enemyLin Then
            enemyVerticalDirection = enemyVerticalDirection * -1
        End If
    End If
End Sub

Sub moveEnemies()
    If enemiesPerScreen(currentScreen) = 0 Then Return
    
    For enemyId=0 To enemiesPerScreen(currentScreen) - 1
        Dim enemyAlive As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_ALIVE)
        
        If enemyAlive <= 0 Then continue For
        
        Dim tile As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 1
        
        If tile = 0 Then continue For
        
        #ifdef ENEMIES_NOT_RESPAWN_ENABLED
            If tile > 15 Then
                If enemyAlive < 99 Then
                    If screensWon(currentScreen) Then continue For
                End If
            End If
        #endif
        
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
        
        If enemyColIni = enemyColEnd Then enemyHorizontalDirection = 0
        If enemyLinIni = enemyLinEnd Then enemyVerticalDirection = 0

        ' Platforms
        #ifdef SIDE_VIEW
            If tile < 16 Then
                setEnemyDirectionForDefaulMovement(enemyCol, enemyLin, enemyColIni, enemyLinIni, enemyColEnd, enemyLinEnd, enemyHorizontalDirection, enemyVerticalDirection)

                enemyCol = enemyCol + enemyHorizontalDirection
                enemyLin = enemyLin + enemyVerticalDirection

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

        #ifdef ENEMY_SHOOT_ENABLED
            Dim enemyShootingTrigger As Ubyte = enemyId * 50

            If enemyBehaviour = ENEMY_BEHAVIOUR_DEFAULT_SHOOT And mainLoopCounter = enemyShootingTrigger Then
                shootEnemyBullet(enemyCol, enemyLin)
            End If
                    
            If enemyBehaviour = ENEMY_BEHAVIOUR_DEFAULT_SHOOT And mainLoopCounter - enemyShootingTrigger < ENEMY_STOP_FRAMES Then
                If enemyHorizontalDirection = 1 Then
                    tile = tile
                Else
                    tile = tile + 16
                End If
                checkCollisionSaveAndDraw(enemyId, tile, enemyHorizontalDirection, enemyVerticalDirection, enemyCol, enemyLin, enemySpeed)
                Continue For
            End If
        #endif

        If enemyLinEnd = -1 Then
            enemyHorizontalDirection = Sgn(protaX - enemyCol)
            enemyVerticalDirection = Sgn(protaY - enemyLin)
            #ifdef FREEZE_ON_SIGHT_ENABLED
                ' Enemy without col end: freeze if the player is seeing it
                If enemyColEnd = -1 Then
                    If (protaDirection = 1 And enemyHorizontalDirection = -1) Or (protaDirection = 0 And enemyHorizontalDirection = 1) Then
                        If enemyHorizontalDirection = -1 Then
                            tile = tile + 16
                        End If
                    Else
                        calculatePositionAndTile(tile, enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection)
                    End If
                End If
            #else
                calculatePositionAndTile(tile, enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection)
            #endif
        Elseif enemyBehaviour = ENEMY_BEHAVIOUR_DEFAULT Or enemyBehaviour = ENEMY_BEHAVIOUR_DEFAULT_SHOOT Then
            setEnemyDirectionForDefaulMovement(enemyCol, enemyLin, enemyColIni, enemyLinIni, enemyColEnd, enemyLinEnd, enemyHorizontalDirection, enemyVerticalDirection)
            calculatePositionAndTile(tile, enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection)
        Elseif enemyBehaviour = ENEMY_BEHAVIOUR_NO_RETURN Then
            enemyHorizontalDirection = Sgn(enemyColEnd - enemyColIni)
            enemyVerticalDirection = Sgn(enemyLinEnd - enemyLinIni)
            
            enemyCol = enemyCol + enemyHorizontalDirection
            enemyLin = enemyLin + enemyVerticalDirection
            
            If resetReturnMovement Then
                enemyCol = enemyColIni
                enemyLin = enemyLinIni
                ' Forze save because maybe speed skip it
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLin
                tile = tile + 16
                resetReturnMovement = 0
            Elseif enemyCol = enemyColEnd Or enemyLin = enemyLinEnd Then
                tile = tile + 17
                resetReturnMovement = 1
            End If
        #ifdef RECTANGULAR_MOVE_ENABLED
        Elseif enemyBehaviour = ENEMY_BEHAVIOUR_RECTANGULAR Then
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