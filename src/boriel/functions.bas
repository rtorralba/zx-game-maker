sub pauseUntilPressKey()
    while INKEY$<>"":wend
    while INKEY$="":wend
end sub

sub decrementLife()
    if (currentLife = 0) then
        return
    end if
    
    #ifdef LIVES_MODE_ENABLED
        if currentLife > 1 then
            currentLife = currentLife - 1

            invincible = 1
            invincibleFrame = framec
            
            #ifdef LIVES_MODE_GRAVEYARD
                saveProta(protaY, protaX, 15, 0)
            #endif

            #ifdef LIVES_MODE_RESPAWN
                saveProta(protaYRespawn, protaXRespawn, 1, protaDirection)
            #endif

            #ifdef TIMER_ENABLED
                timerSeconds = initialTimerSeconds
                timerMinutes = initialTimerMinutes
                updateTimerDisplay()
            #endif
        else
            currentLife = 0
        end if
    #else
        if currentLife > DAMAGE_AMOUNT then
            currentLife = currentLife - DAMAGE_AMOUNT

            invincible = 1
            invincibleFrame = framec
        else
            currentLife = 0
        end if
    #endif
	printLife()
    BeepFX_Play(1)
end sub

sub printLife()
	PRINT AT HUD_LIFE_Y, HUD_LIFE_X; "   ";
	PRINT AT HUD_LIFE_Y, HUD_LIFE_X; currentLife;
    #ifdef JETPACK_FUEL
        PRINT AT HUD_JETPACK_FUEL_Y, HUD_JETPACK_FUEL_X; "   ";  
	    PRINT AT HUD_JETPACK_FUEL_Y, HUD_JETPACK_FUEL_X; jumpEnergy;
    #endif
    #ifdef AMMO_ENABLED
        PRINT AT HUD_AMMO_Y, HUD_AMMO_X; "   ";  
        PRINT AT HUD_AMMO_Y, HUD_AMMO_X; currentAmmo;
    #endif
    #ifndef ARCADE_MODE
        #ifdef KEYS_ENABLED
            PRINT AT HUD_KEYS_Y, HUD_KEYS_X; currentKeys;
        #endif
    #endif
    #ifdef HISCORE_ENABLED
        PRINT AT HUD_HISCORE_Y, HUD_HISCORE_X; hiScore;
	    PRINT AT HUD_HISCORE_Y_2, HUD_HISCORE_X; score;
    #endif
    #ifndef ARCADE_MODE
        #ifdef ITEMS_ENABLED
            PRINT AT HUD_ITEMS_Y, HUD_ITEMS_X; "  ";
            PRINT AT HUD_ITEMS_Y, HUD_ITEMS_X; currentItems;
        #endif
    #endif
end sub

#ifdef TIMER_ENABLED
    Sub updateTimerDisplay()
        PRINT AT HUD_TIMER_Y, HUD_TIMER_X; " :"
        PRINT AT HUD_TIMER_Y, HUD_TIMER_X; timerMinutes;
        If timerSeconds < 10 Then
            PRINT AT HUD_TIMER_Y, HUD_TIMER_X + 2; "0";
            PRINT AT HUD_TIMER_Y, HUD_TIMER_X + 3; timerSeconds;
        Else
            PRINT AT HUD_TIMER_Y, HUD_TIMER_X + 2; timerSeconds;
        End If
    End Sub
    Sub updateTimer()
        If framec - lastFrameTimer > 50 Then
            lastFrameTimer = framec

            If timerSeconds = 0 Then
                If timerMinutes = 0 Then
                    #ifdef LIVES_MODE_ENABLED
                        decrementLife()
                    #else
                        currentLife = 0
                    #endif
                Else
                    timerMinutes = timerMinutes - 1
                    timerSeconds = 59
                End If
            Else
                timerSeconds = timerSeconds - 1
            End If

            updateTimerDisplay()
        End If
    End Sub
#endif

#ifdef MESSAGES_ENABLED
    sub printMessage(line1 as string, line2 as string, p as ubyte, i as ubyte)
        Paper p: Ink i: Flash 1
        PRINT AT HUD_MESSAGE_Y, HUD_MESSAGE_X; line1
        PRINT AT HUD_MESSAGE_Y_2, HUD_MESSAGE_X; line2
        Paper 0: Ink 7: Flash 0
        messageLoopCounter = 0
    end sub

    sub checkMessageForDelete()
        If messageLoopCounter = MESSAGE_LOOPS_VISIBLE Then
            PRINT AT HUD_MESSAGE_Y, HUD_MESSAGE_X; "        "
            PRINT AT HUD_MESSAGE_Y_2, HUD_MESSAGE_X; "        "
        End If
        messageLoopCounter = messageLoopCounter + 1
    end sub
