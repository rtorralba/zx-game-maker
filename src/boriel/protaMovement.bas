function canMoveLeft() as ubyte
	#ifdef KEYS_ENABLED
	if CheckDoor(protaX - 1, protaY) then
		return 0
	end if
	#endif
	return not CheckCollision(protaX - 1, protaY)
end function

function canMoveRight() as ubyte
	#ifdef KEYS_ENABLED
	if CheckDoor(protaX + 1, protaY) then
		return 0
	end if
	#endif
	return not CheckCollision(protaX + 1, protaY)
end function

function canMoveUp() as ubyte
	#ifdef ARCADE_MODE
		if protaY = 0 Then
			protaY = 39
			return 1
		end if
	#endif
	#ifdef KEYS_ENABLED
	if CheckDoor(protaX, protaY - 1) then
		return 0
	end if
	#endif
	return not CheckCollision(protaX, protaY - 1)
end function

function canMoveDown() as ubyte
	#ifdef ARCADE_MODE
		if protaY > 39 then
			protaY = 0
			return 1
		end if
	#endif
	#ifdef KEYS_ENABLED
	if CheckDoor(protaX, protaY + 1) then
		return 0
	end if
	#endif
	if CheckCollision(protaX, protaY + 1) then return 0
	#ifdef SIDE_VIEW
		if checkPlatformByXY(protaX, protaY + 4) then return 0
		if CheckStaticPlatform(protaX, protaY + 4) then return 0
		if CheckStaticPlatform(protaX + 1, protaY + 4) then return 0
		if CheckStaticPlatform(protaX + 2, protaY + 4) then return 0
	#endif
	return 1
end function

#ifdef SIDE_VIEW
	function getNextFrameJumpingFalling() as ubyte
		if (protaDirection) then
			return 4
		else
			return 8
		end if
	end function

	sub checkIsJumping()
		if jumpCurrentKey <> jumpStopValue then
			if protaY < 2 and jumpEnergy > 0 then
				#ifdef ARCADE_MODE
					protaY = 39
				#else
					moveScreen = 8 ' stop jumping
				#endif
			#ifndef JETPACK_FUEL
				elseif jumpCurrentKey < jumpStepsCount
					if CheckStaticPlatform(protaX, protaY + jumpArray(jumpCurrentKey)) then
						saveSprite(PROTA_SPRITE, protaY + jumpArray(jumpCurrentKey), protaX, getNextFrameJumpingFalling(), protaDirection)
					else
						if not CheckCollision(protaX, protaY + jumpArray(jumpCurrentKey)) then
							saveSprite(PROTA_SPRITE, protaY + jumpArray(jumpCurrentKey), protaX, getNextFrameJumpingFalling(), protaDirection)
						end if
					end if
					jumpCurrentKey = jumpCurrentKey + 1
				else
					jumpCurrentKey = jumpStopValue ' stop jumping
				end if
			#else
				elseif jumpCurrentKey < jumpStepsCount _ 
				and ((kempston = 0 and MultiKeys(keyArray(UP)) <> 0) or (kempston = 1 and IN(31) bAND %1000 <> 0)) _ 
				and jumpEnergy > 0 then
					if not CheckCollision(protaX, protaY - 1) then
						saveSprite(PROTA_SPRITE, protaY - 1, protaX, getNextFrameJumpingFalling(), protaDirection)
					end if
					jumpCurrentKey = jumpCurrentKey + 1
					jumpEnergy = jumpEnergy - 1
					if jumpEnergy MOD 5 = 0 then 
						printLife()
					end if
				else
					jumpCurrentKey = jumpStopValue ' stop jumping
					if jumpEnergy = 0 then
						printLife()
					end if
				end if
			#endif 
		end if
	end sub

	function isFalling() as UBYTE
		if canMoveDown() then
			#ifdef JETPACK_FUEL
				if (kempston = 0 and MultiKeys(keyArray(UP)) <> 0) or ( kempston = 1 and IN(31) bAND %1000 <> 0) then
					jumpCurrentKey = 0
				end if
			#endif
			return 1
		else
			if landed = 0 then
				landed = 1
				#ifdef JETPACK_FUEL
					jumpEnergy = jumpStepsCount
					printLife()
				#endif
				if protaY bAND 1 <> 0 then
					' saveSpriteLin(PROTA_SPRITE, protaY - 1)
					protaY = protaY - 1
				end if
				resetProtaSpriteToRunning()
			end if
			return 0
		end if
	end function

	sub gravity()
		if jumpCurrentKey = jumpStopValue and isFalling() then
			if protaY >= MAX_LINE then
				moveScreen = 2
			else
				#ifndef JETPACK_FUEL
					saveSprite(PROTA_SPRITE, protaY + 2, protaX, getNextFrameJumpingFalling(), protaDirection)
				#else
					saveSprite(PROTA_SPRITE, protaY + 1, protaX, getNextFrameJumpingFalling(), protaDirection)
				#endif
			end if
			landed = 0
		end if
	end sub
