Sub mapDraw()
    Dim index As Uinteger
    Dim y, x As Ubyte
    
    x = 0
    y = 0
    
    For index=0 To SCREEN_LENGTH
        drawTile(Peek(@decompressedMap + index) - 1, x, y)
        
        x = x + 1
        If x = screenWidth Then
            x = 0
            y = y + 1
        End If
    Next index
End Sub

Sub drawTile(tile As Ubyte, x As Ubyte, y As Ubyte)
    If tile < 2 Then Return
    
    #ifdef SHOULD_KILL_ENEMIES_ENABLED
        If tile = ENEMY_DOOR_TILE Then
            If screensWon(currentScreen) Then
                SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
            Else
                SetTile(tile, attrSet(tile), x, y)
            End If
            Return
        End If
    #Else
        If tile = ENEMY_DOOR_TILE Then
            SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
            Return
        End If
    #endif
    
    #ifdef USE_BREAKABLE_TILE
        If tile = 62 Then
            If brokenTiles(currentScreen) Then
                SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
            Else
                SetTileChecked(tile, attrSet(tile), x, y)
            End If
            Return
        End If
    #endif
    
    If tile < 187 Then
        SetTile(tile, attrSet(tile), x, y)
        Return
    End If
    
    If tile = ITEM_TILE Then
        If screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) Then
            SetTileChecked(tile, attrSet(tile), x, y)
        End If
    Elseif tile = KEY_TILE
        #ifdef ARCADE_MODE
            currentScreenKeyX = x
            currentScreenKeyY = y
        #Else
            If screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) Then
                SetTileChecked(tile, attrSet(tile), x, y)
            End If
        #endif
        #ifdef KEYS_ENABLED
        Elseif tile = DOOR_TILE
            If screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX) Then
                SetTile(tile, attrSet(tile), x, y)
            End If
        #endif
    Elseif tile = LIFE_TILE
        If screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) Then
            SetTileChecked(tile, attrSet(tile), x, y)
        End If
    Elseif tile = AMMO_TILE
        If screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) Then
            SetTileChecked(tile, attrSet(tile), x, y)
        End If
    End If
End Sub

#ifdef ARCADE_MODE
    Sub drawKey()
        SetTile(KEY_TILE, attrSet(KEY_TILE), currentScreenKeyX, currentScreenKeyY)
    End Sub
#endif

Sub redrawScreen()
    ' memset(22527,0,768)
    ' CancelOps()
    ClearScreen(7, 0, 0) ' Modified For only cancelops And no clear Screen
    ' dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
    FillWithTile(0, 32, 22, BACKGROUND_ATTRIBUTE, 0, 0)
    ' clearBox(0,0,120,112)
    mapDraw()
    printLife()
    ' enemiesDraw(currentScreen)
End Sub

#ifdef KEYS_ENABLED
    Function checkTileIsDoor(col As Ubyte, lin As Ubyte) As Ubyte
        If GetTile(col, lin) = DOOR_TILE Then
            If currentKeys <> 0 Then
                currentKeys = currentKeys - 1
                printLife()
                screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX) = 0
                BeepFX_Play(4)
                removeTilesFromScreen(DOOR_TILE)
            Else
                #ifdef MESSAGES_ENABLED
                     printMessage("No keys ", "left!   ", 2, 0)
                #endif
            End If
            Return 1
        Else
            Return 0
        End If
    End Function
#endif

