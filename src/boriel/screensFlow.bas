Sub showMenu()
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            VortexTracker_Stop()
        #endif
    #endif
    inMenu = 1
    Ink 7: Paper 0: Border 0: BRIGHT 0: FLASH 0: Cls
    #ifdef ENABLED_128k
        PaginarMemoria(DATA_BANK)
        dzx0Standard(TITLE_SCREEN_ADDRESS, $4000)
        PaginarMemoria(0)
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_TITLE_ENABLED
                VortexTracker_Play(MUSIC_TITLE_ADDRESS)
            #endif
        #endif
    #Else
        dzx0Standard(TITLE_SCREEN_ADDRESS, $4000)
    #endif
    
    #ifdef HISCORE_ENABLED
        Ink getFirstCharInk(): Paper getFirstCharPaper(): Bright getFirstCharBright()
        Print AT 23, 6; "HI:"
        Print AT 23, 9; "00000"
        Print AT 23, 14 - LEN(STR$(hiScore)); hiScore
    #endif
    
    Do
        kempston = 0
        If MultiKeys(KEY1) Then
            If Not keyArray(LEFT) Then
                Let keyArray(LEFT) = KEYO
                Let keyArray(RIGHT) = KEYP
                Let keyArray(UP) = KEYQ
                Let keyArray(DOWN) = KEYA
                Let keyArray(FIRE) = KEYSPACE
            End If
            playGame()
        elseif MultiKeys(KEY2) Then
            kempston = 1
            playGame()
        elseif MultiKeys(KEY3) Then
            Let keyArray(LEFT)=KEY6
            Let keyArray(RIGHT)=KEY7
            Let keyArray(UP)=KEY9
            Let keyArray(DOWN)=KEY8
            Let keyArray(FIRE)=KEY0
            playGame()
            #ifdef REDEFINE_KEYS_ENABLED
            elseif MultiKeys(KEY4) Then
                redefineKeys()
            #endif
        elseif kempstonInterfaceAvailable Then
            Dim n As Ubyte = In(31)
            
            If n bAND %10000 Then
                kempston = 1
                playGame()
            End If
        End If
    Loop
End Sub


#ifdef PASSWORD_ENABLED
    Function readKey() As Ubyte
        Let k = GetKey
        Let keyOption = chr(k)
        If keyOption = " " Then showMenu()
        Return k
    End Function
    
    Sub passwordScreen()
        Ink 7: Paper 0: Border 0: BRIGHT 0: FLASH 0: Cls
        Print AT 10, 10; "INSERT PASSWORD"
        Print AT 18, 0; "PRESS SPACE To Return To MENU"
        For i=0 To 7
            Print AT 12, 10 + i; "*"
        Next i
        
        Let keyOption = ""
        Dim pass(7) As Ubyte
        Dim passwordIndex As Ubyte = 0
        
        For i=0 To 7
            While GetKeyScanCode() <> 0
            Wend
            pass(i) = readKey()
            Print AT 12, 10 + i; chr(pass(i))
        Next i
        
        For i=0 To 7
            If chr(pass(i)) <> password(i) Then
                passwordScreen()
            End If
        Next i
        
        playGame()
    End Sub
#endif

#ifdef REDEFINE_KEYS_ENABLED
    Function LeerTecla() As Uinteger
        Do Loop While GetKeyScanCode()
        Do Loop Until GetKeyScanCode()
        Return GetKeyScanCode()
    End Function
    
    Sub redefineKeys()
        Ink 7: Paper 0: Border 0: BRIGHT 0: FLASH 0: Cls

        #ifdef ENABLED_128k
            #ifdef MUSIC_ENABLED
                #ifdef MUSIC_TITLE_ENABLED
                    VortexTracker_Stop()
                #endif
            #endif
        #endif
        
        doubleSizeTexto(96, 120, "KEYS")
        
        Print AT 13,8;"LEFT"
        keyArray(LEFT) = LeerTecla()
        
        Print AT 15,8;"RIGHT"
        keyArray(RIGHT) = LeerTecla()
        
        Print AT 17,8;"UP"
        keyArray(UP) = LeerTecla()
        
        Print AT 19,8;"DOWN"
        keyArray(DOWN) = LeerTecla()

        #ifdef SHOOTING_ENABLED
            Print AT 21,8;"FIRE"
            keyArray(FIRE) = LeerTecla()
        #endif
        
        showMenu()
    End Sub
