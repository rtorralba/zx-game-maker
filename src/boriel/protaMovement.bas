Function canMoveLeft() As Ubyte
    Return Not CheckCollision(protaX - 1, protaY, 1)
End Function

Function canMoveRight() As Ubyte
    Return Not CheckCollision(protaX + 1, protaY, 1)
End Function

Function canMoveUp() As Ubyte
    #ifdef ARCADE_MODE
        If protaY = 0 Then
            protaY = 39
            Return 1
        End If
    #endif
    Return Not CheckCollision(protaX, protaY - 1, 1)
End Function

Function canMoveDown() As Ubyte
    #ifdef ARCADE_MODE
        If protaY > 39 Then
            protaY = 0
            Return 1
        End If
    #endif
    If CheckCollision(protaX, protaY + 1, 1) Then Return 0
    #ifdef SIDE_VIEW
        If checkPlatformByXY(protaX, protaY + 4) Then Return 0
        If checkTravesablePlatform(protaX, protaY + 4) Then Return 0
        If checkTravesablePlatform(protaX + 1, protaY + 4) Then Return 0
        If checkTravesablePlatform(protaX + 2, protaY + 4) Then Return 0
    #endif
    Return 1
End Function

#ifdef SIDE_VIEW
    #ifdef LADDERS_ENABLED
        Function getNextFrameLadder() As Ubyte
            If protaTile = 11 Then
                Return 12
            Else
                Return 11
            End If
        End Function
    #endif
#endif

Function getNextFrameRunning() As Ubyte
    #ifdef SIDE_VIEW
        #ifdef MAIN_CHARACTER_EXTRA_FRAME
            If protaDirection = 1 Then
                If protaFrame = 0 Then
                    protaLastFrame = protaFrame
                    Return 1
                Else If protaFrame = 1 And protaLastFrame = 0 Then
                    protaLastFrame = protaFrame
                    Return 2
                Else If protaFrame = 2 Then
                    protaLastFrame = protaFrame
                    Return 1
                Else If protaFrame = 1 And protaLastFrame = 2 Then
                    protaLastFrame = protaFrame
                    Return 0
                End If
            Else
                If protaFrame = 4 Then
                    protaLastFrame = protaFrame
                    Return 5
                Else If protaFrame = 5 And protaLastFrame = 4 Then
                    protaLastFrame = protaFrame
                    Return 6
                Else If protaFrame = 6 Then
                    protaLastFrame = protaFrame
                    Return 5
                Else If protaFrame = 5 And protaLastFrame = 6 Then
                    protaLastFrame = protaFrame
                    Return 4
                End If
            End If
        #Else
            If protaDirection = 1 Then
                If protaFrame = 0 Then
                    Return 1
                Else
                    Return 0
                End If
            Else
                If protaFrame = 4 Then
                    Return 5
                Else
                    Return 4
                End If
            End If
        #endif
    #Else
        If protaDirection = 1 Then
            If protaFrame = 0 Then
                Return 1
            Else
                Return 0
            End If
        Elseif protaDirection = 0 Then
            If protaFrame = 2 Then
                Return 3
            Else
                Return 2
            End If
        Elseif protaDirection = 8 Then
            If protaFrame = 4 Then
                Return 5
            Else
                Return 4
            End If
        Else ' down
            If protaFrame = 6 Then
                Return 7
            Else
                Return 6
            End If
        End If
    #endif
End Function

