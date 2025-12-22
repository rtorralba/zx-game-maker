Dim currentAnimatedTileKey As Ubyte = 0

Sub mapDraw()
    Dim index, base As Uinteger
    Dim y, x As Ubyte

    currentAnimatedTileKey = 0
    resetAnimatedTilesInScreen()
    
    x = 0
    y = 0
    base = arrayBasePtr(decompressedMap)

    For index=0 To SCREEN_LENGTH
        drawTile(Peek(base + index) - 1, x, y)
        
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

    Dim basePtr As Uinteger
    
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

    If tile > 73 Then
        If tile < 187 Then
            basePtr = arrayBasePtr(animatedTiles)
            For i = 0 To ANIMATED_TILES_COUNT
                If tile = Peek(basePtr + i) Then
                    animatedTilesInScreen(currentAnimatedTileKey, 0) = tile
                    animatedTilesInScreen(currentAnimatedTileKey, 1) = x
                    animatedTilesInScreen(currentAnimatedTileKey, 2) = y
                    currentAnimatedTileKey = currentAnimatedTileKey + 1
                    Exit For
                End If
            Next i
        End If
    End If
    
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
    
    Dim attr, besideTile As Ubyte

    If tile < LAST_PRINTABLE_TILE + 1 Then
        If tile = KEY_DOOR_TILE Then
            If not checkScreenObjectAlreadyTaken(tile, x, y) Then
                SetTileChecked(tile, attrSet(tile), x, y)
            End If
            Return
        Else
            #ifdef PLATFORM_MIMIC_ENABLED
                If tile > 63 And tile < 70 Then
                    Dim index As Uinteger
                    index = ((y + 1) * screenWidth) + x
                    besideTile = decompressedMap(index) - 1
                    attr = getAttrFromTileAndApplyToOther(tile, besideTile)
                    SetTile(tile, attr, x, y)
                Else
                    SetTile(tile, attrSet(tile), x, y)
                End If
            #else
                SetTile(tile, attrSet(tile), x, y)
            #endif
            Return
        End If
    End If

    besideTile = GetTile(x, y - 1)
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
                SetTile(0, attrSet(besideTile), x, y)
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
        #ifdef ARCADE_MODE_SPRITE_ID
            showKeySprite = 1
        #endif
    End Sub

    #ifdef ARCADE_MODE_RESET_ON_KILL
        Sub mapDrawOnlyItems()
            Dim index, basePtr As Uinteger
            Dim y, x, tile, attr, besideTile As Ubyte

            x = 0
            y = 0
            
            basePtr = arrayBasePtr(decompressedMap)
            For index=0 To SCREEN_LENGTH
                tile = Peek(basePtr + index) - 1

                If tile = ITEM_TILE Then
                    besideTile = GetTile(x - 1, y)
                    attr = getAttrFromTileAndApplyToOther(tile, besideTile)
                    SetTileChecked(tile, attr, x, y)
                End If

                If tile = BREAKABLE_BY_TOUCH_TILE Then
                    SetTileChecked(tile, attrSet(tile), x, y)
                End If
                
                x = x + 1
                If x = screenWidth Then
                    x = 0
                    y = y + 1
                End If
            Next index
        End Sub

        Sub clearKey()
            Dim besideTile As Ubyte
            besideTile = GetTile(currentScreenKeyX - 1, currentScreenKeyY)
            If besideTile <> 0 Then
                SetTile(besideTile, attrSet(besideTile), currentScreenKeyX, currentScreenKeyY)
            Else
                SetTile(0, BACKGROUND_ATTRIBUTE, currentScreenKeyX, currentScreenKeyY)
            End If
        End Sub
    #endif
#endif

Sub clearScreen()
    Asm
    call CLEAR_SCREEN
    End Asm
    FillWithTile(0, 32, 22, BACKGROUND_ATTRIBUTE, 0, 0)
    #ifdef MESSAGES_ENABLED
        clearMessage()
    #endif
End Sub

Sub redrawScreen()
    clearScreen()
    mapDraw()
    printHud()
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

    #ifdef ARCADE_MODE
        #ifdef ARCADE_MODE_SPRITE_ID
            showKeySprite = 0
        #endif
        #ifdef MUSIC_STAGE_CLEAR_ENABLED
            #ifdef HURRY_UP_SECONDS
                vortexTracker2x = 0
            #endif
            VortexTracker_Play(MUSIC_STAGE_CLEAR_ADDRESS)
            ' wait 4 seconds
            Dim startFrame As Ubyte = framec
            While framec - startFrame < 180: Wend
            VortexTracker_Stop()
        #endif
        #ifdef HISCORE_ENABLED
            #ifdef ARCADE_SHOW_INTERMEDIATE_SCREEN
                If direction = 6 Then
                    showIntermediateScreen()
                End If
            #else
                swapScreen()
            #endif
        #else
            swapScreen()
        #endif
    #else
        swapScreen()
    #endif

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
        #ifdef DASH_ENABLED
            If dashGhostActive Then
                Draw2x2Sprite(dashGhostTile, dashGhostX, dashGhostY)
            End If
        #endif
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
        #ifdef IDLE_ENABLED
            #ifdef SHOW_IDLE_MESSAGE
                If protaLoopCounter >= IDLE_TIME Then
                    If protaY >= 4 Then
                        If protaX >= 4 Then
                            Draw2x2Sprite(15, protaX + 4, protaY - 4)
                        Else
                            Draw2x2Sprite(15, protaX - 4, protaY - 4)
                        End If
                    End If
                End If
            #endif
        #endif
    End If
    
    #ifdef SWORD_ENABLED
        If swordTimer > 0 Then
            Dim swordX As Ubyte
            If swordDirection = 1 Then 
                swordX = protaX + 4
                If swordX >= 60 Then swordX = 60 ' Bound check if needed, though Draw1x1Sprite handles clipping usually
                Draw1x1Sprite(SWORD_SPRITE_RIGHT_ID, swordX, protaY + 1)
            Else 
                If protaX >= 2 Then swordX = protaX - 2 Else swordX = 0
                Draw1x1Sprite(SWORD_SPRITE_LEFT_ID, swordX, protaY + 1)
            End If
        End If
    #endif

    #ifdef SHOOTING_ENABLED
        If bulletPositionX <> 0 Then
            Draw1x1Sprite(currentBulletSpriteId, bulletPositionX, bulletPositionY)
        End If
    #endif
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