#endif

Function skipScreenPressed() As Ubyte
    If kempstonInterfaceAvailable Then
        Dim n As Ubyte = In(31)
        If n bAND %10000 Then
            Return 1
        End If
    End If
    
    If MultiKeys(KEYENTER) Then
        Return 1
    End If
    
    Return 0
End Function

Sub playGame()
    inMenu = 0
    
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_TITLE_ENABLED
                VortexTracker_Stop()
            #endif
        #endif
    #endif
    
    #ifdef ENABLED_128k
        #ifdef INTRO_SCREEN_ENABLED
            PaginarMemoria(DATA_BANK)
            dzx0Standard(INTRO_SCREEN_ADDRESS, $4000)
            PaginarMemoria(0)
            #ifdef MUSIC_ENABLED
                #ifdef MUSIC_INTRO_ENABLED
                    VortexTracker_Play(MUSIC_INTRO_ADDRESS)
                #endif
            #endif
            Do
            Loop Until skipScreenPressed()
        #endif
    #endif
    
    Ink INK_VALUE: Paper PAPER_VALUE: Border BORDER_VALUE
    
    currentScreen = INITIAL_SCREEN
    
    #ifdef INIT_TEXTS
        For i=0 To 2
            showInitTexts(initTexts(i))
        Next i
    #endif
    
    #ifdef ENABLED_128k
        PaginarMemoria(DATA_BANK)
        dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
        PaginarMemoria(0)
        #ifndef ARCADE_MODE
            #ifdef MUSIC_ENABLED
                VortexTracker_Play(MUSIC_ADDRESS)
            #endif
        #endif
    #Else
        dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
    #endif

    #ifndef ARCADE_MODE
        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = INITIAL_MAIN_CHARACTER_X
            protaYRespawn = INITIAL_MAIN_CHARACTER_Y
        #endif
        
        saveProta(INITIAL_MAIN_CHARACTER_Y, INITIAL_MAIN_CHARACTER_X, 1, 1)
    #endif
    resetValues()
    swapScreen()
    
    #ifdef NEW_BEEPER_PLAYER
        Let lastFrameBeep = framec
    #endif
    
    #ifdef HISCORE_ENABLED
        Print AT HUD_HISCORE_Y, HUD_HISCORE_X; "00000"
        Print AT HUD_HISCORE_Y, HUD_HISCORE_X + 5 - LEN(STR$(hiScore)); hiScore
        Print AT HUD_HISCORE_Y + 1, HUD_HISCORE_X; "00000"
    #endif
    
    Do
        #ifdef ARCADE_MODE
            #ifdef HURRY_UP_SECONDS
                If timerSeconds > HURRY_UP_SECONDS Then
                    If currentItems = itemsToFind Then
                        printMessage(ARCADE_GOAL_LINE1, ARCADE_GOAL_LINE2, ARCADE_GOAL_PAPER, ARCADE_GOAL_INK)
                    End If
                End If
            #else
                If currentItems = itemsToFind Then
                    printMessage(ARCADE_GOAL_LINE1, ARCADE_GOAL_LINE2, ARCADE_GOAL_PAPER, ARCADE_GOAL_INK)
                End If
            #endif

            #ifdef ARCADE_MODE_RESET_ON_KILL
                If arcadeModeResetObjects Then
                    arcadeModeResetObjects = 0
                    clearKey()
                    mapDrawOnlyItems()
                    currentItems = 0
                    dzx0Standard(ENEMIES_DATA_ADDRESS + enemiesInScreenOffsets(currentScreen), arrayBasePtr(decompressedEnemiesScreen))
                End If
            #endif

            #ifdef ARCADE_MODE_SPRITE_ID
                If showKeySprite Then
                    Draw2x2Sprite(ARCADE_MODE_SPRITE_ID, currentScreenKeyX * 2, (currentScreenKeyY * 2) - 2)
                End If
            #endif
        #endif

        calculateIfSkipMovementBySpeed()

        #ifdef TIMER_ENABLED
            updateTimer()
        #endif
        
        If lastFrameOnBreakableTiles <> 0 Then
            If framec - lastFrameOnBreakableTiles >= BREAKABLE_BY_TOUCH_TILE_FRAMES Then
                lastFrameOnBreakableTiles = 0
                replaceTileWithBackground(tileToBreakByTouchX, tileToBreakByTouchY)
                BeepFX_Play(0)
            End If
        End If

        If resetBorder Then
            Border BORDER_VALUE
            resetBorder = 0
        End If
        
        protaMovement()
        checkDamageByTile()
        moveEnemies()
        #ifdef SHOOTING_ENABLED
            moveBullet()
        #endif
        drawSprites()

        RenderFrame()

        makeAnimations()
        
        If moveScreen <> 0 Then
            moveToScreen(moveScreen)
            moveScreen = 0
        End If
        
        If currentLife = 0 Then gameOver()
        
        If invincible Then
            If framec - invincibleFrame >= INVINCIBLE_FRAMES Then
                invincible = 0
                invincibleFrame = 0
            End If

            #ifdef LIVES_MODE_GRAVEYARD
                if Not invincible Then saveProta(protaYRespawn, protaXRespawn, 1, protaDirection)
            #endif
        End If
        
        #ifdef NEW_BEEPER_PLAYER
            If framec - lastFrameBeep >= BEEP_PERIOD Then
                BeepFX_NextNote()
                Let lastFrameBeep = framec
            End If
        #endif

        #ifndef ARCADE_MODE
            checkGameObjective()
        #endif

        mainLoopCounter = mainLoopCounter + 1
    Loop