#ifdef SIDE_VIEW
    Function getNextFrameJumpingFalling() As Ubyte
        If (protaDirection) Then
            Return 4
        Else
            Return 8
        End If
    End Function
    
    #ifndef JETPACK_FUEL
        Sub checkIsJumping()
            If jumpCurrentKey >= jumpStopValue Then Return
            If jumpCurrentKey >= jumpStepsCount - 1 Then
                jumpCurrentKey = jumpStopValue
                Return
            End If
            
            If protaY < 2 Then
                #ifdef ARCADE_MODE
                    protaY = 39
                #Else
                    moveScreen = 8 ' stop jumping
                #endif
                jumpCurrentKey = jumpCurrentKey + 1
                Return
            End If
            
            If CheckCollision(protaX, protaY + jumpArray(jumpCurrentKey), 1) Or checkTravesablePlatformFromTop(protaX, protaY + jumpArray(jumpCurrentKey)) Then
                If jumpArray(jumpCurrentKey) > 0 Then
                    jumpCurrentKey = jumpStopValue
                Else
                    jumpCurrentKey = jumpCurrentKey + 1
                End If
                Return
            End If
            
            saveProta(protaY + jumpArray(jumpCurrentKey), protaX, getNextFrameJumpingFalling(), protaDirection)
            jumpCurrentKey = jumpCurrentKey + 1
        End Sub
    #endif
    
    #ifdef JETPACK_FUEL
        Function pressingUp() As Ubyte
            Return ((kempston = 0 And MultiKeys(keyArray(UP)) <> 0) Or (kempston = 1 And In(31) bAND %1000 <> 0))
        End Function
        
        Sub checkIsFlying()
            If jumpCurrentKey = jumpStopValue Then Return
            
            If protaY < 2 Then
                If jumpEnergy > 0 Then
                    #ifdef ARCADE_MODE
                        protaY = 39
                    #Else
                        moveScreen = 8 ' stop jumping
                    #endif
                End If
            End If
            
            If pressingUp() And jumpEnergy > 0 Then
                If Not CheckCollision(protaX, protaY - 1, 1) Then
                    saveProta(protaY - 1, protaX, getNextFrameJumpingFalling(), protaDirection)
                Else
                    saveProta(protaY, protaX, getNextFrameJumpingFalling(), protaDirection)
                End If
                jumpCurrentKey = jumpCurrentKey + 1
                jumpEnergy = jumpEnergy - 1
                PRINT AT HUD_JETPACK_FUEL_Y, HUD_JETPACK_FUEL_X; "  ";  
	            PRINT AT HUD_JETPACK_FUEL_Y, HUD_JETPACK_FUEL_X; jumpEnergy;
                Return
            End If
            
            jumpCurrentKey = jumpStopValue ' stop flight
        End Sub
    #endif
    
    Function isFalling() As Ubyte
        If canMoveDown() And Not CheckCollision(protaX, protaY, 2) And Not CheckCollision(protaX, protaY + 2, 2) Then
            #ifdef JETPACK_FUEL
                If pressingUp() Then
                    jumpCurrentKey = 0
                End If
            #endif
            Return 1
        Else
            If landed = 0 And jumpCurrentKey = jumpStopValue Then
                landed = 1
                #ifdef WALL_JUMP_ENABLED
                    wallJumpTimer = 0
                #endif
                #ifdef DASH_ENABLED
                    hasDashed = 0
                #endif
                jumpCurrentKey = jumpStopValue
                #ifdef JETPACK_FUEL
                    jumpEnergy = jumpStepsCount
                    printHud()
                #endif
                If protaY bAND 1 <> 0 Then
                    protaY = protaY - 1
                End If
                If protaDirection Then
                    saveProta(protaY, protaX, FIRST_RUNNING_PROTA_SPRITE_RIGHT, protaDirection)
                Else
                    saveProta(protaY, protaX, FIRST_RUNNING_PROTA_SPRITE_LEFT, protaDirection)
                End If
            End If
            Return 0
        End If
    End Function
    
    Sub gravity()
        #ifdef DASH_ENABLED
            If dashTimer > 0 Then Return
        #endif
        If jumpCurrentKey = jumpStopValue And isFalling() Then
            If protaY >= MAX_LINE Then
                moveScreen = 2
            Else
                #ifndef JETPACK_FUEL
                    saveProta(protaY + 2, protaX, getNextFrameJumpingFalling(), protaDirection)
                #Else
                    saveProta(protaY + 1, protaX, getNextFrameJumpingFalling(), protaDirection)
                #endif
            End If
            landed = 0
        End If
    End Sub

    #ifdef SHOOTING_ENABLED
        Sub shoot()
            If Not noKeyPressedForShoot Then Return
            noKeyPressedForShoot = 0
            
            If bulletPositionX <> 0 Then Return
            
            #ifdef AMMO_ENABLED
                If currentAmmo = 0 Then Return
                currentAmmo = currentAmmo - 1
                printHud()
            #endif
            
            currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
            If protaDirection Then
                #ifdef IDLE_ENABLED
                    saveProta(protaY, protaX, 1, 1)
                #endif
                
                currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
                bulletPositionX = protaX + 2
                If BULLET_DISTANCE <> 0 Then
                    If protaX + BULLET_DISTANCE > maxXScreenRight Then
                        bulletEndPositionX = maxXScreenRight
                    Else
                        bulletEndPositionX = protaX + BULLET_DISTANCE + 1
                    End If
                Else
                    bulletEndPositionX = maxXScreenRight
                End If
            Elseif protaDirection = 0
                #ifdef IDLE_ENABLED
                    saveProta(protaY, protaX, 5, 0)
                #endif
                currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
                bulletPositionX = protaX
                If BULLET_DISTANCE <> 0 Then
                    If BULLET_DISTANCE > protaX Then
                        bulletEndPositionX = maxXScreenLeft
                    Else
                        bulletEndPositionX = protaX - BULLET_DISTANCE + 1
                    End If
                Else
                    bulletEndPositionX = maxXScreenLeft
                End If
            End If
            
            bulletPositionY = protaY + 1
            bulletDirection = protaDirection
            BeepFX_Play(2)
        End Sub
    #endif