#ifdef KEYS_ENABLED
    Function CheckDoor(x As Ubyte, y As Ubyte) As Ubyte
        Dim xIsEven As Ubyte = (x bAnd 1) = 0
        Dim yIsEven As Ubyte = (y bAnd 1) = 0
        Dim col As Ubyte = x >> 1
        Dim lin As Ubyte = y >> 1
        
        If xIsEven And yIsEven Then
            Return checkTileIsDoor(col, lin) Or checkTileIsDoor(col + 1, lin) _
            Or checkTileIsDoor(col, lin + 1) Or checkTileIsDoor(col + 1, lin + 1)
        Elseif xIsEven And Not yIsEven Then
            Return checkTileIsDoor(col, lin) Or checkTileIsDoor(col + 1, lin) _
            Or checkTileIsDoor(col, lin + 1) Or checkTileIsDoor(col + 1, lin + 1) _
            Or checkTileIsDoor(col, lin + 2) Or checkTileIsDoor(col + 1, lin + 2)
        Elseif Not xIsEven And yIsEven Then
            Return checkTileIsDoor(col, lin) Or checkTileIsDoor(col + 1, lin) Or checkTileIsDoor(col + 2, lin) _
            Or checkTileIsDoor(col, lin + 1) Or checkTileIsDoor(col + 1, lin + 1) Or checkTileIsDoor(col + 2, lin + 1)
        Elseif Not xIsEven And Not yIsEven Then
            Return checkTileIsDoor(col, lin) Or checkTileIsDoor(col + 1, lin) Or checkTileIsDoor(col + 2, lin) _
            Or checkTileIsDoor(col, lin + 1) Or checkTileIsDoor(col + 1, lin + 1) Or checkTileIsDoor(col + 2, lin + 1) _
            Or checkTileIsDoor(col, lin + 2) Or checkTileIsDoor(col + 1, lin + 2) Or checkTileIsDoor(col + 2, lin + 2)
        End If
    End Function
#endif

Sub moveToScreen(direction As Ubyte)
    ' removeAllObjects()
    If direction = 6 Then
        saveSprite(PROTA_SPRITE, protaY, 0, getSpriteTile(PROTA_SPRITE), protaDirection)
        currentScreen = currentScreen + 1

        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = 0
            protaYRespawn = protaY
        #endif
    Elseif direction = 4 Then
        saveSprite(PROTA_SPRITE, protaY, 60, getSpriteTile(PROTA_SPRITE), protaDirection)
        currentScreen = currentScreen - 1

        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = 60
            protaYRespawn = protaY
        #endif
    Elseif direction = 2 Then
        saveSprite(PROTA_SPRITE, 0, protaX, getSpriteTile(PROTA_SPRITE), protaDirection)
        currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT

        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = protaX
            protaYRespawn = 0
        #endif
    Elseif direction = 8 Then
        saveSprite(PROTA_SPRITE, MAX_LINE, protaX, getSpriteTile(PROTA_SPRITE), protaDirection)
        #ifdef SIDE_VIEW
            jumpCurrentKey = 0
        #endif
        currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT

        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = protaX
            protaYRespawn = MAX_LINE
        #endif
    End If
    
    swapScreen()
    ' removeScreenObjectFromBuffer()
    redrawScreen()
End Sub

Sub drawSprites()
    If (protaY < 41) Then
        #ifdef LIVES_MODE_GRAVEYARD
            Draw2x2Sprite(getSpriteTile(PROTA_SPRITE), protaX, protaY)
        #else
            If Not invincible Or invincible bAnd 2 Then
                Draw2x2Sprite(getSpriteTile(PROTA_SPRITE), protaX, protaY)
            End If
        #endif
    End If

    If enemiesPerScreen(currentScreen) > 0 Then
        For i = 0 To enemiesPerScreen(currentScreen) - 1
            If Not getSpriteLin(i) Then continue For
            
            #ifdef ENEMIES_NOT_RESPAWN_ENABLED
                If decompressedEnemiesScreen(i, ENEMY_ALIVE) <> 99 And decompressedEnemiesScreen(i, ENEMY_TILE) > 15 Then
                    If screensWon(currentScreen) Then continue For
                End If
            #endif
            Draw2x2Sprite(getSpriteTile(i), getSpriteCol(i), getSpriteLin(i))
        Next i
    End If
    
    If bulletPositionX <> 0 Then
        Draw1x1Sprite(currentBulletSpriteId, bulletPositionX, bulletPositionY)
    End If
    
    RenderFrame()
End Sub

Sub animateEnemies()
    enemFrame = Not enemFrame
End Sub

Sub animateAnimatedTiles()
    For i=0 To MAX_ANIMATED_TILES_PER_SCREEN:
        If animatedTilesInScreen(currentScreen, i, 0) <> 0 Then
            Dim tile As Ubyte = animatedTilesInScreen(currentScreen, i, 0) + animatedFrame
            SetTile(tile, attrSet(tile), animatedTilesInScreen(currentScreen, i, 1), animatedTilesInScreen(currentScreen, i, 2))
        End If
    Next i
    animatedFrame = Not animatedFrame
End Sub