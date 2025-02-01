sub mapDraw()
	dim index, y, x as integer

	x = 0
	y = 0
	
	for index=0 to SCREEN_LENGTH
		drawTile(peek(@decompressedMap + index) - 1, x, y)

		x = x + 1
		if x = screenWidth
			x = 0
			y = y + 1
		end if
	next index
end sub

#ifdef KEYS_ENABLED
sub removeKeyDoors()
	dim index, y, x as integer

	x = 0
	y = 0
	
	for index=0 to SCREEN_LENGTH
		if peek(@decompressedMap + index) - 1 = DOOR_TILE
			SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
		end if

		x = x + 1
		if x = screenWidth
			x = 0
			y = y + 1
		end if
	next index
end sub
#endif

sub drawTile(tile as ubyte, x as ubyte, y as ubyte)
	if tile < 2 then return

	#ifdef SHOULD_KILL_ENEMIES_ENABLED
		if tile = 63 ' if is background, bullet or enemy kill door dont draw
			if screensWon(currentScreen)
				SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
			else
				SetTile(tile, attrSet(tile), x, y)
			end if
			return
		end if
	#else
		if tile = 63 ' if is background, bullet or enemy kill door dont draw
			SetTile(0, BACKGROUND_ATTRIBUTE, x, y)
			return
		end if
	#endif

	if tile < 187
		SetTile(tile, attrSet(tile), x, y)
		return
	end if
	
	if tile = ITEM_TILE
		if screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX)
			SetTileChecked(tile, attrSet(tile), x, y)
		end if
	elseif tile = KEY_TILE
		if screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX)
			SetTileChecked(tile, attrSet(tile), x, y)
		end if
	#ifdef KEYS_ENABLED
	elseif tile = DOOR_TILE
		if screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX)
			SetTile(tile, attrSet(tile), x, y)
		end if
	#endif
	elseif tile = LIFE_TILE
		if screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX)
			SetTileChecked(tile, attrSet(tile), x, y)
		end if
	elseif tile = AMMO_TILE
		if screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX)
			SetTileChecked(tile, attrSet(tile), x, y)
		end if
	end if
end sub

sub redrawScreen()
	' memset(22527,0,768)
    ' CancelOps()
	ClearScreen(7, 0, 0) ' Modified for only cancelops and no clear screen
	' dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
	FillWithTile(0, 32, 22, BACKGROUND_ATTRIBUTE, 0, 0)
	' clearBox(0,0,120,112)
	mapDraw()
	printLife()
	' enemiesDraw(currentScreen)
end sub

#ifdef KEYS_ENABLED
function checkTileIsDoor(col as ubyte, lin as ubyte) as ubyte
	if GetTile(col, lin) = DOOR_TILE
		if currentKeys <> 0
			currentKeys = currentKeys - 1
			printLife()
			screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX) = 0
			BeepFX_Play(4)
			removeKeyDoors()
		end if
		return 1
	else
		return 0
	end if
end function
#endif

#ifdef KEYS_ENABLED
function CheckDoor(x as uByte, y as uByte) as uByte
    Dim xIsEven as uByte = (x bAnd 1) = 0
    Dim yIsEven as uByte = (y bAnd 1) = 0
    Dim col as uByte = x >> 1
    Dim lin as uByte = y >> 1

    if xIsEven and yIsEven
        return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) _
            or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1)
    elseif xIsEven and not yIsEven
        return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) _
            or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1) _
            or checkTileIsDoor(col, lin + 2) or checkTileIsDoor(col + 1, lin + 2)
	elseif not xIsEven and yIsEven
		return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) or checkTileIsDoor(col + 2, lin) _
			or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1) or checkTileIsDoor(col + 2, lin + 1)
    elseif not xIsEven and not yIsEven
        return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) or checkTileIsDoor(col + 2, lin) _
            or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1) or checkTileIsDoor(col + 2, lin + 1) _
            or checkTileIsDoor(col, lin + 2) or checkTileIsDoor(col + 1, lin + 2) or checkTileIsDoor(col + 2, lin + 2)
    end if
end function
#endif

sub moveToScreen(direction as Ubyte)
	' removeAllObjects()
	if direction = 6
		saveSprite(PROTA_SPRITE, protaY, 0, getSpriteTile(PROTA_SPRITE), protaDirection)
		currentScreen = currentScreen + 1
	elseif direction = 4
		saveSprite(PROTA_SPRITE, protaY, 60, getSpriteTile(PROTA_SPRITE), protaDirection)
		currentScreen = currentScreen - 1
	elseif direction = 2
		saveSprite(PROTA_SPRITE, 0, protaX, getSpriteTile(PROTA_SPRITE), protaDirection)
		currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
	elseif direction = 8
		saveSprite(PROTA_SPRITE, MAX_LINE, protaX, getSpriteTile(PROTA_SPRITE), protaDirection)
		#ifdef SIDE_VIEW
			jumpCurrentKey = 0
		#endif
		currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT
	end if

	swapScreen()
	' removeScreenObjectFromBuffer()
	redrawScreen()
end sub

sub drawSprites()
	if (protaY < 41)
		if not invincible
			Draw2x2Sprite(spritesSet(getSpriteTile(PROTA_SPRITE)), protaX, protaY)
		else
			if invincibleBlink
				invincibleBlink = not invincibleBlink
				Draw2x2Sprite(spritesSet(getSpriteTile(PROTA_SPRITE)), protaX, protaY)
			else
				invincibleBlink = not invincibleBlink
			end if
		end if
	end if
	if enemiesPerScreen(currentScreen) > 0
		for i = 0 to enemiesPerScreen(currentScreen) - 1
			if not getSpriteLin(i) then continue for
			
			#ifdef ENEMIES_NOT_RESPAWN_ENABLED
				if decompressedEnemiesScreen(i, ENEMY_ALIVE) <> 99 and decompressedEnemiesScreen(i, ENEMY_TILE) > 15
					if screensWon(currentScreen) then continue for
				end if
			#endif
			Draw2x2Sprite(spritesSet(getSpriteTile(i)), getSpriteCol(i), getSpriteLin(i))
		next i
	end if

	if bulletPositionX <> 0
		Draw1x1Sprite(spritesSet(currentBulletSpriteId), bulletPositionX, bulletPositionY)
	end if

	RenderFrame()
END SUB