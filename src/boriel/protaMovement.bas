Function canMoveLeft() As Ubyte
    #ifdef KEYS_ENABLED
        If CheckDoor(protaX - 1, protaY) Then
            Return 0
        End If
    #endif
    Return Not CheckCollision(protaX - 1, protaY)
End Function

Function canMoveRight() As Ubyte
    #ifdef KEYS_ENABLED
        If CheckDoor(protaX + 1, protaY) Then
            Return 0
        End If
    #endif
    Return Not CheckCollision(protaX + 1, protaY)
End Function

Function canMoveUp() As Ubyte
    #ifdef ARCADE_MODE
        If protaY = 0 Then
            protaY = 39
            Return 1
        End If
    #endif
    #ifdef KEYS_ENABLED
        If CheckDoor(protaX, protaY - 1) Then
            Return 0
        End If
    #endif
    Return Not CheckCollision(protaX, protaY - 1)
End Function

Function canMoveDown() As Ubyte
    #ifdef ARCADE_MODE
        If protaY > 39 Then
            protaY = 0
            Return 1
        End If
    #endif
    #ifdef KEYS_ENABLED
        If CheckDoor(protaX, protaY + 1) Then
            Return 0
        End If
    #endif
    If CheckCollision(protaX, protaY + 1) Then Return 0
    #ifdef SIDE_VIEW
        If checkPlatformByXY(protaX, protaY + 4) Then Return 0
        If CheckStaticPlatform(protaX, protaY + 4) Then Return 0
        If CheckStaticPlatform(protaX + 1, protaY + 4) Then Return 0
        If CheckStaticPlatform(protaX + 2, protaY + 4) Then Return 0
    #endif
    Return 1
End Function

#ifdef SIDE_VIEW
    Function getNextFrameJumpingFalling() As Ubyte
        If (protaDirection) Then
            Return 4
        Else
            Return 8
        End If
    End Function
    
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
            
            If CheckCollision(protaX, protaY + jumpArray(jumpCurrentKey)) Then
                jumpCurrentKey = jumpStopValue
                Return
            End If
            
            If jumpArray(jumpCurrentKey) <= 0 Then
                If CheckCollision(protaX, protaY + jumpArray(jumpCurrentKey) + 1) Then
                    jumpCurrentKey = jumpStopValue
                    Return
                End If
            Else
                If CheckCollision(protaX, protaY + jumpArray(jumpCurrentKey) - 1) Then
                    jumpCurrentKey = jumpStopValue
                    Return
                End If
                If CheckStaticPlatform(protaX, protaY + jumpArray(jumpCurrentKey)) Then
                    jumpCurrentKey = jumpStopValue
                    Return
                End If
                If CheckStaticPlatform(protaX + 1, protaY + jumpArray(jumpCurrentKey)) Then
                    jumpCurrentKey = jumpStopValue
                    Return
                End If
                If jumpArray(jumpCurrentKey) = 2 Then
                    If CheckStaticPlatform(protaX, protaY + jumpArray(jumpCurrentKey) + 2) Then
                        jumpCurrentKey = jumpStopValue
                        resetProtaSpriteToRunning()
                        Return
                    End If
                    If CheckStaticPlatform(protaX + 1, protaY + jumpArray(jumpCurrentKey) + 2) Then
                        jumpCurrentKey = jumpStopValue
                        resetProtaSpriteToRunning()
                        Return
                    End If
                End If
            End If
            
            saveSprite(PROTA_SPRITE, protaY + jumpArray(jumpCurrentKey), protaX, getNextFrameJumpingFalling(), protaDirection)
            jumpCurrentKey = jumpCurrentKey + 1
        End Sub
    #endif
    
    #ifdef JETPACK_FUEL
        Function pressingUp() As Ubyte
            return ((kempston = 0 and MultiKeys(keyArray(UP)) <> 0) or (kempston = 1 and IN(31) bAND %1000 <> 0))
        End Function
        
        sub checkIsFlying()
            if jumpCurrentKey = jumpStopValue then return
            
            if protaY < 2 then
                if jumpEnergy > 0 then
                    #ifdef ARCADE_MODE
                        protaY = 39
                    #else
                        moveScreen = 8 ' stop jumping
                    #endif
                end if  
                Return
            end if    
            
            if pressingUp() and jumpEnergy > 0 then
                if not CheckCollision(protaX, protaY - 1) then
                    saveSprite(PROTA_SPRITE, protaY - 1, protaX, getNextFrameJumpingFalling(), protaDirection)
                end if
                jumpCurrentKey = jumpCurrentKey + 1
                jumpEnergy = jumpEnergy - 1
                if jumpEnergy MOD 5 = 0 then 
                    printLife()
                end if
                return
            end if
            
            jumpCurrentKey = jumpStopValue ' stop jumping
            if jumpEnergy = 0 then
                printLife()
            end if                     
        end Sub
    #endif
    
    Function isFalling() As Ubyte
        If canMoveDown() Then
            #ifdef JETPACK_FUEL
				if pressingUp() then
                    jumpCurrentKey = 0
				end if
            #endif
            Return 1
        Else
            If landed = 0 Then
                landed = 1
                #ifdef JETPACK_FUEL
                    jumpEnergy = jumpStepsCount
                    printLife()
                #endif
                If protaY bAND 1 <> 0 Then
                    ' saveSpriteLin(PROTA_SPRITE, protaY - 1)
                    protaY = protaY - 1
                End If
                resetProtaSpriteToRunning()
            End If
            Return 0
        End If
    End Function
    
    Sub gravity()
        If jumpCurrentKey = jumpStopValue And isFalling() Then
            If protaY >= MAX_LINE Then
                moveScreen = 2
            Else
                #ifndef JETPACK_FUEL
                    saveSprite(PROTA_SPRITE, protaY + 2, protaX, getNextFrameJumpingFalling(), protaDirection)
				#else
                    saveSprite(PROTA_SPRITE, protaY + 1, protaX, getNextFrameJumpingFalling(), protaDirection)
                #endif
            End If
            landed = 0
        End If
    End Sub
