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

Function checkProtaCollision(enemyId As Ubyte) As Ubyte
    If invincible Then Return 0
    
    Dim protaX1 As Ubyte = protaX + 2
    Dim protaY1 As Ubyte = protaY + 2
    
    Dim enemyX0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
    Dim enemyY0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
    Dim enemyX1 As Ubyte = enemyX0 + 2
    Dim enemyY1 As Ubyte = enemyY0 + 2
    
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

Sub moveEnemies()
    Dim maxEnemiesCount As Ubyte = 0
    
    If enemiesPerScreen(currentScreen) > 0 Then maxEnemiesCount = enemiesPerScreen(currentScreen) - 1
    
    For enemyId=0 To maxEnemiesCount
        If decompressedEnemiesScreen(enemyId, ENEMY_TILE) = 0 Then continue For
        
        #ifdef ENEMIES_NOT_RESPAWN_ENABLED
            If decompressedEnemiesScreen(enemyId, ENEMY_TILE) > 15 Then
                If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) <> 99 Then
                    If screensWon(currentScreen) Then continue For
                End If
            End If
        #endif
        
        If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) <= 0 Then continue For

        Dim tile As Byte = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
        
        If Not firstTimeMoveEnemyOnRoom Then
            If decompressedEnemiesScreen(enemyId, ENEMY_SPEED) = 0 Then
                If (framec bAnd 15) <> 0 Then
                    Draw2x2Sprite(tile + 1, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
                    continue For
                End If
            Elseif decompressedEnemiesScreen(enemyId, ENEMY_SPEED) = 1 Then
                If (framec bAnd 1) = 0 Then
                    Draw2x2Sprite(tile + 1, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
                    continue For
                End If
            Elseif decompressedEnemiesScreen(enemyId, ENEMY_SPEED) = 2 Then
                If (framec bAnd 3) = 0 Then
                    Draw2x2Sprite(tile + 1, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
                    continue For
                End If
            End If
        End If
        firstTimeMoveEnemyOnRoom = 0
        
        Dim enemyCol As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
        Dim enemyLin As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
        Dim enemyColIni As Byte = decompressedEnemiesScreen(enemyId, ENEMY_COL_INI)
        Dim enemyLinIni As Byte = decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI)
        Dim enemyColEnd As Byte = decompressedEnemiesScreen(enemyId, ENEMY_COL_END)
        Dim enemyLinEnd As Byte = decompressedEnemiesScreen(enemyId, ENEMY_LIN_END)

        If enemyColIni = enemyColEnd Then decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 0
        If enemyLinIni = enemyLinEnd Then decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = 0

        If decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) Then
            If enemyColIni = enemyCol Or enemyColEnd = enemyCol Then
                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) * -1
            End If
        End If
        
        If decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) Then
            If enemyLinIni = enemyLin Or enemyLinEnd = enemyLin Then
                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) * -1
            End If
        End If
        
        If decompressedEnemiesScreen(enemyId, ENEMY_BEHAVIOUR) = 0 Then
            If enemyLinEnd = -1 Then
                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = Sgn(protaX - enemyCol)
                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = Sgn(protaY - enemyLin)
            End If

            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLin + decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)
        Elseif decompressedEnemiesScreen(enemyId, ENEMY_BEHAVIOUR) = 1 Then
            If enemyCol = enemyColEnd Then
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyColIni
            Else
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
                If enemyCol + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = enemyColEnd Then
                    tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 17
                    Draw2x2Sprite(tile, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
                    saveSprite(enemyId, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), tile + 1, decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION))
                    continue For
                End If
            End If
            
            If enemyLin = enemyLinEnd Then
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLinIni
            Else
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) + decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)
                If enemyLin + decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = enemyLinEnd Then
                    tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 17
                    Draw2x2Sprite(tile, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
                    saveSprite(enemyId, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), tile + 1, decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION))
                    continue For
                End If
            End If
        End If
        
        If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 Then
            #ifdef SIDE_VIEW
                If checkPlatformHasProtaOnTop(decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)) Then
                    jumpCurrentKey = jumpStopValue
                    If decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) Then
                        protaY = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) - 4
                    End If
                    
                    If decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) Then
                        If Not CheckCollision(protaX + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION), protaY) Then
                            protaX = protaX + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
                        End If
                    End If
                End If
                tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
            #endif
        Else
            If checkProtaCollision(enemyId) Then
                If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) <= 0 Then continue For
            End If
            
            If decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = -1 Then
                If decompressedEnemiesScreen(enemyId, ENEMY_BEHAVIOUR) = 0 Then
                    tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 16
                End If
            End If
        End If
        
        If enemFrame Then
            tile = tile + 1
        End If
        
        saveSprite(enemyId, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), tile + 1, decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION))
        Draw2x2Sprite(tile + 1, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
    Next enemyId
End Sub