End Sub

#ifdef ARCADE_MODE
    #ifdef HISCORE_ENABLED
        Sub showIntermediateScreen()
            VortexTracker_Stop()
            clearScreen()

            Dim tinta As Ubyte = BACKGROUND_ATTRIBUTE bAND 7
            Dim papel As Ubyte = (BACKGROUND_ATTRIBUTE bAND 56) / 8
            Dim brillante As Ubyte = (BACKGROUND_ATTRIBUTE bAND 64) / 64
            Ink tinta: Paper papel: Bright brillante

            Dim currentLives As Ubyte = currentLife

            Print At 6, 8; "TIME LEFT:      ";
            Print At 6, 24 - LEN(STR$(timerSeconds)); timerSeconds

            Print AT 8, 8; "LIVES LEFT:    ";
            Print AT 8, 24 - LEN(STR$(currentLives)); currentLives

            Print AT 10, 8; "SCORE:          ";
            Print AT 10, 24 - LEN(STR$(score)); score

            doubleSizeTexto(10, 160, "SCREEN CLEARED!")
            ' Print current score and remaining time and subtractr second and increase score
            #ifdef TIMER_ENABLED
                protaX = 30
                protaY = 26
                protaTile = PROTA_IDLE_SPRITE_ID

                While timerSeconds > 0
                    timerSeconds = timerSeconds - 1
                    incrementScore(1)

                    Print At 6, 8; "TIME LEFT:      ";
                    Print At 6, 24 - LEN(STR$(timerSeconds)); timerSeconds

                    Print AT 10, 8; "SCORE:          ";
                    Print AT 10, 24 - LEN(STR$(score)); score
                    Beep .01, 12

                    protaTile = getNextProtaIdleSprite()
                    Draw2x2Sprite(protaTile, protaX, protaY)
                    RenderFrame()
                Wend

                While currentLives > 0
                    currentLives = currentLives - 1
                    incrementScore(50)

                    Print AT 8, 8; "LIVES LEFT:    ";
                    Print AT 8, 24 - LEN(STR$(currentLives)); currentLives

                    Print AT 10, 8; "SCORE:          ";
                    Print AT 10, 24 - LEN(STR$(score)); score
                    Beep .01, 12

                    protaTile = getNextProtaIdleSprite()
                    Draw2x2Sprite(protaTile, protaX, protaY)
                    RenderFrame()
                Wend

                Ink INK_VALUE: Paper PAPER_VALUE: Border BORDER_VALUE
                printScore()
                Ink tinta: Paper papel: Bright brillante

                Flash 1
                Print AT 18, 4; "PRESS ENTER To Continue"
                Flash 0

                If score > hiScore Then
                    hiScore = score
                End If
            #endif

            Do
                animateProtaForIntermediateScreen()
            Loop Until skipScreenPressed()

            #ifndef ARCADE_MODE     
                If music2alreadyPlayed = 0 Then
                    VortexTracker_Play(MUSIC_ADDRESS)
                Else If music2alreadyPlayed = 1 And music3alreadyPlayed = 0 Then
                    VortexTracker_Play(MUSIC_2_ADDRESS)
                Else If music3alreadyPlayed = 1 Then
                    VortexTracker_Play(MUSIC_3_ADDRESS)
                End If
            #endif

            Ink INK_VALUE: Paper PAPER_VALUE: Border BORDER_VALUE

            If currentScreen <= SCREENS_COUNT Then
                swapScreen()
            Else
                ending()
            End If
        End Sub

        Sub animateProtaForIntermediateScreen()
            If framec mod 50 = 0 Then
                protaTile = getNextProtaIdleSprite()
            End If
            Draw2x2Sprite(protaTile, protaX, protaY)
            RenderFrame()
        End Sub
    #endif