#endif

#ifdef SIDE_VIEW
    Sub shoot()
        If Not noKeyPressedForShoot Then Return
        noKeyPressedForShoot = 0
        
        If bulletPositionX <> 0 Then Return
        
        #ifdef AMMO_ENABLED
            If currentAmmo = 0 Then Return
            currentAmmo = currentAmmo - 1
            printLife()
        #endif
        
        currentBulletSpriteId = BULLET_SPRITE_RIGHT_ID
        If protaDirection Then
            #ifdef IDLE_ENABLED
                saveSprite(PROTA_SPRITE, protaY, protaX, 1, 1)
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
                saveSprite(PROTA_SPRITE, protaY, protaX, 5, 0)
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

#ifdef OVERHEAD_VIEW
    Sub shoot()
        If Not noKeyPressedForShoot Then Return
        
        noKeyPressedForShoot = 0
        
        #ifdef AMMO_ENABLED
            If currentAmmo = 0 Then Return
            currentAmmo = currentAmmo - 1
            printLife()
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

Sub leftKey()
    If protaDirection <> 0 Then
        #ifdef SIDE_VIEW
            protaFrame = 4
        #Else
            protaFrame = 2
        #endif
        spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 0
    End If
    
    If onFirstColumn(PROTA_SPRITE) Then
        #ifdef ARCADE_MODE
            protaX = 60
            Return
        #Else
            moveScreen = 4
        #endif
    Elseif canMoveLeft()
        saveSprite(PROTA_SPRITE, protaY, protaX - 1, protaFrame + 1, 0)
    End If
End Sub

Sub rightKey()
    If protaDirection <> 1 Then
        protaFrame = 0
        spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 1
    End If
    
    If onLastColumn(PROTA_SPRITE) Then
        #ifdef ARCADE_MODE
            protaX = 0
            Return
        #Else
            moveScreen = 6
        #endif
    Elseif canMoveRight()
        saveSprite(PROTA_SPRITE, protaY, protaX + 1, protaFrame + 1, 1)
    End If
End Sub

Sub upKey()
    #ifdef SIDE_VIEW
        jump()
    #Else
        If protaDirection <> 8 Then
            protaFrame = 4
            spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 8
        End If
        If canMoveUp() Then
            saveSprite(PROTA_SPRITE, protaY - 1, protaX, protaFrame + 1, 8)
            If protaY < 2 Then
                moveScreen = 8
            End If
        End If
    #endif
End Sub