#endif

#ifdef OVERHEAD_VIEW
    #ifdef SHOOTING_ENABLED
        Sub shoot()
            If Not noKeyPressedForShoot Then Return
            
            noKeyPressedForShoot = 0
            
            #ifdef AMMO_ENABLED
                If currentAmmo = 0 Then Return
                currentAmmo = currentAmmo - 1
                printHud()
            #endif
            
            If bulletPositionX <> 0 Then Return
            
            If protaDirection = 1 Then
                currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
                bulletPositionX = protaX + 2
                bulletPositionY = protaY + 1
                If BULLET_DISTANCE <> 0 Then
                    If protaX + BULLET_DISTANCE > maxXScreenRight Then
                        bulletEndPositionX = maxXScreenRight
                    Else
                        bulletEndPositionX = protaX + BULLET_DISTANCE + 1
                    End If
                Else
                    bulletEndPositionX = maxXScreenRight
                End If
            Elseif protaDirection = 0
                currentBulletSpriteId = BULLET_SPRITE_LEFT_ID
                bulletPositionX = protaX
                bulletPositionY = protaY + 1
                If BULLET_DISTANCE <> 0 Then
                    If BULLET_DISTANCE > protaX Then
                        bulletEndPositionX = maxXScreenLeft
                    Else
                        bulletEndPositionX = protaX - BULLET_DISTANCE + 1
                    End If
                Else
                    bulletEndPositionX = maxXScreenLeft
                End If
            Elseif protaDirection = 8
                currentBulletSpriteId = BULLET_SPRITE_UP_ID
                bulletPositionX = protaX + 1
                bulletPositionY = protaY + 1
                If BULLET_DISTANCE <> 0 Then
                    If BULLET_DISTANCE > protaY Then
                        bulletEndPositionY = maxYScreenTop
                    Else
                        bulletEndPositionY = protaY - BULLET_DISTANCE + 1
                    End If
                Else
                    bulletEndPositionY = maxYScreenTop
                End If
            Else
                currentBulletSpriteId = BULLET_SPRITE_DOWN_ID
                bulletPositionX = protaX + 1
                bulletPositionY = protaY + 2
                If BULLET_DISTANCE <> 0 Then
                    If protaY + BULLET_DISTANCE > maxYScreenBottom Then
                        bulletEndPositionY = maxYScreenBottom
                    Else
                        bulletEndPositionY = protaY + BULLET_DISTANCE + 1
                    End If
                Else
                    bulletEndPositionY = maxYScreenBottom
                End If
            End If
            
            bulletDirection = protaDirection
            BeepFX_Play(2)
        End Sub
    #endif
#endif