#endif

function getNextFrameRunning() as UBYTE
	#ifdef SIDE_VIEW
		#ifdef MAIN_CHARACTER_EXTRA_FRAME
			if protaDirection = 1 then ' right
				if protaFrame = 0 then
					protaLastFrame = protaFrame
					return 1
				else if protaFrame = 1 and protaLastFrame = 0 then
					protaLastFrame = protaFrame
					return 2
				else if protaFrame = 2 then
					protaLastFrame = protaFrame
					return 1
				else if protaFrame = 1 and protaLastFrame = 2 then
					protaLastFrame = protaFrame
					return 0
				end if
			else ' left
				if protaFrame = 4 then
					protaLastFrame = protaFrame
					return 5
				else if protaFrame = 5 and protaLastFrame = 4 then
					protaLastFrame = protaFrame
					return 6
				else if protaFrame = 6 then
					protaLastFrame = protaFrame
					return 5
				else if protaFrame = 5 and protaLastFrame = 6 then
					protaLastFrame = protaFrame
					return 4
				end if
			end if
		#else
			if protaDirection = 1 then' right
				if protaFrame = 0 then
					return 1
				else
					return 0
				end if
			else
				if protaFrame = 4 then
					return 5
				else
					return 4
				end if
			end if
		#endif
	#else
		if protaDirection = 1 then ' right
			if protaFrame = 0 then
				return 1
			else
				return 0
			end if
		elseif protaDirection = 0 then' left
			if protaFrame = 2 then
				return 3
			else
				return 2
			end if
		elseif protaDirection = 8 then ' up
			if protaFrame = 4 then
				return 5
			else
				return 4
			end if
		else ' down
			if protaFrame = 6 then
				return 7
			else
				return 6
			end if
		end if
	#endif
end function

#ifdef SIDE_VIEW
	sub shoot()
		if not noKeyPressedForShoot then return
		noKeyPressedForShoot = 0

		if bulletPositionX <> 0 then return ' bullet in movement

		#ifdef AMMO_ENABLED
			if currentAmmo = 0 then return
			currentAmmo = currentAmmo - 1
			printLife()
		#endif

		currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
		if protaDirection then
			currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
			bulletPositionX = protaX + 2
			if BULLET_DISTANCE <> 0 then
				if protaX + BULLET_DISTANCE > maxXScreenRight then
					bulletEndPositionX = maxXScreenRight
				else
					bulletEndPositionX = protaX + BULLET_DISTANCE + 1
				end if
			else
				bulletEndPositionX = maxXScreenRight
			end if
		elseif protaDirection = 0
			currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
			bulletPositionX = protaX
			if BULLET_DISTANCE <> 0 then
				if BULLET_DISTANCE > protaX then
					bulletEndPositionX = maxXScreenLeft
				else
					bulletEndPositionX = protaX - BULLET_DISTANCE + 1
				end if
			else
				bulletEndPositionX = maxXScreenLeft
			end if
		end if

		bulletPositionY = protaY + 1
		bulletDirection = protaDirection
		BeepFX_Play(2)
	end sub
#endif