#else
    Sub checkGameObjective()
        #ifdef FINISH_GAME_OBJECTIVE_ITEM
            If currentItems = GOAL_ITEMS Then
                ending()
            End If
        #endif

        #ifdef FINISH_GAME_OBJECTIVE_ENEMY
            If enemyToKillAlreadyKilled Then
                ending()
            End If
        #endif

        #ifdef FINISH_GAME_OBJECTIVE_ITEMS_AND_ENEMY
            If currentItems = GOAL_ITEMS Then
                If enemyToKillAlreadyKilled Then
                    ending()
                End If
            End If
        #endif
    End Sub
#endif

Sub calculateIfSkipMovementBySpeed()
    skipMove0 = 0
    skipMove1 = 0
    skipMove2 = 0

    If mainLoopCounter bAnd 7 <> 0 Then skipMove0 = 1   ' 1 de cada 8 loops (slowest)
    If mainLoopCounter bAnd 3 <> 0 Then skipMove1 = 1   ' 1 de cada 4 loops
    If mainLoopCounter bAnd 1 <> 0 Then skipMove2 = 1   ' 1 de cada 2 loops
End Sub

Sub makeAnimations()
    If framec - lastFrameProta >= ANIMATE_PERIOD_MAIN Then
        protaFrame = getNextFrameRunning()
        Let lastFrameProta = framec
    End If
    
    If framec - lastFrameEnemies >= ANIMATE_PERIOD_ENEMY Then
        animateEnemies()
        Let lastFrameEnemies = framec
    End If
    
    If framec - lastFrameTiles >= ANIMATE_PERIOD_TILE Then
        animateAnimatedTiles()
        #ifdef IDLE_ENABLED
            animateIdle()
        #endif
        Let lastFrameTiles = framec
    End If
End sub

Sub ending()
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_ENDING_ENABLED
                VortexTracker_Play(MUSIC_ENDING_ADDRESS)
            #endif
            #ifndef MUSIC_ENDING_ENABLED
                VortexTracker_Stop()
            #endif
        #endif
        PaginarMemoria(DATA_BANK)
        dzx0Standard(ENDING_SCREEN_ADDRESS, $4000)
        PaginarMemoria(0)
    #Else
        dzx0Standard(ENDING_SCREEN_ADDRESS, $4000)
    #endif
    Do
    Loop Until skipScreenPressed()
    showMenu()
End Sub

Sub gameOver()
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            #ifdef MUSIC_GAMEOVER_ENABLED
                VortexTracker_Play(MUSIC_GAMEOVER_ADDRESS)
            #endif
            #ifndef MUSIC_GAMEOVER_ENABLED
                VortexTracker_Stop()
            #endif
        #endif
    #endif
    
    #ifdef NEW_BEEPER_PLAYER
        BeepFX_Reset()
    #endif
    
    #ifdef ENABLED_128k
        #ifdef GAMEOVER_SCREEN_ENABLED
            PaginarMemoria(DATA_BANK)
            dzx0Standard(GAMEOVER_SCREEN_ADDRESS, $4000)
            PaginarMemoria(0)
        #Else
            saveProta(protaY, protaX, 15, 0)
            Print AT 7, 12; "GAME OVER"
        #endif
    #Else
        saveProta(protaY, protaX, 15, 0)
        Print at 7, 12; "GAME OVER"
    #endif
    
    Do
    Loop Until skipScreenPressed()
    showMenu()
End Sub