Sub leftKey()
    If protaDirection <> 0 Then
        If swordTimer > 0 Then swordDirection = 0
        #ifdef SIDE_VIEW
            protaFrame = 4
        #Else
            protaFrame = 2
        #endif
        protaDirection = 0
        saveProta(protaY, protaX, getNextFrameRunning(), protaDirection)
    End If
    
    If protaX = 0 Then
        #ifdef ARCADE_MODE
            protaX = 60
            Return
        #Else
            moveScreen = 4
        #endif
    Elseif canMoveLeft()
        #ifdef SIDE_VIEW
            #ifdef LADDERS_ENABLED
                If CheckCollision(protaX, protaY, 2) Then
                    saveProta(protaY, protaX - 1, getNextFrameLadder(), 0)
                    Return
                End If
            #endif
        #endif
        Dim nextSprite as Ubyte = protaFrame + 1
        #ifdef SIDE_VIEW
            #ifdef DASH_ENABLED
                If dashTimer > 0 Then nextSprite = getNextFrameJumpingFalling()
            #endif
        #endif
        saveProta(protaY, protaX - 1, nextSprite, 0)
    End If
End Sub

Sub rightKey()
    If protaDirection <> 1 Then
        If swordTimer > 0 Then swordDirection = 1
        protaFrame = 0
        protaDirection = 1
        saveProta(protaY, protaX, getNextFrameRunning(), protaDirection)
    End If
    
    If protaX = 60 Then
        #ifdef ARCADE_MODE
            protaX = 0
            Return
        #Else
            moveScreen = 6
        #endif
    Elseif canMoveRight()
        #ifdef SIDE_VIEW
            #ifdef LADDERS_ENABLED
                If CheckCollision(protaX, protaY, 2) Then
                    saveProta(protaY, protaX + 1, getNextFrameLadder(), 1)
                    Return
                End If
            #endif
        #endif
        Dim nextSprite as Ubyte = protaFrame + 1
        #ifdef SIDE_VIEW
            #ifdef DASH_ENABLED
                If dashTimer > 0 Then nextSprite = getNextFrameJumpingFalling()
            #endif
        #endif
        saveProta(protaY, protaX + 1, nextSprite, 1)
    End If
End Sub

Sub upKey()
    #ifdef SIDE_VIEW
        #ifdef LADDERS_ENABLED
            If CheckCollision(protaX, protaY, 2) Then
                If protaY = 0 Then
                    #ifdef ARCADE_MODE
                        protaY = 39
                    #else
                        moveScreen = 8 ' stop jumping
                    #endif
                    Return
                End If
                If Not CheckCollision(protaX, protaY - 1, 1) Then
                    protaY = protaY - 1
                    protaTile = getNextFrameLadder()
                End If
            Else
                jump()
            End If
        #Else
            jump()
        #endif
    #Else
        If protaDirection <> 8 Then
            protaFrame = 4
            protaDirection = 8
        End If
        If canMoveUp() Then
            saveProta(protaY - 1, protaX, protaFrame + 1, 8)
            If protaY < 2 Then
                moveScreen = 8
            End If
        End If
    #endif
End Sub

