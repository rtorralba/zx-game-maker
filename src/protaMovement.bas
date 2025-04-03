function canMoveLeft() as ubyte
	#ifdef KEYS_ENABLED
	if CheckDoor(protaX - 1, protaY)
		return 0
	end if
	#endif
	return not CheckCollision(protaX - 1, protaY)
end function

function canMoveRight() as ubyte
	#ifdef KEYS_ENABLED
	if CheckDoor(protaX + 1, protaY)
		return 0
	end if
	#endif
	return not CheckCollision(protaX + 1, protaY)
end function

function canMoveUp() as ubyte
	#ifdef KEYS_ENABLED
	if CheckDoor(protaX, protaY - 1)
		return 0
	end if
	#endif
	return not CheckCollision(protaX, protaY - 1)
end function

function canMoveDown() as ubyte
	#ifdef KEYS_ENABLED
	if CheckDoor(protaX, protaY + 1)
		return 0
	end if
	#endif
	if CheckCollision(protaX, protaY + 1) return 0
	#ifdef SIDE_VIEW
		if checkPlatformByXY(protaX, protaY + 4) return 0
		if CheckStaticPlatform(protaX, protaY + 4) return 0
		if CheckStaticPlatform(protaX + 1, protaY + 4) return 0
		if CheckStaticPlatform(protaX + 2, protaY + 4) return 0
	#endif
	return 1
end function

#ifdef SIDE_VIEW
	function getNextFrameJumpingFalling() as ubyte
		if (protaDirection)
			return 3
		else
			return 7
		end if
	end function

	sub checkIsJumping()
		if jumpCurrentKey <> jumpStopValue
			if protaY < 2
				moveScreen = 8 ' stop jumping
			elseif jumpCurrentKey < jumpStepsCount
				if CheckStaticPlatform(protaX, protaY + jumpArray(jumpCurrentKey))
					saveSprite(PROTA_SPRITE, protaY + jumpArray(jumpCurrentKey), protaX, getNextFrameJumpingFalling(), protaDirection)
				else
					if not CheckCollision(protaX, protaY + jumpArray(jumpCurrentKey))
						saveSprite(PROTA_SPRITE, protaY + jumpArray(jumpCurrentKey), protaX, getNextFrameJumpingFalling(), protaDirection)
					end if
				end if
				jumpCurrentKey = jumpCurrentKey + 1
			else
				jumpCurrentKey = jumpStopValue ' stop jumping
			end if
		end if
	end sub

	function isFalling() as UBYTE
		if canMoveDown()
			return 1
		else
			if landed = 0
				landed = 1
				if protaY bAND 1 <> 0
					' saveSpriteLin(PROTA_SPRITE, protaY - 1)
					protaY = protaY - 1
				end if
				resetProtaSpriteToRunning()
			end if
			return 0
		end if
	end function

	sub gravity()
		if jumpCurrentKey = jumpStopValue and isFalling()
			if protaY >= MAX_LINE
				moveScreen = 2
			else
				saveSprite(PROTA_SPRITE, protaY + 2, protaX, getNextFrameJumpingFalling(), protaDirection)
			end if
			landed = 0
		end if
	end sub
#endif

function getNextFrameRunning() as UBYTE
	#ifdef SIDE_VIEW
		#ifdef MAIN_CHARACTER_EXTRA_FRAME
			if protaDirection = 1 ' right
				if protaFrame = 0
					protaLastFrame = protaFrame
					return 1
				else if protaFrame = 1 and protaLastFrame = 0
					protaLastFrame = protaFrame
					return 2
				else if protaFrame = 2
					protaLastFrame = protaFrame
					return 1
				else if protaFrame = 1 and protaLastFrame = 2
					protaLastFrame = protaFrame
					return 0
				end if
			else ' left
				if protaFrame = 4
					protaLastFrame = protaFrame
					return 5
				else if protaFrame = 5 and protaLastFrame = 4
					protaLastFrame = protaFrame
					return 6
				else if protaFrame = 6
					protaLastFrame = protaFrame
					return 5
				else if protaFrame = 5 and protaLastFrame = 6
					protaLastFrame = protaFrame
					return 4
				end if
			end if
		#else
			if protaDirection = 1 ' right
				if protaFrame = 0
					return 1
				else
					return 0
				end if
			else
				if protaFrame = 4
					return 5
				else
					return 4
				end if
			end if
		#endif
	#else
		if protaDirection = 1 ' right
			if protaFrame = 0
				return 1
			else
				return 0
			end if
		elseif protaDirection = 0 ' left
			if protaFrame = 2
				return 3
			else
				return 2
			end if
		elseif protaDirection = 8 ' up
			if protaFrame = 4
				return 5
			else
				return 4
			end if
		else ' down
			if protaFrame = 6
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

		if bulletPositionX <> 0 return ' bullet in movement

		#ifdef AMMO_ENABLED
			if currentAmmo = 0 then return
			currentAmmo = currentAmmo - 1
			printLife()
		#endif

		currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
		if protaDirection
			currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
			bulletPositionX = protaX + 2
			if BULLET_DISTANCE <> 0
				if protaX + BULLET_DISTANCE > maxXScreenRight
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
			if BULLET_DISTANCE <> 0
				if BULLET_DISTANCE > protaX
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

		if bulletPositionX <> 0 return ' bullet in movement

		if protaDirection = 1
			currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
			bulletPositionX = protaX + 2
			bulletPositionY = protaY + 1
			if BULLET_DISTANCE <> 0
				if protaX + BULLET_DISTANCE > maxXScreenRight
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
			if BULLET_DISTANCE <> 0
				if BULLET_DISTANCE > protaX
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
			if BULLET_DISTANCE <> 0
				if BULLET_DISTANCE > protaY
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
			if BULLET_DISTANCE <> 0
				if protaY + BULLET_DISTANCE > maxYScreenBottom
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
	if protaDirection <> 0
		#ifdef SIDE_VIEW
			protaFrame = 4
		#else
			protaFrame = 2
		#endif
		spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 0
	end if

	if onFirstColumn(PROTA_SPRITE)
		moveScreen = 4
	elseif canMoveLeft()
		saveSprite(PROTA_SPRITE, protaY, protaX - 1, protaFrame, 0)
	end if