#endif

Sub isDamageTileByColLin(col as Ubyte, lin as Ubyte)
    Dim tile as Ubyte = GetTile(col, lin)

    For i = 0 to DAMAGE_TILES_COUNT
        if peek(@damageTiles + i) = tile then decrementLife()
    Next i
End Sub

function allEnemiesKilled() as ubyte
    if enemiesPerScreen(currentScreen) = 0 then return 1

    for enemyId=0 TO enemiesPerScreen(currentScreen) - 1
        if decompressedEnemiesScreen(enemyId, 0) < 16 then
            continue for
        end if
        if decompressedEnemiesScreen(enemyId, 8) <> 99 then  'is not invincible'
            if decompressedEnemiesScreen(enemyId, 8) > 0 then 'In the screen and still live
                return 0
            end if
        end if
    next enemyId

    return 1
end function

function isSolidTileByColLin(col as ubyte, lin as ubyte) as ubyte
	dim tile as ubyte = GetTile(col, lin)

    if tile > 63 then return 0
    if tile < 1 then return 0

    #ifdef MESSAGES_ENABLED
        If tile = ENEMY_DOOR_TILE Then
            printMessage(KILL_ALL_ENEMIES_LINE1, KILL_ALL_ENEMIES_LINE2, KILL_ALL_ENEMIES_INK, KILL_ALL_ENEMIES_PAPER)
        End If
    #endif

    #ifdef KEYS_ENABLED
        If tile = KEY_DOOR_TILE Then
            If currentKeys <> 0 Then
                currentKeys = currentKeys - 1
                printLife()
                BeepFX_Play(4)
                removeTilesFromScreen(KEY_DOOR_TILE)
            Else
                #ifdef MESSAGES_ENABLED
                    printMessage(NO_KEYS_LINE1, NO_KEYS_LINE2, NO_KEYS_INK, NO_KEYS_PAPER)
                #endif
            End If
        End If
    #endif

    if tile = ITEMS_DOOR_TILE then
        #ifdef MESSAGES_ENABLED
            printMessage(NEED_ITEMS_LINE1, NEED_ITEMS_LINE2, NEED_ITEMS_INK, NEED_ITEMS_PAPER)
        #endif
    end if

    #ifdef USE_BREAKABLE_TILE_BY_TOUCH
        If tile = BREAKABLE_BY_TOUCH_TILE Then
            If lastFrameOnBreakableTiles = 0 Then
                lastFrameOnBreakableTiles = framec
            End If
        End If
    #endif

	return tile
end function

#ifdef ARCADE_MODE
    sub countItemsOnTheScreen()
        dim index, y, x as integer

        x = 0
        y = 0

        itemsToFind = 0
        currentItems = 0
        for index=0 to SCREEN_LENGTH
            if peek(@decompressedMap + index) - 1 = ITEM_TILE then
                itemsToFind = itemsToFind + 1
            end if

            x = x + 1
            if x = screenWidth then
                x = 0
                y = y + 1
            end if
        next index
    end sub
#endif

#ifdef SIDE_VIEW
    Function checkTravesablePlatformFromTop(x as uByte, y as uByte) as uByte
        Dim tile as Ubyte = GetTile(x >> 1, y >> 1)

        If tile < 64 Then Return 0
        If tile > 65 Then Return 0

        Return 1
    End Function

    function checkTravesablePlatform(x as uByte, y as uByte) as uByte
        Dim tile as Ubyte = GetTile(x >> 1, y >> 1)

        If tile < 64 Then Return 0
        If tile > 69 Then Return 0

        Return 1
    end function

    Function checkTravesablePlatformFromTopAndAll(x as uByte, y as uByte) as uByte
        Dim tile as Ubyte = GetTile(x >> 1, y >> 1)

        If tile < 64 Then Return 0
        If tile > 67 Then Return 0

        Return 1
    End Function
    #ifdef LADDERS_ENABLED
        Function isLadder(col as uByte, lin as uByte) as uByte
            Dim tile as Ubyte = GetTile(col, lin)

            If tile < 70 Then Return 0
            If tile > 73 Then Return 0

            Return 1
        End Function
    #endif
#endif