Sub downKey()
    ' Sword Attack Logic
    If swordTimer = 0 Then
        swordTimer = SWORD_DURATION
        swordDirection = protaDirection
        BeepFX_Play(2)
    End If

    ' Allow movement if sword is not active? Or just block it?
    ' "instead of shooting bullet" implies it's an action.
    ' If we want to allow crouching/climbing concurrently, we remove the return.
    ' But typically attacks block movement or are mutually exclusive with ladders in simple engines.
    ' Given the prompt "when pressing down INSTEAD OF ...", I will assume it replaces the old behavior
    ' OR the user meant "instead of the bullet behavior that I might have bound to down"
    ' But wait, the user said "en vez de disparar bala", did they mean default down behavior was shoot?
    ' Only if they mapped Fire to Down?
    ' Regardles, I will keep the original movement logic BUT only if sword is not active?
    ' actually, if I want strict "sword instad of bullet", and bullet was bound to fire...
    ' The user wants Down -> Sword.
    ' And explicitly "en vez de disparar bala" suggests comparable action.
    
    ' I will COMMENT OUT the original movement logic to strictly follow "instead of".
    ' But if I block movement, they can't go down ladders.
    ' This might be a mistake in interpretation.
    ' Maybe they want "Press Down to Attack" AND "Press Down to Climb"?
    ' Context: "Platformer". Usually Down is Crouch/Climb.
    ' If I replace it, I break navigation.
    ' "En vez de disparar bala" -> Maybe they had a gun they could shoot downwards?
    ' The prompt says "shooting bullet" (generic).
    ' I will ADD the sword logic. I will Return ONLY if sword just started?
    ' No, if I return, I can't climb.
    
    ' Implementation: Trigger sword. If on ladder, maybe don't sword?
    ' Or just do both.
    ' "saco la espada" -> Visual effect.
    ' I'll leave the movement logic below active, so they can still climb down.
    ' BUT if they are just standing, they will look like they are attacking.
    
    #ifdef OVERHEAD_VIEW
        If protaDirection <> 2 Then
            protaFrame = 6
            protaDirection = 2
        End If
        If canMoveDown() Then
            If protaY >= MAX_LINE Then
                #ifndef ARCADE_MODE
                    moveScreen = 2
                #endif
            Else
                saveProta(protaY + 1, protaX, protaFrame + 1, 2)
            End If
        End If
    #Else
        If CheckCollision(protaX, protaY + 1, 1) Then Return
        If checkTravesablePlatformFromTopAndAll(protaX, protaY + 4) Or checkTravesablePlatformFromTopAndAll(protaX + 1, protaY + 4) Or checkTravesablePlatformFromTopAndAll(protaX + 2, protaY + 4) Or checkTravesablePlatformFromTopAndAll(protaX, protaY + 2) Or checkTravesablePlatformFromTopAndAll(protaX + 1, protaY + 2) Or checkTravesablePlatformFromTopAndAll(protaX + 2, protaY + 2) Or checkTravesablePlatformFromTopAndAll(protaX, protaY) Or checkTravesablePlatformFromTopAndAll(protaX + 1, protaY) Or checkTravesablePlatformFromTopAndAll(protaX + 2, protaY) Then
            protaY = protaY + 2
            Return
        End If
        #ifdef LADDERS_ENABLED
            If CheckCollision(protaX, protaY, 2) Or CheckCollision(protaX, protaY + 1, 2) Then
                If protaY = MAX_LINE Then
                    #ifdef ARCADE_MODE
                        protaY = 0
                    #else
                        moveScreen = 2 ' stop jumping
                    #endif
                    Return
                End If
                protaY = protaY + 1
                protaTile = getNextFrameLadder()
            End If
        #endif
    #endif
End Sub

Sub fireKey()
    #ifdef SHOOTING_ENABLED
        shoot()
    #endif
End Sub

Sub keyboardListen()
    #ifdef SIDE_VIEW
        #ifdef WALL_JUMP_ENABLED
            If wallJumpTimer > 0 Then
                wallJumpTimer = wallJumpTimer - 1
                If protaDirection = 0 Then
                    leftKey()
                Else
                    rightKey()
                End If
                
                If kempston Then
                    If In(31) bAND %10000 Then fireKey()
                Else
                    If MultiKeys(keyArray(FIRE))<>0 Then fireKey()
                End If
                Return
            End If
        #endif

        #ifdef DASH_ENABLED
            dashGhostActive = 0
            If dashTimer > 0 Then
                dashGhostX = protaX
                dashGhostY = protaY
                dashGhostTile = protaTile
                dashGhostActive = 1
                dashTimer = dashTimer - 1
                Dim i As Ubyte
                For i = 1 To 2
                    If protaDirection = 0 Then
                        leftKey()
                    Else
                        rightKey()
                    End If
                    #ifdef WALL_JUMP_ENABLED
                        If wallJumpTimer > 0 Then Exit For ' Break if wall hit (optional)
                    #endif
                Next i
                Return
            End If
        #endif
    #endif

    If kempston Then
        Dim n As Ubyte = In(31)
        If n bAND %10 Then leftKey()
        If n bAND %1 Then rightKey()
        If n bAND %1000 Then upKey()
        If n bAND %100 Then downKey()
        If n bAND %10000 Then fireKey()
        #ifdef IDLE_ENABLED
            If n = 0 Then
                If protaLoopCounter < IDLE_TIME Then protaLoopCounter = protaLoopCounter + 1
            Else
                protaLoopCounter = 0
            End If
        #endif
    Else
        If MultiKeys(keyArray(LEFT))<>0 Then leftKey()
        If MultiKeys(keyArray(RIGHT))<>0 Then rightKey()
        If MultiKeys(keyArray(UP))<>0 Then upKey()
        If MultiKeys(keyArray(DOWN))<>0 Then downKey()
        If MultiKeys(keyArray(FIRE))<>0 Then fireKey()
        #ifdef IDLE_ENABLED
            If MultiKeys(keyArray(LEFT))=0 And MultiKeys(keyArray(RIGHT))=0 And MultiKeys(keyArray(UP))=0 And MultiKeys(keyArray(DOWN))=0 And MultiKeys(keyArray(FIRE))=0 Then
                If protaLoopCounter < IDLE_TIME Then protaLoopCounter = protaLoopCounter + 1
            Else
                protaLoopCounter = 0
            End If
        #endif
    End If
