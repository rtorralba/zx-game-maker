#ifdef SIDE_VIEW
    Function checkPlatformHasProtaOnTop(x As Ubyte, y As Ubyte) As Ubyte
        If jumpCurrentKey <> jumpStopValue Then Return 0
        
        Dim protaX1 As Ubyte = protaX + 2
        Dim protaY1 As Ubyte = protaY + 4
        
        If protaX > x + 2 Then Return 0
        If protaX1 < x Then Return 0
        If protaY > y + 2 Then Return 0
        If protaY1 < y - 2 Then Return 0
        
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
            
            If protaX >= enemyX0 And protaX <= enemyX1 Or protaX1 <= enemyX1 And protaX1 >= enemyX0 Then
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

Function checkBulletProtaCollision(enemyX0 As Ubyte, enemyY0 As Ubyte, enemyX1 As Ubyte, enemyY1 As Ubyte, enemyId As Ubyte) As Ubyte
    If bulletPositionX = 0 Then Return 0

    Dim bulletX0 As Ubyte = bulletPositionX
    Dim bulletX1 As Ubyte = bulletPositionX + 1
    Dim bulletY0 As Ubyte = bulletPositionY
    Dim bulletY1 As Ubyte = bulletPositionY + 1
    
    If bulletX1 < enemyX0 Then Return 0
    If bulletX0 > enemyX1 Then Return 0
    If bulletY1 < enemyY0 Then Return 0
    If bulletY0 > enemyY1 Then Return 0
    
    damageEnemy(enemyId)
    resetBullet()

    Return 1
End Function

Function checkProtaAndBulletCollision(enemyId As Ubyte) As Ubyte
    If invincible Then Return 0
    
    Dim protaX1 As Ubyte = protaX + 3
    Dim protaY1 As Ubyte = protaY + 3
    
    Dim enemyX0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
    Dim enemyY0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
    Dim enemyX1 As Ubyte = enemyX0 + 3
    Dim enemyY1 As Ubyte = enemyY0 + 3

    Dim damage As Ubyte = 0
    
    #ifdef SHOOTING_ENABLED
        If checkBulletProtaCollision(enemyX0, enemyY0, enemyX1, enemyY1, enemyId) Then Return 1
    #endif

    #ifdef SIDE_VIEW
        #ifdef KILL_JUMPING_ON_TOP
            If checkHitOnTop(enemyId, protaX1, protaY1, enemyX0, enemyY0, enemyX1, enemyY1) Then Return 1
        #endif
    #endif
    
    If protaX1 < enemyX0 Then Return 0
    If protaX > enemyX1 Then Return 0
    If protaY1 < enemyY0 Then Return 0
    If protaY > enemyY1 Then Return 0
    
    decrementLife()
    
    Return 0
End Function

Sub saveAndDraw(enemyId as Ubyte, tile As Ubyte, horizontalDirection As Ubyte, verticalDirection As Ubyte)
    Draw2x2Sprite(tile, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
    decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = horizontalDirection
    decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = verticalDirection
End Sub

Sub checkAndDraw(enemyId as Ubyte, tile As Ubyte, enemyCol As Byte, enemyLin As Byte)
    if checkProtaAndBulletCollision(enemyId) Then
        If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) <= 0 Then
            Return
        End If
    End If
    Draw2x2Sprite(tile + 1, enemyCol, enemyLin)
End Sub

Function checkShouldSkipMoveBySpeed(enemySpeed As Ubyte) As Ubyte
    If enemySpeed = 0 Then
        If skipMove0 Then Return 1
    Elseif enemySpeed = 1 Then
        If skipMove1 Then Return 1
    Elseif enemySpeed = 2 Then
        If skipMove2 Then Return 1
    End If
    Return 0
End Function

Sub moveEnemies()
    If enemiesPerScreen(currentScreen) = 0 Then Return
    For enemyId=0 To enemiesPerScreen(currentScreen) - 1
        Dim enemyAlive As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_ALIVE)

        If enemyAlive <= 0 Then continue For

        Dim tile As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_TILE)

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
        
        If enemyBehaviour = 0 Then
            If enemyLinEnd = -1 Then
                enemyHorizontalDirection = Sgn(protaX - enemyCol)
                enemyVerticalDirection = Sgn(protaY - enemyLin)
            Else
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
            End If

            If checkShouldSkipMoveBySpeed(enemySpeed) Then
                If tile > 15 Then
                    If enemyHorizontalDirection = -1 Then
                        tile = tile + 16
                    End If
                End If
                checkAndDraw(enemyId, tile, enemyCol, enemyLin)
                Continue For
            End If

            enemyCol = enemyCol + enemyHorizontalDirection
            enemyLin = enemyLin + enemyVerticalDirection

            If tile < 16 Then
                #ifdef SIDE_VIEW
                    If checkPlatformHasProtaOnTop(enemyCol, enemyLin) Then
                        jumpCurrentKey = jumpStopValue
                        If enemyVerticalDirection Then
                            If Not CheckCollision(protaX, enemyLin - 4, 1) Then
                                protaY = enemyLin - 4
                            End If
                        End If
                        
                        If enemyHorizontalDirection Then
                            If Not CheckCollision(protaX + enemyHorizontalDirection, protaY, 1) Then
                                protaX = protaX + enemyHorizontalDirection
                            End If
                        End If
                    End If
                #endif
            Else
                If checkProtaAndBulletCollision(enemyId) Then
                    If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) <= 0 Then
                        continue For
                    End If
                End If
                
                If enemyHorizontalDirection = -1 Then
                    tile = tile + 16
                End If
            End If
            
            If enemFrame Then
                tile = tile + 1
            End If

            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLin

            saveAndDraw(enemyId, tile + 1, enemyHorizontalDirection, enemyVerticalDirection)
        Elseif enemyBehaviour = 1 Then
            If checkShouldSkipMoveBySpeed(enemySpeed) Then
                checkAndDraw(enemyId, tile, enemyCol, enemyLin)
                Continue For
            End If

            enemyHorizontalDirection = Sgn(enemyColEnd - enemyColIni)
            enemyVerticalDirection = Sgn(enemyLinEnd - enemyLinIni)
            
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) =  enemyCol + enemyHorizontalDirection
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLin + enemyVerticalDirection

            If enemyCol = enemyColIni And enemyLin = enemyLinIni Then
                saveAndDraw(enemyId, tile + 17, enemyHorizontalDirection, enemyVerticalDirection)
                continue For
            ElseIf enemyCol + enemyHorizontalDirection = enemyColEnd And enemyLin + enemyVerticalDirection = enemyLinEnd Then
                saveAndDraw(enemyId, tile + 18, enemyHorizontalDirection, enemyVerticalDirection)
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyColIni
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLinIni
                continue For
            End If

            If enemyCol = enemyColEnd Or enemyLin = enemyLinEnd Then
                If enemyCol = enemyColEnd Then
                    decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyColIni
                End If
                If enemyLin = enemyLinEnd Then
                    decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLinIni
                End If
            End If

            If enemFrame Then
                tile = tile + 1
            End If

            If checkProtaAndBulletCollision(enemyId) Then
                If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) <= 0 Then
                    continue For
                End If
            End If

            saveAndDraw(enemyId, tile + 1, enemyHorizontalDirection, enemyVerticalDirection)
        End If
    Next enemyId
End Sub