#ifdef OVERHEAD_VIEW
	sub shoot()
		if not noKeyPressedForShoot then return

		noKeyPressedForShoot = 0

		#ifdef AMMO_ENABLED
			if currentAmmo = 0 then return
			currentAmmo = currentAmmo - 1
			printLife()
		#endif

		if bulletPositionX <> 0 then return ' bullet in movement

		if protaDirection = 1 then
			currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
			bulletPositionX = protaX + 2
			bulletPositionY = protaY + 1
			if BULLET_DISTANCE <> 0 then
				if protaX + BULLET_DISTANCE > maxXScreenRight then
					bulletEndPositionX = maxXScreenRight
				else
					bulletEndPositionX = protaX + BULLET_DISTANCE + 1
				end if
			else
				bulletEndPositionX = maxXScreenRight
			end if
		elseif protaDirection = 0
			currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
			bulletPositionX = protaX
			bulletPositionY = protaY + 1
			if BULLET_DISTANCE <> 0 then
				if BULLET_DISTANCE > protaX then
					bulletEndPositionX = maxXScreenLeft
				else
					bulletEndPositionX = protaX - BULLET_DISTANCE + 1
				end if
			else
				bulletEndPositionX = maxXScreenLeft
			end if
		elseif protaDirection = 8
			currentBulletSpriteId = BULLET_SPRITE_UP_ID
			bulletPositionX = protaX + 1
			bulletPositionY = protaY + 1
			if BULLET_DISTANCE <> 0 then
				if BULLET_DISTANCE > protaY then
					bulletEndPositionY = maxYScreenTop
				else
					bulletEndPositionY = protaY - BULLET_DISTANCE + 1
				end if
			else
				bulletEndPositionY = maxYScreenTop
			end if
		else
			currentBulletSpriteId = BULLET_SPRITE_DOWN_ID
			bulletPositionX = protaX + 1
			bulletPositionY = protaY + 2
			if BULLET_DISTANCE <> 0 then
				if protaY + BULLET_DISTANCE > maxYScreenBottom then
					bulletEndPositionY = maxYScreenBottom
				else
					bulletEndPositionY = protaY + BULLET_DISTANCE + 1
				end if
			else
				bulletEndPositionY = maxYScreenBottom
			end if
		end if

		bulletDirection = protaDirection
		BeepFX_Play(2)
	end sub
#endif

sub leftKey()
	if protaDirection <> 0 then
		#ifdef SIDE_VIEW
			protaFrame = 4
		#else
			protaFrame = 2
		#endif
		spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 0
	end if

	if onFirstColumn(PROTA_SPRITE) then
		#ifdef ARCADE_MODE
			protaX = 60
			return
		#else
			moveScreen = 4
		#endif
	elseif canMoveLeft()
		saveSprite(PROTA_SPRITE, protaY, protaX - 1, protaFrame + 1, 0)
	end if
end sub

sub rightKey()
	if protaDirection <> 1 then
		protaFrame = 0
		spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 1
	end if

	if onLastColumn(PROTA_SPRITE) then
		#ifdef ARCADE_MODE
			protaX = 0
			return
		#else
			moveScreen = 6
		#endif
	elseif canMoveRight()
		saveSprite(PROTA_SPRITE, protaY, protaX + 1, protaFrame + 1, 1)
	end if
end sub

sub upKey()
	#ifdef SIDE_VIEW
		jump()
	#else
		if protaDirection <> 8 then
			protaFrame = 4
			spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 8
		end if
		if canMoveUp() then
			saveSprite(PROTA_SPRITE, protaY - 1, protaX, protaFrame + 1, 8)
			if protaY < 2 then
				moveScreen = 8
			end if
		end if
	#endif
end sub

sub downKey()
	#ifdef OVERHEAD_VIEW
		if protaDirection <> 2 then
			protaFrame = 6
			spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 2
		end if
		if canMoveDown() then
			if protaY >= MAX_LINE then
				#ifndef ARCADE_MODE
					moveScreen = 2
				#endif
			else
				saveSprite(PROTA_SPRITE, protaY + 1, protaX, protaFrame + 1, 2)
			end if
		end if
	#else
		if CheckStaticPlatform(protaX, protaY + 4) or CheckStaticPlatform(protaX + 1, protaY + 4) or CheckStaticPlatform(protaX + 2, protaY + 4) then
			protaY = protaY + 2
		end if
	#endif
end sub

sub fireKey()
	#ifdef SHOOTING_ENABLED
		shoot()
	#endif
end sub