End Sub

Function checkTileObject(tile As Ubyte) As Ubyte
    If tile < 187 Then Return 0
    
    If tile = ITEM_TILE Then
        currentItems = currentItems + ITEMS_INCREMENT
        #ifdef HISCORE_ENABLED
            incrementScore(100)
        #endif
        #ifdef BORDER_COLOR_ITEM
            Border BORDER_COLOR_ITEM
            resetBorder = 1
        #endif
        printHud()
        #ifdef MESSAGES_ENABLED
            printMessage(ITEM_FOUND_LINE1, ITEM_FOUND_LINE2, ITEM_FOUND_PAPER, ITEM_FOUND_INK)
        #endif
        #ifdef ARCADE_MODE
            If currentItems = itemsToFind Then
                drawKey()
            End If
        #endif

        If currentItems = ITEMS_TO_OPEN_DOORS Then
            removeTilesFromScreen(ITEMS_DOOR_TILE)
        End If
        BeepFX_Play(5)
        Return 1
    Elseif tile = KEY_TILE Then
        #ifdef ARCADE_MODE
            #ifdef ARCADE_SHOW_INTERMEDIATE_SCREEN
                moveScreen = 6
                Return 1
            #else
                #ifdef HISCORE_ENABLED
                    incrementScore(timerSeconds)
                #endif
                printHud()
                If currentScreen = SCREENS_COUNT Then
                    ending()
                Else
                    moveScreen = 6
                    Return 1
                End If
            #endif
        #endif
        currentKeys = currentKeys + 1
        #ifdef BORDER_COLOR_KEY
            Border BORDER_COLOR_KEY
            resetBorder = 1
        #endif
        printHud()
        #ifdef MESSAGES_ENABLED
            printMessage(KEY_FOUND_LINE1, KEY_FOUND_LINE2, KEY_FOUND_PAPER, KEY_FOUND_INK)
        #endif
        BeepFX_Play(3)
        Return 1
    Elseif tile = LIFE_TILE Then
        currentLife = currentLife + LIFE_AMOUNT
        #ifdef BORDER_COLOR_LIFE
            Border BORDER_COLOR_LIFE
            resetBorder = 1
        #endif
        printHud()
        #ifdef MESSAGES_ENABLED
            printMessage(LIFE_FOUND_LINE1, LIFE_FOUND_LINE2, LIFE_FOUND_PAPER, LIFE_FOUND_INK)
        #endif
        BeepFX_Play(6)
        Return 1
        #ifdef AMMO_ENABLED
        Elseif tile = AMMO_TILE Then
            currentAmmo = currentAmmo + AMMO_INCREMENT
            printHud()
            #ifdef MESSAGES_ENABLED
                printMessage(AMMO_FOUND_LINE1, AMMO_FOUND_LINE2, AMMO_FOUND_PAPER, AMMO_FOUND_INK)
            #endif
            BeepFX_Play(6)
            Return 1
        #endif
    End If
    Return 0
