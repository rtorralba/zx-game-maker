#ifdef SIDE_VIEW
    Function checkPlatformHasProtaOnTop(x As Ubyte, y As Ubyte) As Ubyte
        If (protaX + 2) < x Then Return 0
        If protaX > x + 4 Then Return 0
        If protaY <> y - 4 Then Return 0
        
        Return 1
    End Function
#endif

Sub moveEnemies()
    If enemiesPerScreen(currentScreen) > 0 Then        
        For enemyId=0 To enemiesPerScreen(currentScreen) - 1
            Dim tile As Byte = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
            Dim enemyLive As Byte = decompressedEnemiesScreen(enemyId, ENEMY_ALIVE)
            
            If tile = 0 Then continue For
            #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                If enemyLive <> 99 And tile > 15 Then
                    If screensWon(currentScreen) Then continue For
                End If
            #endif
            
            'In the Screen And still live
            If enemyLive > 0 Then
                Dim enemySpeed As Byte = decompressedEnemiesScreen(enemyId, ENEMY_SPEED)
                Dim horizontalDirection As Byte = decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
                Dim enemyCol As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
                Dim enemyLin As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
                
                If enemySpeed = 1 Then
                    If (framec bAnd 1) = 0 Then continue For
                ElseIf enemySpeed = 2 Then
                    If (framec bAnd 2) = 0 Then continue For
                End If
                
                Dim enemyMode As Byte = decompressedEnemiesScreen(enemyId, ENEMY_MODE)
                Dim enemyColIni As Byte = decompressedEnemiesScreen(enemyId, ENEMY_COL_INI)
                Dim enemyLinIni As Byte = decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI)
                Dim enemyColEnd As Byte = decompressedEnemiesScreen(enemyId, ENEMY_COL_END)
                Dim enemyLinEnd As Byte = decompressedEnemiesScreen(enemyId, ENEMY_LIN_END)
                Dim verticalDirection As Byte = decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)
                
                if enemyMode < 2 Then
                    If horizontalDirection Then
                        If enemyColIni = enemyCol Or enemyColEnd = enemyCol Then
                            horizontalDirection = horizontalDirection * -1
                        End If
                    End If
                    
                    If verticalDirection Then
                        If enemyLinIni = enemyLin Or enemyLinEnd = enemyLin Then
                            verticalDirection = verticalDirection * -1
                        End If
                    End If
                    
                    #ifdef ENEMIES_ALERT_ENABLED
                        If Not invincible And enemyMode = 1 Then
                            If Abs(protaX - enemyCol) < ENEMIES_ALERT_DISTANCE And Abs(protaY - enemyLin) < (ENEMIES_ALERT_DISTANCE * 2) Then
                                enemyMode = 3
                            End if
                        End if
                    #endif
                    #ifdef ENEMIES_PURSUIT_ENABLED
                    ElseIf enemyMode < 4 Then
                        horizontalDirection = 0
                        verticalDirection = 0
                        if invincible Then
                            enemyCol = enemyColIni
                            enemyLin = enemyLinIni
                            
                            #ifdef ENEMIES_ALERT_ENABLED
                                if enemyMode = 3 Then enemyMode = 1
                            #endif
                        Else
                            If protaX <> enemyCol Then
                                If protaX > enemyCol Then horizontalDirection = 1 Else horizontalDirection = -1
                                
                                #ifdef OVERHEAD_VIEW
                                    if CheckCollision(enemyCol + horizontalDirection, enemyLin) Then horizontalDirection = 0
                                #endif
                            End If
                            
                            If protaY <> enemyLin Then
                                If protaY > enemyLin Then verticalDirection = 1 Else verticalDirection = -1
                                
                                #ifdef OVERHEAD_VIEW
                                    if CheckCollision(enemyCol, enemyLin + verticalDirection) Then verticalDirection = 0
                                #endif
                            End If
                        End if
                    #endif
                    #ifdef ENEMIES_ONE_DIRECTION_ENABLED
                    ElseIf enemyMode = 4 Then
                        If enemyColEnd = enemyCol And enemyLinEnd = enemyLin Then
                            enemyCol = enemyColIni
                            enemyLin = enemyLinIni
                        End If
                    #endif
                    #ifdef ENEMIES_ANTICLOCKWISE_ENABLED
                    ElseIf enemyMode = 5 Then
                        If enemyColIni = enemyCol Then
                            If enemyLinIni = enemyLin Then
                                ' Esquina sup iz
                                verticalDirection = 1
                                horizontalDirection = 0
                            Elseif enemyLinEnd = enemyLin Then
                                ' Esquina inf iz
                                horizontalDirection = 1
                                verticalDirection = 0
                            End If
                        Elseif enemyColEnd = enemyCol Then
                            If enemyLinEnd = enemyLin Then
                                ' Esquina inf der
                                verticalDirection = -1
                                horizontalDirection = 0
                            Elseif enemyLinIni = enemyLin Then
                                ' Esquina sup der
                                horizontalDirection = -1
                                verticalDirection = 0
                            End If
                        End if
                    #endif
                    #ifdef ENEMIES_CLOCKWISE_ENABLED
                    Elseif enemyMode = 6 Then
                        If enemyColIni = enemyCol Then
                            If enemyLinIni = enemyLin Then
                                ' Esquina sup iz
                                verticalDirection = 0
                                horizontalDirection = 1
                            Elseif enemyLinEnd = enemyLin Then
                                ' Esquina inf iz
                                horizontalDirection = 0
                                verticalDirection = -1
                            End If
                        Elseif enemyColEnd = enemyCol Then
                            If enemyLinEnd = enemyLin Then
                                ' Esquina inf der
                                verticalDirection = 0
                                horizontalDirection = -1
                            Elseif enemyLinIni = enemyLin Then
                                ' Esquina sup der
                                horizontalDirection = 0
                                verticalDirection = 1
                            End If
                        End if
                    #endif
                End if
                
                enemyCol = enemyCol + horizontalDirection
                
                ' Is a platform Not an enemy, only 2 frames, 1 direction
                If tile < 16 Then
                    #ifdef SIDE_VIEW
                        If checkPlatformHasProtaOnTop(enemyCol, enemyLin) Then
                            jumpCurrentKey = jumpStopValue
                            If verticalDirection Then
                                spritesLinColTileAndFrame(PROTA_SPRITE, 1) = protaY + verticalDirection
                                protaY = spritesLinColTileAndFrame(PROTA_SPRITE, 1)
                                
                                ' If protaY < 2 Then moveScreen = 8
                            End If
                            
                            If horizontalDirection Then
                                If Not CheckCollision(protaX + horizontalDirection, protaY) Then
                                    spritesLinColTileAndFrame(PROTA_SPRITE, 1) = protaX + horizontalDirection
                                    protaX = spritesLinColTileAndFrame(PROTA_SPRITE, 1)
                                End If
                            End If
                        End If
                    #endif
                Elseif horizontalDirection = -1 Then
                    tile = tile + 16
                End If
                
                enemyLin = enemyLin + verticalDirection
                
                If enemFrame Then
                    tile = tile + 1
                End If
                
                ' se guarda el estado final del enemigo
                if enemyMode <> 2 And enemyMode <> 3 Then
                    decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = horizontalDirection
                    decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = verticalDirection
                End if
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol
                decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLin
                decompressedEnemiesScreen(enemyId, ENEMY_MODE) = enemyMode
                
                ' se actualiza el sprite
                saveSprite(enemyId, enemyLin, enemyCol, tile + 1, horizontalDirection)
            End If
        Next enemyId
        
        'checkEnemiesCollection()
        For enemyId=0 To enemiesPerScreen(currentScreen) - 1
            If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 Then continue For
            If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) = 0 Then continue For
            #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) <> 99 Then
                    If screensWon(currentScreen) Then continue For
                End If
            #endif
            
            checkProtaCollision(enemyId)
        Next enemyId
    End if
