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
                saveSprite(PROTA_SPRITE, protaY, protaX, 15, 0)
            #endif

            #ifdef LIVES_MODE_RESPAWN
                saveSprite(PROTA_SPRITE, protaYRespawn, protaXRespawn, 1, protaDirection)
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

function isADamageTile(tile as ubyte) as UBYTE
    for i = 0 to DAMAGE_TILES_COUNT
        if peek(@damageTiles + i) = tile then
            return 1
        end if
    next i
	return 0
end function

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

    #ifdef MESSAGES_ENABLED
        If tile = ENEMY_DOOR_TILE Then
            printMessage("Kill All", "Enemies!", 2, 0)
        End If
    #endif

    if tile > 64 then return 0
    if tile < 1 then return 0

	return 1
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
    function CheckStaticPlatform(x as uByte, y as uByte) as uByte
        If jumpCurrentKey <> jumpStopValue Then Return 0
        
        Dim col as uByte = x >> 1
        Dim lin as uByte = y >> 1

        dim tile as ubyte = GetTile(col, lin)

        if tile > 63 and tile < 80 then return 1

        return 0
    end function
#endif

function CheckCollision(x as uByte, y as uByte) as uByte
    Dim xIsEven as uByte = (x bAnd 1) = 0
    Dim yIsEven as uByte = (y bAnd 1) = 0
    Dim col as uByte = x >> 1
    Dim lin as uByte = y >> 1

    if isSolidTileByColLin(col, lin) then return 1
    if isSolidTileByColLin(col + 1, lin) then return 1
    if isSolidTileByColLin(col, lin + 1) then return 1
    if isSolidTileByColLin(col + 1, lin + 1) then return 1
    
    if not yIsEven then
        if isSolidTileByColLin(col, lin + 2) then return 1
        if isSolidTileByColLin(col + 1, lin + 2) then return 1
    end if

    if not xIsEven then
        if isSolidTileByColLin(col + 2, lin) then return 1
        if isSolidTileByColLin(col + 2, lin + 1) then return 1
    end if

    if not xIsEven and not yIsEven then
		if isSolidTileByColLin(col + 2, lin + 2) then return 1
    end if

	return 0
end function

sub removeTilesFromScreen(tile as ubyte)
	dim index as uinteger
    dim y, x as ubyte

	x = 0
	y = 0
	
	for index=0 to SCREEN_LENGTH
		if peek(@decompressedMap + index) - 1 = tile then
			SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
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
        if jumpCurrentKey = jumpStopValue and landed then
            landed = 0
            jumpCurrentKey = 0
        end if
    end sub
#endif

#ifdef INIT_TEXTS
    sub showInitTexts(Text as String)
        dim n as uByte
        dim line = ""
        dim word = ""
        dim y = 1
        dim x = 0
        cls
        for n=0 to len(Text)-1
            let c = Text(n to n)
            if c = " " or n = len(Text) - 1 then
                if len(line + word) > 31 then
                    print at y, 0; line
                    beep .01,0
                    let line = word
                    if c = " " then
                        let line = line + " "
                    end if
                    let y = y + 1
                    let x = 0
                else
                    let line = line + word
                    if c = " " then
                        let line = line + " "
                    end if
                end if
                let word = ""
            else
                let word = word + c
            end if
        next n
        if line <> "" then
            print at y, x; line
        end if
        while INKEY$<>"":wend
        while INKEY$="":wend
    end sub
#endif

sub debugA(value as BYTE)
    PRINT AT 0, 0; "----"
    PRINT AT 0, 0; value
end sub

sub debugB(value as BYTE)
    PRINT AT 0, 5; "  "
    PRINT AT 0, 5; value
end sub

sub debugC(value as UBYTE)
    PRINT AT 0, 10; "  "
    PRINT AT 0, 10; value
end sub

' sub debugD(value as UBYTE)
'     PRINT AT 18, 25; "  "
'     PRINT AT 18, 25; value
' end sub