Sub resetValues()
    #ifdef SHOOTING_ENABLED
        bulletPositionX = 0
    #endif
    #ifdef SIDE_VIEW
        jumpCurrentKey = jumpStopValue
    #endif
    
    invincible = 0
    invincibleBlink = 0
    invincibleFrame = 0
    
    currentLife = INITIAL_LIFE
    currentKeys = 2 Mod 2
    currentKeys = 0
    moveScreen = 0

    #ifdef USE_BREAKABLE_TILE_INDIVIDUAL
        For i = 0 To BREAKABLE_TILES_COUNT
            brokenTiles(i, 0) = 0
            brokenTiles(i, 1) = 0
            brokenTiles(i, 2) = 0
        Next i
    #endif

    For i = 0 To SCREEN_OBJECTS_COUNT
        screenObjects(i, 1) = 0
        screenObjects(i, 2) = 0
        screenObjects(i, 3) = 0
        screenObjects(i, 4) = 0
    Next i

    #ifdef ARCADE_MODE
        currentItems = 0
    #Else
        If ITEMS_COUNTDOWN Then
            currentItems = itemsToFind
        Else
            currentItems = 0
        End If
    #endif

    #ifdef LIVES_MODE_ENABLED
        protaXRespawn = INITIAL_MAIN_CHARACTER_X
        protaYRespawn = INITIAL_MAIN_CHARACTER_Y
    #endif

    For i = 0 To SCREENS_COUNT
        screensWon(i) = 0
    Next i
    #ifdef USE_BREAKABLE_TILE_ALL
        For i = 0 To SCREENS_COUNT
            brokenTiles(i) = 0
        Next i
    #endif
    #ifdef HISCORE_ENABLED
        score = 0
    #endif
    
    currentAmmo = INITIAL_AMMO
    
    brokenTilesCurrentIndex = 0
    screenObjectsCurrentIndex = 0

    #ifdef MUSIC_2_ENABLED
        music2alreadyPlayed = 0
    #endif
    #ifdef MUSIC_3_ENABLED
        music3alreadyPlayed = 0
    #endif

    #ifdef TIMER_ENABLED
        resetTimer()
    #endif
    #ifdef FINISH_GAME_OBJECTIVE_ENEMY
        enemyToKillAlreadyKilled = 0
    #endif
    #ifdef FINISH_GAME_OBJECTIVE_ITEMS_AND_ENEMY
        enemyToKillAlreadyKilled = 0
    #endif
End Sub

Sub swapScreen()
    dzx0Standard(MAPS_DATA_ADDRESS + screensOffsets(currentScreen), arrayBasePtr(decompressedMap))
    dzx0Standard(ENEMIES_DATA_ADDRESS + enemiesInScreenOffsets(currentScreen), arrayBasePtr(decompressedEnemiesScreen))
    #ifdef SHOOTING_ENABLED
        bulletPositionX = 0
    #endif
    #ifdef ARCADE_MODE
        countItemsOnTheScreen()
        saveProta(mainCharactersArray(currentScreen, 1), mainCharactersArray(currentScreen, 0), 1, 1)

        #ifdef LIVES_MODE_ENABLED
            protaXRespawn = mainCharactersArray(currentScreen, 0)
            protaYRespawn = mainCharactersArray(currentScreen, 1)
        #endif
    #endif

    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            #ifdef ARCADE_MODE
                dim musicNumber as ubyte = musicPerScreenArray(currentScreen)
                If musicNumber = 1 Then
                    VortexTracker_Play(MUSIC_ADDRESS)
                ElseIf musicNumber = 2 Then
                    VortexTracker_Play(MUSIC_2_ADDRESS)
                ElseIf musicNumber = 3 Then
                    VortexTracker_Play(MUSIC_3_ADDRESS)
                End If
            #else
                #ifdef MUSIC_2_ENABLED
                    If currentScreen = MUSIC_2_SCREEN_ID Then
                        If music2alreadyPlayed = 0 Then
                            VortexTracker_Play(MUSIC_2_ADDRESS)
                            music2alreadyPlayed = 1
                        End If
                    End If
                #endif
                #ifdef MUSIC_3_ENABLED
                    If currentScreen = MUSIC_3_SCREEN_ID Then
                        If music3alreadyPlayed = 0 Then
                            VortexTracker_Play(MUSIC_3_ADDRESS)
                            music3alreadyPlayed = 1
                        End If
                    End If
                #endif
            #endif
        #endif
    #endif

    #ifdef TIMER_ENABLED
        resetTimer()
        updateTimerDisplay()
    #endif
    redrawScreen()
End Sub