End Sub


Sub checkProtaCollision(enemyId As Ubyte)
    If invincible Then Return
    
    Dim protaY1 As Ubyte = protaY + 2
    Dim enemyX0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
    Dim enemyY0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
    Dim enemyX1 As Ubyte = enemyX0 + 2
    
    #ifdef SIDE_VIEW
        #ifdef KILL_JUMPING_ON_TOP
            If Not landed Then
                If (protaY1 + 2) = enemyY0 Then
                    If protaX >= (enemyX0-1) And protaX <= (enemyX1+3) Then
                        damageEnemy(enemyId)
                        landed = 1
                        jumpCurrentKey = jumpStopValue
                        jump()
                        Return
                    End If
                End If
            End If
        #endif
    #endif
    
    If (protaX + 2) < enemyX0 Then Return
    If protaX > enemyX1 Then Return
    If protaY1 < enemyY0 Then Return
    If protaY > (enemyY0 + 2) Then Return
    
    decrementLife()
End Sub

#ifdef SIDE_VIEW
    Function checkPlatformByXY(x As Ubyte, y As Ubyte) As Ubyte
        If enemiesPerScreen(currentScreen) = 0 Then Return 0
        
        For enemyId=0 To enemiesPerScreen(currentScreen) - 1
            If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 Then
                Dim enemyCol As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
                 
                If x < enemyCol - 2 Or x > enemyCol + 4 Or y <> decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) Then continue For
                
                Return 1
            End If
        Next enemyId
        
        Return 0
    End Function
#endif