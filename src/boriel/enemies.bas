#ifdef SIDE_VIEW
    Function checkPlatformHasProtaOnTop(x As Ubyte, y As Ubyte) As Ubyte
        If jumpCurrentKey <> jumpStopValue Then Return 0
        
        Dim protaX1 As Ubyte = protaX + 4
        Dim protaY1 As Ubyte = protaY + 4
        
        If protaX > x + 4 Then Return 0
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
        Function checkHitOnTop(protaX1 As Ubyte, protaY1 As Ubyte, enemyX0 As Ubyte, enemyY0 As Ubyte, enemyX1 As Ubyte, enemyY1 As Ubyte) As Ubyte
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
    
    Dim protaX1 As Ubyte = protaX + 2
    Dim protaY1 As Ubyte = protaY + 2
    
    Dim enemyX0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
    Dim enemyY0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
    Dim enemyX1 As Ubyte = enemyX0 + 2
    Dim enemyY1 As Ubyte = enemyY0 + 2

    Dim damage As Ubyte = 0
    
    If checkBulletProtaCollision(enemyX0, enemyY0, enemyX1, enemyY1, enemyId) Then Return 1

    #ifdef SIDE_VIEW
        #ifdef KILL_JUMPING_ON_TOP
            If checkHitOnTop(protaX1, protaY1, enemyX0, enemyY0, enemyX1, enemyY1) Then Return 1
        #endif
    #endif
    
    If protaX1 < enemyX0 Then Return 0
    If protaX > enemyX1 Then Return 0
    If protaY1 < enemyY0 Then Return 0
    If protaY > enemyY1 Then Return 0
    
    decrementLife()
    
    Return 0
End Function

Sub saveAndDraw(enemyId as Ubyte, tile As Ubyte, horizontalDirection As Ubyte = 0, verticalDirection As Ubyte = 0)
    Draw2x2Sprite(tile, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
    saveSprite(enemyId, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), tile + 1, horizontalDirection)
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

Sub moveEnemies()    
    For enemyId=0 To enemiesPerScreen(currentScreen) - 1
        Dim tile As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
        Dim enemyAlive As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_ALIVE)
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

        If tile = 0 Then continue For
        
        #ifdef ENEMIES_NOT_RESPAWN_ENABLED
            If tile > 15 Then
                If enemyAlive < 99 Then
                    If screensWon(currentScreen) Then continue For
                End If
            End If
        #endif
        
        If enemyAlive <= 0 Then continue For

        If Not firstTimeMoveEnemyOnRoom Then
            If enemySpeed = 0 Then
                If (framec bAnd 15) <> 0 Then
                    checkAndDraw(enemyId, tile, enemyCol, enemyLin)
                    continue For
                End If
            Elseif enemySpeed = 1 Then
                If (framec bAnd 1) = 0 Then
                    checkAndDraw(enemyId, tile, enemyCol, enemyLin)
                    continue For
                End If
            Elseif enemySpeed = 2 Then
                If (framec bAnd 3) = 0 Then
                    checkAndDraw(enemyId, tile, enemyCol, enemyLin)
                    continue For
                End If
            End If
        End If
        firstTimeMoveEnemyOnRoom = 0

        If enemyColIni = enemyColEnd Then enemyHorizontalDirection = 0
        If enemyLinIni = enemyLinEnd Then enemyVerticalDirection = 0

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
        
        If enemyBehaviour = 0 Then
            If enemyLinEnd = -1 Then
                enemyHorizontalDirection = Sgn(protaX - enemyCol)
                enemyVerticalDirection = Sgn(protaY - enemyLin)
            End If

            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol + enemyHorizontalDirection
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLin + enemyVerticalDirection
        Elseif enemyBehaviour = 1 Then
            If enemyCol = enemyColEnd Then
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyColIni
            Else
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol + enemyHorizontalDirection
                If enemyCol = enemyColIni Then
                    saveAndDraw(enemyId, tile + 17, enemyHorizontalDirection, enemyVerticalDirection)
                    continue For
                ElseIf enemyCol + enemyHorizontalDirection = enemyColEnd Then
                    saveAndDraw(enemyId, tile + 18, enemyHorizontalDirection, enemyVerticalDirection)
                    continue For
                End If
            End If
            
            If enemyLin = enemyLinEnd Then
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLinIni
            Else
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) + enemyVerticalDirection
                If enemyLin = enemyLinIni Then
                    saveAndDraw(enemyId, tile + 17, enemyHorizontalDirection, enemyVerticalDirection)
                    continue For
                ElseIf enemyLin + enemyVerticalDirection = enemyLinEnd Then
                    saveAndDraw(enemyId, tile + 18, enemyHorizontalDirection, enemyVerticalDirection)
                    continue For
                End If
            End If
        End If
        
        If tile < 16 Then
            #ifdef SIDE_VIEW
                If checkPlatformHasProtaOnTop(decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)) Then
                    jumpCurrentKey = jumpStopValue
                    If enemyVerticalDirection Then
                        protaY = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) - 4
                    End If
                    
                    If enemyHorizontalDirection Then
                        If Not CheckCollision(protaX + enemyHorizontalDirection, protaY) Then
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
                If enemyBehaviour = 0 Then
                    tile = tile + 16
                End If
            End If
        End If
        
        If enemFrame Then
            tile = tile + 1
        End If
        
        saveAndDraw(enemyId, tile + 1, enemyHorizontalDirection, enemyVerticalDirection)
    Next enemyId
End Sub