'type 0 Damage, 1 Solid, 2 Ladder
Function checkTypeOfTile(col as uByte, lin as uByte, type as Ubyte) as uByte
    If type = 1 Then
        Return isSolidTileByColLin(col, lin)
    End If
    If type = 0 Then
        isDamageTileByColLin(col, lin)
        Return 0
    End If
    #ifdef LADDERS_ENABLED
        If type = 2 Then
            Return isLadder(col, lin)
        End If
    #endif
    Return 0
End Function

'type 0 Damage, 1 Solid, 2 Ladder
Function CheckCollision(x as Ubyte, y as Ubyte, type as Ubyte) as Ubyte
    Dim xIsEven as Ubyte = (x bAnd 1) = 0
    Dim yIsEven as Ubyte = (y bAnd 1) = 0
    Dim col as Ubyte = x >> 1
    Dim lin as Ubyte = y >> 1

    if checkTypeOfTile(col, lin, type) then return 1
    if checkTypeOfTile(col + 1, lin, type) then return 1
    if checkTypeOfTile(col, lin + 1, type) then return 1
    if checkTypeOfTile(col + 1, lin + 1, type) then return 1

    if not yIsEven then
        if checkTypeOfTile(col, lin + 2, type) then return 1
        if checkTypeOfTile(col + 1, lin + 2, type) then return 1
    end if

    if not xIsEven then
        if checkTypeOfTile(col + 2, lin, type) then return 1
        if checkTypeOfTile(col + 2, lin + 1, type) then return 1
    end if

    if not xIsEven and not yIsEven then
		if checkTypeOfTile(col + 2, lin + 2, type) then return 1
    end if

	return 0
End Function

sub removeTilesFromScreen(tile as ubyte)
	dim index as uinteger
    dim y, x as ubyte

	x = 0
	y = 0
	
	for index=0 to SCREEN_LENGTH
		if peek(@decompressedMap + index) - 1 = tile then
			SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
            #ifndef ARCADE_MODE
                If tile = KEY_DOOR_TILE Then
                    addScreenObject(KEY_DOOR_TILE, x, y)
                End If
            #endif
		end if

		x = x + 1
		if x = screenWidth then
			x = 0
			y = y + 1
		end if
	next index
end sub

#ifdef SIDE_VIEW
	sub jump()
        #ifdef SIDE_VIEW
            #ifdef DISABLE_CONTINUOUS_JUMP
                If Not noKeyPressedForJump Then Return
                noKeyPressedForJump = 0
            #endif
        #endif
        if jumpCurrentKey = jumpStopValue and landed then
            landed = 0
            jumpCurrentKey = 0
        end if
    end sub
#endif

sub saveProta(lin as ubyte, col as ubyte, tile as ubyte, directionRight as ubyte)
    protaX = col
    protaY = lin
    protaTile = tile
    protaDirection = directionRight
end sub

#ifndef ARCADE_MODE
Sub addScreenObject(tile As Ubyte, col As Ubyte, lin As Ubyte)
    If screenObjectsCurrentIndex >= SCREEN_OBJECTS_COUNT Then Return
    
    screenObjects(screenObjectsCurrentIndex, 0) = currentScreen
    screenObjects(screenObjectsCurrentIndex, 1) = tile
    screenObjects(screenObjectsCurrentIndex, 2) = col
    screenObjects(screenObjectsCurrentIndex, 3) = lin
    
    screenObjectsCurrentIndex = screenObjectsCurrentIndex + 1
End Sub
#endif

Function getAttrFromTileAndApplyToOther(tile As Ubyte, besideTile As Ubyte) As Ubyte
    Dim attr As Ubyte
    Dim tinta As Ubyte
    Dim papel As Ubyte
    Dim brillo As Ubyte
    Dim parpadeo As Ubyte

    attr = attrSet(tile)
    tinta = attr bAnd 7
    parpadeo = (attr bAnd 128) / 128

    attr = attrSet(besideTile)
    papel = (attr bAnd 56) / 8
    brillo = (attr bAnd 64) / 64

    ' Montar el atributo: papel, tinta, brillo, parpadeo
    Return (papel * 8) + tinta + (brillo * 64) + (parpadeo * 128)
End Function

sub debugA(value as UBYTE)
    PRINT AT 0, 0; "----"
    PRINT AT 0, 0; value
end sub

sub debugB(value as UBYTE)
    PRINT AT 0, 5; "  "
    PRINT AT 0, 5; value
end sub

sub debugC(value as UBYTE)
    PRINT AT 0, 10; "  "
    PRINT AT 0, 10; value
end sub

sub debugD(value as UBYTE)
    PRINT AT 0, 15; "  "
    PRINT AT 0, 15; value
end sub