End Function

Sub checkObjectContact()
    Dim col As Ubyte = protaX >> 1
    Dim lin As Ubyte = protaY >> 1
    
    Dim besideTile As Ubyte
    Dim attr As Ubyte

    Dim tile As Ubyte = GetTile(col, lin)
    If checkTileObject(tile) Then
        #ifndef ARCADE_MODE
            addScreenObject(tile, col, lin)
        #endif
        besideTile = GetTile(col, lin - 1)
        If besideTile = 0 Then
            FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col, lin)
        Else
            FillWithTileChecked(0, 1, 1, attrSet(besideTile), col, lin)
        End If
        Return
    End If
    
    tile = GetTile(col + 1, lin)
    If checkTileObject(tile) Then
        #ifndef ARCADE_MODE
            addScreenObject(tile, col + 1, lin)
        #endif
        besideTile = GetTile(col, lin)
        If besideTile = 0 Then
            FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + 1, lin)
        Else
            FillWithTileChecked(0, 1, 1, attrSet(besideTile), col + 1, lin)
        End If
        Return
    End If
    
    tile = GetTile(col, lin + 1)
    If checkTileObject(tile) Then
        #ifndef ARCADE_MODE
            addScreenObject(tile, col, lin + 1)
        #endif
        besideTile = GetTile(col, lin)
        If besideTile = 0 Then
            FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col, lin + 1)
        Else
            FillWithTileChecked(0, 1, 1, attrSet(besideTile), col, lin + 1)
        End If
        Return
    End If
    
    tile = GetTile(col + 1, lin + 1)
    If checkTileObject(tile) Then
        #ifndef ARCADE_MODE
            addScreenObject(tile, col + 1, lin + 1)
        #endif
        besideTile = GetTile(col, lin)
        If besideTile = 0 Then
            FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + 1, lin + 1)
        Else
            FillWithTileChecked(0, 1, 1, attrSet(besideTile), col + 1, lin + 1)
        End If
        Return
    End If
End Sub

Sub checkDamageByTile()
    If invincible Then Return
    
    If CheckCollision(protaX, protaY, 0) Then
        decrementLife()
    End If
End Sub

#ifdef IDLE_ENABLED
    Sub animateIdle()
        If protaLoopCounter >= IDLE_TIME Then
            If jumpCurrentKey <> jumpStopValue Then Return
            
            #ifdef SIDE_VIEW
                #ifdef JETPACK_FUEL
                    If isFalling() Then Return
                #endif
            #endif

            If CheckCollision(protaX, protaY, 2) Then Return
            
            saveProta(protaY, protaX, getNextProtaIdleSprite(), protaDirection)
        End If
    End Sub
#endif

Sub updateSword()
    If swordTimer > 0 Then
        swordTimer = swordTimer - 1
    End If
End Sub

Sub protaMovement()
    updateSword()

    #ifdef LIVES_MODE_GRAVEYARD
        If invincible Then Return
    #endif

    #ifdef SHOOTING_ENABLED
        If kempston = 1 Then
            If In(31) bAND %10000 = 0 Then
                noKeyPressedForShoot = 1
            End If
        Else
            If MultiKeys(keyArray(FIRE)) = 0 Then
                noKeyPressedForShoot = 1
            End If
        End If
    #endif

    #ifdef SIDE_VIEW
        #ifdef DISABLE_CONTINUOUS_JUMP
            If kempston = 1 Then
                If In(31) bAND %1000 = 0 Then
                    noKeyPressedForJump = 1
                End If
            Else
                If MultiKeys(keyArray(UP)) = 0 Then
                    noKeyPressedForJump = 1
                End If
            End If
        #endif
    #endif
    keyboardListen()
    checkObjectContact()
    
    #ifdef SIDE_VIEW
        #ifndef JETPACK_FUEL
            checkIsJumping()
        #Else
            checkIsFlying()
        #endif
        gravity()
    #endif
    
    #ifdef MESSAGES_ENABLED
        checkMessageForDelete()
    #endif
End Sub