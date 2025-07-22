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
        Print AT 0, 22; "HI:"
        Print AT 0, 26; hiScore
    #endif
    
    Do
        Dim n As Ubyte = In(31)

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
        elseif n bAND %10000 Then
            kempston = 1
            playGame()
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
        
        Print AT 8,10;"<"
        keyArray(LEFT) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 8,20; keyOption
        
        Print AT 10,10;">"
        keyArray(RIGHT) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 10,20; keyOption
        
        Print AT 12,10;"^"
        keyArray(UP) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 12,20; keyOption
        
        Print AT 14,10;"v"
        keyArray(DOWN) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 14,20; keyOption
        
        Print AT 16,10;"Fire"
        keyArray(FIRE) = LeerTecla()
        ' keyOption = Inkey$
        ' Print AT 16,20; keyOption
        '
        ' keyOption = ""
        
        showMenu()
    End Sub
#endif

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
            Do
            Loop Until MultiKeys(KEYENTER) Or (In(31) bAND %10000)
        #endif
    #endif
    
    Ink INK_VALUE: Paper PAPER_VALUE: Border BORDER_VALUE
    
    #ifdef ARCADE_MODE
        currentScreen = 0
    #Else
        currentScreen = INITIAL_SCREEN
    #endif
    
    #ifdef INIT_TEXTS
        For i=0 To 2
            showInitTexts(initTexts(i))
        Next i
    #endif
    
    #ifdef ENABLED_128k
        PaginarMemoria(DATA_BANK)
        dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
        PaginarMemoria(0)
        #ifdef MUSIC_ENABLED
            VortexTracker_Play(MUSIC_ADDRESS)
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
    
    Let lastFrameProta = framec
    Let lastFrameEnemies = framec
    Let lastFrameTiles = framec
    
    #ifdef NEW_BEEPER_PLAYER
        Let lastFrameBeep = framec
    #endif
    
    #ifdef HISCORE_ENABLED
        Print AT 22, 20; "00000"
        PRINT AT 22, 25 - LEN(STR$(hiScore)); hiScore
        Print AT 23, 20; "00000"
    #endif
    
    Do
        waitretrace
        
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
            Let lastFrameTiles = framec
        End If
        
        protaMovement()
        checkDamageByTile()
        moveEnemies()
        moveBullet()
        drawSprites()
        
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
    Loop
End Sub

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
    Loop Until MultiKeys(KEYENTER) Or (In(31) bAND %10000)
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
    Loop Until MultiKeys(KEYENTER) Or (In(31) bAND %10000)
    showMenu()
End Sub

Sub resetValues()
    bulletPositionX = 0
    #ifdef SIDE_VIEW
        jumpCurrentKey = jumpStopValue
    #endif
    
    invincible = 0
    invincibleBlink = 0
    invincibleFrame = 0
    
    currentLife = INITIAL_LIFE
    currentKeys = 2 Mod 2
    currentKeys = 0

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

    enemiesPerScreen = enemiesPerScreenInitial
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
End Sub

Sub swapScreen()
    dzx0Standard(MAPS_DATA_ADDRESS + screensOffsets(currentScreen), @decompressedMap)
    dzx0Standard(ENEMIES_DATA_ADDRESS + enemiesInScreenOffsets(currentScreen), @decompressedEnemiesScreen)
    bulletPositionX = 0
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
    redrawScreen()
End Sub