sub keyboardListen()
	if kempston then
		dim n as ubyte = IN(31)
		if n bAND %10 then leftKey()
		if n bAND %1 then rightKey()
		if n bAND %1000 then upKey()
		if n bAND %100 then downKey()
		if n bAND %10000 then fireKey()
		#ifdef IDLE_ENABLED
			if n = 0 then
				if protaLoopCounter < IDLE_TIME then protaLoopCounter = protaLoopCounter + 1
			else
				protaLoopCounter = 0
			end if
		#endif
	else
		if MultiKeys(keyArray(LEFT))<>0 then leftKey()
		if MultiKeys(keyArray(RIGHT))<>0 then rightKey()
		if MultiKeys(keyArray(UP))<>0 then upKey()
		if MultiKeys(keyArray(DOWN))<>0 then downKey()
		if MultiKeys(keyArray(FIRE))<>0 then fireKey()
		#ifdef IDLE_ENABLED
			if MultiKeys(keyArray(LEFT))=0 and MultiKeys(keyArray(RIGHT))=0 and MultiKeys(keyArray(UP))=0 and MultiKeys(keyArray(DOWN))=0 and MultiKeys(keyArray(FIRE))=0 then
				if protaLoopCounter < IDLE_TIME then protaLoopCounter = protaLoopCounter + 1
			else
				protaLoopCounter = 0
			end if
		#endif
	end if
end sub

function checkTileObject(tile as ubyte) as ubyte
	if tile = ITEM_TILE then
		#ifndef ARCADE_MODE
			if not screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) then
				return 0
			endif
		#endif
		currentItems = currentItems + ITEMS_INCREMENT
		#ifdef HISCORE_ENABLED
			score = score + 100
			If score > hiScore Then
            	hiScore = score
        	End If
		#endif
		printLife()
		#ifdef ARCADE_MODE
			if currentItems = itemsToFind then
				drawKey()
			end if
		#else
			if currentItems = GOAL_ITEMS then
				ending()
			end if
		#endif
		screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) = 0
		BeepFX_Play(5)
		return 1
	#ifdef KEYS_ENABLED
	elseif tile = KEY_TILE and screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) then
		#ifdef ARCADE_MODE
			if currentScreen = SCREENS_COUNT then
				ending()
			else
				moveScreen = 6
				return 1
			end if
		#endif
		currentKeys = currentKeys + 1
		printLife()
		screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) = 0
		BeepFX_Play(3)
		return 1
	#endif
	elseif tile = LIFE_TILE and screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) then
		currentLife = currentLife + LIFE_AMOUNT
		printLife()
		screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) = 0
		BeepFX_Play(6)
		return 1
	#ifdef AMMO_ENABLED
	elseif tile = AMMO_TILE and screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) then
		currentAmmo = currentAmmo + AMMO_INCREMENT
		printLife()
		screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) = 0
		BeepFX_Play(6)
		return 1
	#endif
	end if
	return 0
end function

sub checkObjectContact()
	Dim col as uByte = protaX >> 1
    Dim lin as uByte = protaY >> 1

	if checkTileObject(GetTile(col, lin)) then
		FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col, lin)
		return
	elseif checkTileObject(GetTile(col + 1, lin))
		FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + 1, lin)
		return
	elseif checkTileObject(GetTile(col, lin + 1))
		FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col, lin + 1)
		return
	elseif checkTileObject(GetTile(col + 1, lin + 1))
		FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + 1, lin + 1)
		return
	end if
end sub

sub checkDamageByTile()
    if invincible then return
    
    Dim col as uByte = protaX >> 1
    Dim lin as uByte = protaY >> 1

	if isADamageTile(GetTile(col, lin)) then
		protaTouch()
		return
	end if
	if isADamageTile(GetTile(col + 1, lin)) then
		protaTouch()
		return
	end if
	if isADamageTile(GetTile(col, lin + 1)) then
		protaTouch()
		return
	end if
	if isADamageTile(GetTile(col + 1, lin + 1)) then
		protaTouch()
		return
	end if
end sub

sub protaMovement()
	if MultiKeys(keyArray(FIRE)) = 0 then
		noKeyPressedForShoot = 1
	end if
	keyboardListen()
	checkObjectContact()

	#ifdef SIDE_VIEW
		checkIsJumping()
		gravity()

		#ifdef IDLE_ENABLED
			if protaLoopCounter >= IDLE_TIME then
				if jumpCurrentKey <> jumpStopValue then return
				if isFalling() then return

				if framec - lastFrameTiles = ANIMATE_PERIOD_TILE - 2 then
					if getSpriteTile(PROTA_SPRITE) = 13 then
						saveSprite(PROTA_SPRITE, protaY, protaX, 14, protaDirection)
					else
						saveSprite(PROTA_SPRITE, protaY, protaX, 13, protaDirection)
					end if
				end if
			end if
		#endif
	#endif
end sub
