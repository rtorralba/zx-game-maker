#ifdef SIDE_VIEW
    Function checkPlatformHasProtaOnTop(x As Ubyte, y As Ubyte) As Ubyte
        Dim protaX1 As Ubyte = protaX + 2
        
        If protaX1 < x Then Return 0
        If protaX > x + 4 Then Return 0
        If protaY <> y - 4 Then Return 0
        
        Return 1
    End Function
#endif

Sub moveEnemies()
    Dim maxEnemiesCount As Ubyte = 0
    
    If enemiesPerScreen(currentScreen) > 0 Then maxEnemiesCount = enemiesPerScreen(currentScreen) - 1
    For enemyId=0 To maxEnemiesCount
        If decompressedEnemiesScreen(enemyId, ENEMY_TILE) = 0 Then
            continue For
        End If
        #ifdef ENEMIES_NOT_RESPAWN_ENABLED
            If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) <> 99 And decompressedEnemiesScreen(enemyId, ENEMY_TILE) > 15 Then
                If screensWon(currentScreen) Then continue For
            End If
        #endif
        
        ' If In the Screen And still live
        If decompressedEnemiesScreen(enemyId, ENEMY_ALIVE) > 0 Then
            If decompressedEnemiesScreen(enemyId, ENEMY_SPEED) = 1 Then
                If (framec bAnd 1) = 0 Then continue For
            ElseIf decompressedEnemiesScreen(enemyId, ENEMY_SPEED) = 2 Then
                If (framec bAnd 3) = 0 Then continue For
            End If
            
            Dim tile As Byte
            Dim enemyCol As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
            Dim enemyLin As Byte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
            
            tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
            
            If decompressedEnemiesScreen(enemyId, ENEMY_COL_INI) = decompressedEnemiesScreen(enemyId, ENEMY_COL_END) Then decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 0
            If decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) = decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) Then decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = 0
            
            #ifdef ENEMIES_ADVANCED_ENABLED
                If decompressedEnemiesScreen(enemyId, ENEMY_COL_END) > decompressedEnemiesScreen(enemyId, ENEMY_COL_INI) And decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) <> decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) Then
                    If decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) > decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) Then
                        ' clockwise
                        If decompressedEnemiesScreen(enemyId, ENEMY_COL_END) = enemyCol Then
                            If decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) = enemyLin Then
                                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = 1
                                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 0
                            ElseIf decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) = enemyLin Then
                                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = 0
                                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = -1
                            End If
                        ElseIf decompressedEnemiesScreen(enemyId, ENEMY_COL_INI) = enemyCol Then
                            If decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) = enemyLin Then
                                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = -1
                                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 0
                            ElseIf decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) = enemyLin Then
                                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = 0
                                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 1
                            End If
                        End If
                    ElseIf decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) > decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) Then
                        ' reverse clockwise
                        If decompressedEnemiesScreen(enemyId, ENEMY_COL_END) = enemyCol Then
                            If decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) = enemyLin Then
                                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = -1
                                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 0
                            ElseIf decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) = enemyLin Then
                                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = 0
                                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = -1
                            End If
                        ElseIf decompressedEnemiesScreen(enemyId, ENEMY_COL_INI) = enemyCol Then
                            If decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) = enemyLin Then
                                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = 1
                                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 0
                            ElseIf decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) = enemyLin Then
                                decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = 0
                                decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 1
                            End If
                        End If
                    End If
                Else
                #endif
                ' movimiento aleatorio
                If decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) Then
                    If decompressedEnemiesScreen(enemyId, ENEMY_COL_INI) = enemyCol Or decompressedEnemiesScreen(enemyId, ENEMY_COL_END) = enemyCol Then
                        decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) * -1
                    End If
                End If
                
                #ifdef ENEMIES_ADVANCED_ENABLED
                    If decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) Then
                        If decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) = enemyLin Or decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) = enemyLin Then
                            decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) * -1
                        End If
                    End If
                End If
            #endif
            
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
            
            ' If is a platform Not an enemy, only 2 frames, 1 direction
            If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 Then
                #ifdef SIDE_VIEW
                    If checkPlatformHasProtaOnTop(decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)) Then
                        If decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) Then
                            spritesLinColTileAndFrame(PROTA_SPRITE, 1) = protaY + decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)
                            protaY = spritesLinColTileAndFrame(PROTA_SPRITE, 1)
                        End If
                        
                        If decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = -1 Then
                            If Not CheckCollision(protaX - 1, protaY) Then
                                spritesLinColTileAndFrame(PROTA_SPRITE, 1) = protaX + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
                                protaX = spritesLinColTileAndFrame(PROTA_SPRITE, 1)
                            End If
                        ElseIf decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 1 Then
                            If Not CheckCollision(protaX + 1, protaY) Then
                                spritesLinColTileAndFrame(PROTA_SPRITE, 1) = protaX + decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION)
                                protaX = spritesLinColTileAndFrame(PROTA_SPRITE, 1)
                            End If
                        End If
                    End If
                    tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
                #endif
            Elseif decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = 1 Then
                tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE)
            Elseif decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = -1 Then
                tile = decompressedEnemiesScreen(enemyId, ENEMY_TILE) + 16
            End If
            
            ' Movimiento vertical
            ' #ifndef ENEMIES_ADVANCED_ENABLED
            '     If decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) Then
            '         If decompressedEnemiesScreen(enemyId, ENEMY_LIN_INI) = enemyLin Or decompressedEnemiesScreen(enemyId, ENEMY_LIN_END) = enemyLin Then
            '             decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) * -1
            '         End If
            '     End If
            ' #endif
            
            decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) + decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION)
            
            ' If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16
            '     saveSpriteLin(PROTA_SPRITE, protaY + decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION))
            ' End If
            
            If enemFrame Then
                tile = tile + 1
            End If
            
            saveSprite(enemyId, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), tile + 1, decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION))
            
            If decompressedEnemiesScreen(enemyId, ENEMY_TILE) > 15 Then
                checkProtaCollision(enemyId)
            End If
        End If
    Next enemyId
End Sub

Sub checkProtaCollision(enemyId As Ubyte)
    If invincible = 1 Then Return
    
    Dim protaX1 As Ubyte = protaX + 2
    Dim protaY1 As Ubyte = protaY + 2
    
    Dim enemyX0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
    Dim enemyY0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
    Dim enemyX1 As Ubyte = enemyX0 + 2
    Dim enemyY1 As Ubyte = enemyY0 + 2
    
    #ifdef SIDE_VIEW
        #ifdef KILL_JUMPING_ON_TOP
            If Not landed Then
                If (protaY1 + 2) = enemyY0 Then
                    If protaX >= (enemyX0-1) And protaX <= (enemyX1+1) Then
                        damageEnemy(enemyId)
                        landed = 1
                        jump()
                        Return
                    End If
                End If
            End If
        #endif
    #endif
    
    If protaX1 < enemyX0 Then Return
    If protaX > enemyX1 Then Return
    If protaY1 < enemyY0 Then Return
    If protaY > enemyY1 Then Return
    
    invincible = 1
    invincibleFrame = framec
    decrementLife()
    BeepFX_Play(1)
    
End Sub

#ifdef SIDE_VIEW
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
#endif