end sub

sub rightKey()
	if protaDirection <> 1
		protaFrame = 0
		spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 1
	end if

	if onLastColumn(PROTA_SPRITE)
		moveScreen = 6
	elseif canMoveRight()
		saveSprite(PROTA_SPRITE, protaY, protaX + 1, protaFrame, 1)
	end if
end sub

sub upKey()
	#ifdef SIDE_VIEW
		jump()
	#else
		if protaDirection <> 8
			protaFrame = 4
			spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 8
		end if
		if canMoveUp()
			saveSprite(PROTA_SPRITE, protaY - 1, protaX, protaFrame, 8)
			if protaY < 2
				moveScreen = 8
			end if
		end if
	#endif
end sub

sub downKey()
	#ifdef OVERHEAD_VIEW
		if protaDirection <> 2
			protaFrame = 6
			spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 2
		end if
		if canMoveDown()
			if protaY >= MAX_LINE
				moveScreen = 2
			else
				saveSprite(PROTA_SPRITE, protaY + 1, protaX, protaFrame, 2)
			end if
		end if
	#else
		if CheckStaticPlatform(protaX, protaY + 4) or CheckStaticPlatform(protaX + 1, protaY + 4) or CheckStaticPlatform(protaX + 2, protaY + 4)
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
	if kempston
		dim n as ubyte = IN(31)
		if n bAND %10 then leftKey()
		if n bAND %1 then rightKey()
		if n bAND %1000 then upKey()
		if n bAND %100 then downKey()
		if n bAND %10000 then fireKey()
		#ifdef IDLE_ENABLED
			if n = 0
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
			if MultiKeys(keyArray(LEFT))=0 and MultiKeys(keyArray(RIGHT))=0 and MultiKeys(keyArray(UP))=0 and MultiKeys(keyArray(DOWN))=0 and MultiKeys(keyArray(FIRE))=0
				if protaLoopCounter < IDLE_TIME then protaLoopCounter = protaLoopCounter + 1
			else
				protaLoopCounter = 0
			end if
		#endif
	end if
end sub

function checkTileObject(tile as ubyte) as ubyte
	if tile = ITEM_TILE and screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX)
		currentItems = currentItems + ITEMS_INCREMENT
		#ifdef HISCORE_ENABLED
			score = score + 100
		#endif
		printLife()
		if currentItems = GOAL_ITEMS
			go to ending
		end if
		screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) = 0
		BeepFX_Play(5)
		return 1
	#ifdef KEYS_ENABLED
	elseif tile = KEY_TILE and screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX)
		currentKeys = currentKeys + 1
		printLife()
		screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) = 0
		BeepFX_Play(3)
		return 1
	#endif
	elseif tile = LIFE_TILE and screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX)
		currentLife = currentLife + LIFE_AMOUNT
		printLife()
		screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) = 0
		BeepFX_Play(6)
		return 1
	#ifdef AMMO_ENABLED
	elseif tile = AMMO_TILE and screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX)
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

	if checkTileObject(GetTile(col, lin))
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

	if isADamageTile(GetTile(col, lin))
		protaTouch(TILE_DAMAGE_AMOUNT)
		return
	end if
	if isADamageTile(GetTile(col + 1, lin))
		protaTouch(TILE_DAMAGE_AMOUNT)
		return
	end if
	if isADamageTile(GetTile(col, lin + 1))
		protaTouch(TILE_DAMAGE_AMOUNT)
		return
	end if
	if isADamageTile(GetTile(col + 1, lin + 1))
		protaTouch(TILE_DAMAGE_AMOUNT)
		return
	end if
end sub

sub protaMovement()
	if MultiKeys(keyArray(FIRE)) = 0
		noKeyPressedForShoot = 1
	end if
	keyboardListen()
	checkObjectContact()

	#ifdef SIDE_VIEW
		checkIsJumping()
		gravity()

		#ifdef IDLE_ENABLED
			if protaLoopCounter = IDLE_TIME
				if jumpCurrentKey <> jumpStopValue then return
				if isFalling() then return

				if framec - lastFrameTiles = ANIMATE_PERIOD_TILE - 2
					if getSpriteTile(PROTA_SPRITE) = 12
						saveSprite(PROTA_SPRITE, protaY, protaX, 13, protaDirection)
					else
						saveSprite(PROTA_SPRITE, protaY, protaX, 12, protaDirection)
					end if
				end if
			end if
		#endif
	#else
		#ifdef IDLE_ENABLED
			if protaLoopCounter = IDLE_TIME
				if framec - lastFrameTiles = ANIMATE_PERIOD_TILE - 2
					if getSpriteTile(PROTA_SPRITE) = 12
						saveSprite(PROTA_SPRITE, protaY, protaX, 13, protaDirection)
					else
						saveSprite(PROTA_SPRITE, protaY, protaX, 12, protaDirection)
					end if
				end if
			end if
		#endif
	#endif

	#ifdef IDLE_ENABLED
		#ifdef DAMAGE_TIME_ENABLED
			if protaLoopCounter = 0
				movementTime = movementTime + 1

				if movementTime = MAX_DAMAGE_TIME
					protaTouch(1)
				end if
			end if
		#endif
	#endif
end sub