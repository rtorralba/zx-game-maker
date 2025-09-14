Dim currentAnimatedTileKey As Ubyte = 0

Sub mapDraw()
    Dim index As Uinteger
    Dim y, x As Ubyte

    currentAnimatedTileKey = 0
    resetAnimatedTilesInScreen()
    
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

Function checkScreenObjectAlreadyTaken(tile As Ubyte, x As Ubyte, y As Ubyte) As Ubyte
    For i = 0 To SCREEN_OBJECTS_COUNT - 1
        If screenObjects(i, 0) <> currentScreen Then Continue For
        If screenObjects(i, 1) <> tile Then Continue For
        If screenObjects(i, 2) <> x Then Continue For
        If screenObjects(i, 3) <> y Then Continue For
        
        Return 1 ' Object already taken
    Next i
    
    Return 0 ' Object not taken
End Function

Sub resetAnimatedTilesInScreen()
    For i=0 To MAX_ANIMATED_TILES_PER_SCREEN:
        animatedTilesInScreen(i, 0) = 0
        animatedTilesInScreen(i, 1) = 0
        animatedTilesInScreen(i, 2) = 0
    Next i
End Sub

Sub drawTile(tile As Ubyte, x As Ubyte, y As Ubyte)
    If tile < 1 Then Return
    
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

    For i = 0 To ANIMATED_TILES_COUNT
        If tile = animatedTiles(i) Then
            animatedTilesInScreen(currentAnimatedTileKey, 0) = tile
            animatedTilesInScreen(currentAnimatedTileKey, 1) = x
            animatedTilesInScreen(currentAnimatedTileKey, 2) = y
            currentAnimatedTileKey = currentAnimatedTileKey + 1
            Exit For
        End If
    Next i
    
    #ifdef USE_BREAKABLE_TILE_ALL
        If tile = BREAKABLE_BY_BULLET_TILE Then
            If brokenTiles(currentScreen) Then
                SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
            Else
                SetTileChecked(tile, attrSet(tile), x, y)
            End If
            Return
        End If
    #endif
    
    #ifdef USE_BREAKABLE_TILE_INDIVIDUAL
        If tile = BREAKABLE_BY_BULLET_TILE Then
            For i = 0 To BREAKABLE_TILES_COUNT
                If brokenTiles(i, 0) <> currentScreen Then Continue For
                If brokenTiles(i, 1) <> x Then Continue For
                If brokenTiles(i, 2) <> y Then Continue For

                SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
                Return
            Next i
            SetTileChecked(tile, attrSet(tile), x, y)
            Return
        End If
    #endif

    If tile = ITEMS_DOOR_TILE Then
        If currentItems = ITEMS_TO_OPEN_DOORS Then
            SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
        Else
            SetTile(tile, attrSet(tile), x, y)
        End If
        Return
    End If
    
    If tile < 187 Then
        If tile = KEY_DOOR_TILE Then
            If not checkScreenObjectAlreadyTaken(tile, x, y) Then
                SetTileChecked(tile, attrSet(tile), x, y)
            End If
            Return
        Else
            SetTile(tile, attrSet(tile), x, y)
            Return
        End If
    End If

    Dim attr As Ubyte
    Dim besideTile As Ubyte
    besideTile = GetTile(x - 1, y)
    attr = getAttrFromTileAndApplyToOther(tile, besideTile)

    #ifdef ARCADE_MODE
        If tile = KEY_TILE Then
            currentScreenKeyX = x
            currentScreenKeyY = y
            SetTileChecked(besideTile, attrSet(besideTile), x, y)
        Else
            If Not checkScreenObjectAlreadyTaken(tile, x, y) Then
                SetTileChecked(tile, attr, x, y)
            Else
                if besideTile <> 0 Then
                    SetTile(besideTile, attrSet(besideTile), x, y)
                End If
            End If
        End If
    #else
        If Not checkScreenObjectAlreadyTaken(tile, x, y) Then
            SetTileChecked(tile, attr, x, y)
        Else
            if besideTile <> 0 Then
                SetTile(besideTile, attrSet(besideTile), x, y)
            End If
        End If
    #endif
End Sub

#ifdef ARCADE_MODE
    Sub drawKey()
        Dim attr As Ubyte
        Dim besideTile As Ubyte
        besideTile = GetTile(currentScreenKeyX - 1, currentScreenKeyY)
        attr = getAttrFromTileAndApplyToOther(KEY_TILE, besideTile)
        SetTile(KEY_TILE, attr, currentScreenKeyX, currentScreenKeyY)
    End Sub
#endif

Sub redrawScreen()
    ' memset(22527,0,768)
    ' CancelOps()
    asm
    call CLEAR_SCREEN
    end asm
    ' dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
    FillWithTile(0, 32, 22, BACKGROUND_ATTRIBUTE, 0, 0)
    ' clearBox(0,0,120,112)
    mapDraw()
    printLife()
    ' enemiesDraw(currentScreen)
End Sub

Sub moveToScreen(direction As Ubyte)
    If direction = 6 Then
        currentScreen = currentScreen + 1
        protaX = 0
        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = 0
            protaYRespawn = protaY
        #endif
    Elseif direction = 4 Then
        currentScreen = currentScreen - 1
        protaX = 60
        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = 60
            protaYRespawn = protaY
        #endif
    Elseif direction = 2 Then
        currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
        protaY = 0
        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = protaX
            protaYRespawn = 0
        #endif
    Elseif direction = 8 Then
        currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT
        protaY = MAX_LINE
        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = protaX
            protaYRespawn = MAX_LINE
        #endif
    End If

    swapScreen()

    If direction = 8 Then
        #ifdef SIDE_VIEW
            #ifdef LADDERS_ENABLED
                If CheckCollision(protaX, protaY, 2) Then Return
            #endif
            jumpCurrentKey = 0
        #endif
    End If
End Sub

Sub drawSprites()
    If (protaY < 41) Then
        #ifdef LADDERS_ENABLED
            If CheckCollision(protaX, protaY, 2) Then
                If protaTile < 11 Then
                    protaTile = 11
                End If
            End If
        #endif
        #ifdef LIVES_MODE_GRAVEYARD
            Draw2x2Sprite(protaTile, protaX, protaY)
        #else
            If Not invincible Then
                Draw2x2Sprite(protaTile, protaX, protaY)
            Else
                If invincibleBlink Then
                    invincibleBlink = Not invincibleBlink
                    Draw2x2Sprite(protaTile, protaX, protaY)
                Else
                    invincibleBlink = Not invincibleBlink
                End If
            End If
        #endif
    End If
    
    If bulletPositionX <> 0 Then
        Draw1x1Sprite(currentBulletSpriteId, bulletPositionX, bulletPositionY)
    End If
End Sub

Sub animateEnemies()
    enemFrame = Not enemFrame
End Sub

Sub animateAnimatedTiles()
    For i=0 To MAX_ANIMATED_TILES_PER_SCREEN:
        If animatedTilesInScreen(i, 0) <> 0 Then
            Dim tile As Ubyte = animatedTilesInScreen(i, 0) + animatedFrame
            SetTileAnimated(tile, attrSet(tile), animatedTilesInScreen(i, 1), animatedTilesInScreen(i, 2))
        End If
    Next i
    animatedFrame = Not animatedFrame
End Sub