Sub downKey()
    #ifdef OVERHEAD_VIEW
        If protaDirection <> 2 Then
            protaFrame = 6
            spritesLinColTileAndFrame(PROTA_SPRITE, 3) = 2
        End If
        If canMoveDown() Then
            If protaY >= MAX_LINE Then
                #ifndef ARCADE_MODE
                    moveScreen = 2
                #endif
            Else
                saveSprite(PROTA_SPRITE, protaY + 1, protaX, protaFrame + 1, 2)
            End If
        End If
    #Else
        If CheckStaticPlatform(protaX, protaY + 4) Or CheckStaticPlatform(protaX + 1, protaY + 4) Or CheckStaticPlatform(protaX + 2, protaY + 4) Then
            protaY = protaY + 2
        End If
    #endif
End Sub

Sub fireKey()
    #ifdef SHOOTING_ENABLED
        shoot()
    #endif
End Sub

Sub keyboardListen()
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
    If tile = ITEM_TILE Then
        #ifndef ARCADE_MODE
            If Not screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) Then
                Return 0
            End If
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
            If currentItems = itemsToFind Then
                drawKey()
            End If
        #Else
            If currentItems = GOAL_ITEMS Then
                ending()
            End If
        #endif
        screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX) = 0
        BeepFX_Play(5)
        Return 1
        #ifdef KEYS_ENABLED
        Elseif tile = KEY_TILE And screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) Then
            #ifdef ARCADE_MODE
                If currentScreen = SCREENS_COUNT Then
                    ending()
                Else
                    moveScreen = 6
                    Return 1
                End If
            #endif
            currentKeys = currentKeys + 1
            printLife()
            screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX) = 0
            BeepFX_Play(3)
            Return 1
        #endif
    Elseif tile = LIFE_TILE And screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) Then
        currentLife = currentLife + LIFE_AMOUNT
        printLife()
        screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX) = 0
        BeepFX_Play(6)
        Return 1
        #ifdef AMMO_ENABLED
        Elseif tile = AMMO_TILE And screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) Then
            currentAmmo = currentAmmo + AMMO_INCREMENT
            printLife()
            screenObjects(currentScreen, SCREEN_OBJECT_AMMO_INDEX) = 0
            BeepFX_Play(6)
            Return 1
        #endif
    End If
    Return 0
End Function

Sub checkObjectContact()
    Dim col As Ubyte = protaX >> 1
    Dim lin As Ubyte = protaY >> 1
    
    If checkTileObject(GetTile(col, lin)) Then
        FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col, lin)
        Return
    Elseif checkTileObject(GetTile(col + 1, lin))
        FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + 1, lin)
        Return
    Elseif checkTileObject(GetTile(col, lin + 1))
        FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col, lin + 1)
        Return
    Elseif checkTileObject(GetTile(col + 1, lin + 1))
        FillWithTileChecked(0, 1, 1, BACKGROUND_ATTRIBUTE, col + 1, lin + 1)
        Return
    End If
End Sub

Sub checkDamageByTile()
    If invincible Then Return
    
    Dim col As Ubyte = protaX >> 1
    Dim lin As Ubyte = protaY >> 1
    
    If isADamageTile(GetTile(col, lin)) Then
        decrementLife()
        Return
    End If
    If isADamageTile(GetTile(col + 1, lin)) Then
        decrementLife()
        Return
    End If
    If isADamageTile(GetTile(col, lin + 1)) Then
        decrementLife()
        Return
    End If
    If isADamageTile(GetTile(col + 1, lin + 1)) Then
        decrementLife()
        Return
    End If
End Sub

Sub protaMovement()
    #ifdef LIVES_MODE_GRAVEYARD
        if invincible Then Return
    #endif
    
    If MultiKeys(keyArray(FIRE)) = 0 Then
        noKeyPressedForShoot = 1
    End If
    keyboardListen()
    checkObjectContact()
    
    #ifdef SIDE_VIEW
        #ifndef JETPACK_FUEL
            checkIsJumping()
        #Else
            checkIsFlying()
        #endif
        gravity()
        
        #ifdef IDLE_ENABLED
            If protaLoopCounter >= IDLE_TIME Then
                If jumpCurrentKey <> jumpStopValue Then Return
                If isFalling() Then Return
                
                If framec - lastFrameTiles = ANIMATE_PERIOD_TILE - 2 Then
                    If getSpriteTile(PROTA_SPRITE) = 13 Then
                        saveSprite(PROTA_SPRITE, protaY, protaX, 14, protaDirection)
                    Else
                        saveSprite(PROTA_SPRITE, protaY, protaX, 13, protaDirection)
                    End If
                End If
            End If
        #endif
    #endif
End Sub