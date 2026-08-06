#define pauseUntilPressKey() while INKEY$<>"":wend : while INKEY$="":wend

#ifdef LIVES_MODE_ENABLED
    #define printLife() PrintString("  ", 7, HUD_LIFE_X, HUD_LIFE_Y) : PrintString(STR$(currentLife), 7, HUD_LIFE_X, HUD_LIFE_Y)
#else
    #define printLife() PrintString("   ", 7, HUD_LIFE_X, HUD_LIFE_Y) : PrintString(STR$(currentLife), 7, HUD_LIFE_X, HUD_LIFE_Y)
#endif

#ifdef TIMER_ENABLED
    Sub resetTimer()
        timerSeconds = initialTimerSeconds
        #ifdef HURRY_UP_SECONDS
            vortexTracker2x = 0
        #endif
    End Sub
#endif

sub decrementLife()
    #ifdef MAIN_CHARACTER_INVINCIBLE
        return
    #endif
    
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
                lastFrameOnBreakableTiles = 0
            #endif
            
            #ifdef LIVES_MODE_RESPAWN
                saveProta(protaYRespawn, protaXRespawn, 1, protaDirection)
                lastFrameOnBreakableTiles = 0
            #endif
            
            #ifdef TIMER_ENABLED
                resetTimer()
                updateTimerDisplay()
            #endif
            
            #ifdef ARCADE_MODE
                #ifdef ARCADE_MODE_RESET_ON_KILL
                    arcadeModeResetObjects = 1
                    #ifdef ARCADE_MODE_SPRITE_ID
                        showKeySprite = 0
                    #endif
                #endif
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

sub printHud()
    printLife()
    
    #ifdef JETPACK_FUEL
        PrintString("  ", 7, HUD_JETPACK_FUEL_X, HUD_JETPACK_FUEL_Y)
        PrintString(STR$(jumpEnergy), 7, HUD_JETPACK_FUEL_X, HUD_JETPACK_FUEL_Y)
    #endif
    #ifdef AMMO_ENABLED
        PrintString("   ", 7, HUD_AMMO_X, HUD_AMMO_Y)
        PrintString(STR$(currentAmmo), 7, HUD_AMMO_X, HUD_AMMO_Y)
    #endif
    #ifndef ARCADE_MODE
        #ifdef KEYS_ENABLED
            PrintString(STR$(currentKeys), 7, HUD_KEYS_X, HUD_KEYS_Y)
        #endif
    #endif
    #ifdef HISCORE_ENABLED
        printScore()
    #endif
    #ifndef ARCADE_MODE
        #ifdef ITEMS_ENABLED
            PrintString("  ", 7, HUD_ITEMS_X, HUD_ITEMS_Y)
            PrintString(STR$(currentItems), 7, HUD_ITEMS_X, HUD_ITEMS_Y)
        #endif
    #endif
    #ifdef CURRENT_STAGE_ENABLED
        PrintString("  ", 7, HUD_STAGE_X, HUD_STAGE_Y)
        PrintString(STR$(currentScreen + 1), 7, HUD_STAGE_X, HUD_STAGE_Y)
    #endif
end sub



#ifdef HISCORE_ENABLED
    Sub printScore()
        PrintString("00000", 7, HUD_HISCORE_X, HUD_HISCORE_Y)
        PrintString(STR$(hiScore), 7, HUD_HISCORE_X + 5 - LEN(STR$(hiScore)), HUD_HISCORE_Y)
        PrintString("00000", 7, HUD_HISCORE_X, HUD_HISCORE_Y_2)
        PrintString(STR$(score), 7, HUD_HISCORE_X + 5 - LEN(STR$(score)), HUD_HISCORE_Y_2)
    End Sub
#endif

#ifdef TIMER_ENABLED
    Sub updateTimerDisplay()
        PrintString(" :", 7, HUD_TIMER_X, HUD_TIMER_Y)
        PrintString(STR$(timerSeconds / 60), 7, HUD_TIMER_X, HUD_TIMER_Y)
        
        Dim timerSecondsRemaining as Ubyte = timerSeconds MOD 60
        
        If timerSecondsRemaining < 10 Then
            PrintString("0", 7, HUD_TIMER_X + 2, HUD_TIMER_Y)
            PrintString(STR$(timerSecondsRemaining), 7, HUD_TIMER_X + 3, HUD_TIMER_Y)
        Else
            PrintString(STR$(timerSecondsRemaining), 7, HUD_TIMER_X + 2, HUD_TIMER_Y)
        End If
    End Sub
    Sub updateTimer()
        If framec - lastFrameTimer > 50 Then
            lastFrameTimer = framec
            
            If timerSeconds = 0 Then
                #ifdef LIVES_MODE_ENABLED
                    decrementLife()
                #else
                    currentLife = 0
                #endif
            Else
                timerSeconds = timerSeconds - 1
                #ifdef HURRY_UP_SECONDS
                    If timerSeconds < 31 Then
                        vortexTracker2x = 1
                        #ifdef HURRY_UP_LINE1
                            printMessage(HURRY_UP_LINE1, HURRY_UP_LINE2, HURRY_UP_PAPER, HURRY_UP_INK)
                        #endif
                    End If
                #endif
            End If
            
            updateTimerDisplay()
        End If
    End Sub
#endif

#ifdef MESSAGES_ENABLED
    sub printMessage(line1 as string, line2 as string, p as ubyte, i as ubyte)
        If line1 = "" AND line2 = "" Then Return
        
        Paper p: Ink i: Flash MESSAGES_FLASH_ENABLED
        PrintString(line1, 7, HUD_MESSAGE_X, HUD_MESSAGE_Y)
        PrintString(line2, 7, HUD_MESSAGE_X, HUD_MESSAGE_Y_2)
        Paper PAPER_VALUE: Ink INK_VALUE: Flash 0
        messageLoopCounter = 0
    end sub
    
    sub checkMessageForDelete()
        If messageLoopCounter = MESSAGE_LOOPS_VISIBLE Then
            clearMessage()
        ElseIf messageLoopCounter < MESSAGE_LOOPS_VISIBLE Then
            messageLoopCounter = messageLoopCounter + 1
        End If
    end sub
    
    Sub clearMessage()
        Paper MESSAGE_DEFAULT_PAPER: Ink MESSAGE_DEFAULT_INK: Flash 0
        PrintString("        ", 7, HUD_MESSAGE_X, HUD_MESSAGE_Y)
        PrintString("        ", 7, HUD_MESSAGE_X, HUD_MESSAGE_Y_2)
        Paper PAPER_VALUE: Ink INK_VALUE: Flash 0
    End Sub
#endif

#ifdef HISCORE_ENABLED
    Sub incrementScore(amount As Ubyte)
        score = score + amount
        If score > hiScore Then
            hiScore = score
        End If
    End Sub
#endif

Function isDamageTileByColLin(col as Ubyte, lin as Ubyte) As Ubyte
    Dim tile as Ubyte = GetTile(col, lin)
    DIM basePtr as UInteger = arrayBasePtr(damageTiles)
    Dim i as Ubyte
    
    For i = 0 to DAMAGE_TILES_COUNT
        If peek(basePtr + i) = tile Then
            Return tile
        End If
    Next i
    
    Return 0
End Function

function allEnemiesKilled() as ubyte
    if enemiesPerScreen(currentScreen) = 0 then return 1
    
    Dim enemyId As Ubyte
    Dim life As Ubyte
    for enemyId = 0 TO enemiesPerScreen(currentScreen) - 1
        if decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 then
            continue for
        end if
        life = decompressedEnemiesScreen(enemyId, ENEMY_LIFE)
        if life > 0 and life <> 99 then
            return 0
        end if
    next enemyId
    
    return 1
end function

function isSolidTileByColLin(col as ubyte, lin as ubyte) as ubyte
    dim tile as ubyte = GetTile(col, lin)
    
    if tile > 63 then return 0
    if tile < 1 then return 0

    #ifdef USE_BREAKABLE_TILE_BY_TOUCH
        If tile = BREAKABLE_BY_TOUCH_TILE Then
            If lastFrameOnBreakableTiles = 0 Then
                lastFrameOnBreakableTiles = framec
                
                tileToBreakByTouchX = col
                tileToBreakByTouchY = lin
            End If
        End If
    #endif
    
    return tile
end function

#ifdef ARCADE_MODE
    sub countItemsOnTheScreen()
        dim index, y, x as integer
        Dim basePtr as UInteger
        
        x = 0
        y = 0
        basePtr = arrayBasePtr(decompressedMap)
        
        itemsToFind = 0
        currentItems = 0
        for index=0 to SCREEN_LENGTH
            if peek(basePtr + index) - 1 = ITEM_TILE then
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

#ifdef ARCADE_MODE
    #ifdef HISCORE_ENABLED
        #ifdef ARCADE_SHOW_BIG_INTERMEDIATE_TITLE
            Sub doubleSize8x8(x AS Ubyte, y As Ubyte, dir AS Uinteger)
                ' Variables locales
                DIM xx, yy, nx, ny, b, a AS UByte
                ' En pixels 0,0 está abajo a la izquierda, así que
                ' invertimos el valor de y
                yy = y + 14
                ' 8 filas (8 bytes)
                FOR ny = 0 TO 7
                    ' Invertimos x
                    xx = x + 14
                    ' Leemos el valor del byte
                    b = PEEK(dir)
                    ' Procesamos el carácter (1 byte)
                    FOR nx = 0 TO 7
                        ' Tomamos el bit 0
                        a = b bAND %1
                        ' Desplazamos el byte a la derecha
                        b = b >> 1
                        ' Si el bit 0 es 0
                        ' Modo borrar = inverso del bit
                        INVERSE 1 - a
                        ' Dibujamos 4 puntos (2x2)
                        PLOT xx,yy
                        PLOT xx+1,yy
                        PLOT xx,yy+1
                        PLOT xx+1,yy+1
                        ' Desplazamos "x" 2 pixels
                        xx = xx - 2
                    NEXT nx
                    ' Siguiente byte
                    dir = dir + 1
                    ' Desplazamos "y" 2 pixels
                    yy = yy - 2
                NEXT ny
                ' Reseteamos el inverse
                INVERSE 0
            End Sub

            Sub doubleSizeTexto(x As Ubyte, y As Ubyte, texto As String)
                DIM dir AS UInteger
                DIM n, c, xx AS UByte
                ' Sacamos una copia de x
                xx = x
                ' Recorremos la cadena letra a letra
                FOR n = 0 TO LEN(texto)-1
                    ' Dirección del carácter
                    dir = PEEK(UInteger, 23606)
                    ' Código ASCII del carácter
                    c = CODE texto(n)
                    ' Calculamos la dirección del carácter en memoria
                    dir = dir + (CAST(UInteger,c) * 8)
                    ' Imprimimos el carácter a doble tamaño
                    doubleSize8x8(xx,y,dir)
                    ' Incrementamos c en 16 pixels
                    xx = xx + 16
                NEXT n
            End Sub
        #endif
    #endif
#endif

#ifdef SIDE_VIEW
    Function checkTravesablePlatformType(x as uByte, y as uByte, maxTile as Ubyte) as uByte
        Dim tile as Ubyte = GetTile(x >> 1, y >> 1)
        
        If tile < 64 Then Return 0
        If tile > maxTile Then Return 0
        
        Return 1
    End Function
    
    #define checkTravesablePlatformFromTop(x, y) checkTravesablePlatformType(x, y, 65)
    #define checkTravesablePlatform(x, y) checkTravesablePlatformType(x, y, 69)
    #define checkTravesablePlatformFromTopAndAll(x, y) checkTravesablePlatformType(x, y, 67)
#endif

'type 0 Damage, 1 Solid, 2 Ladder
Function checkTypeOfTile(col as uByte, lin as uByte, type as Ubyte) as uByte
    If type = 1 Then
        Return isSolidTileByColLin(col, lin)
    End If
    If type = 0 Then
        Return isDamageTileByColLin(col, lin)
    End If
    #ifdef SIDE_VIEW
        #ifdef LADDERS_ENABLED
            If type = 2 Then
                Dim tile as Ubyte = GetTile(col, lin)
                If tile >= 70 And tile <= 73 Then Return tile
            End If
        #endif
    #endif
    Return 0
End Function

'type 0 Damage, 1 Solid, 2 Ladder
Function CheckCollision(x as Ubyte, y as Ubyte, type as Ubyte) as Ubyte
    Dim xIsEven as Ubyte = (x bAnd 1) = 0
    Dim yIsEven as Ubyte = (y bAnd 1) = 0
    Dim col as Ubyte = x >> 1
    Dim lin as Ubyte = y >> 1
    Dim t as Ubyte
    
    t = checkTypeOfTile(col, lin, type) : if t then return t
    t = checkTypeOfTile(col + 1, lin, type) : if t then return t
    t = checkTypeOfTile(col, lin + 1, type) : if t then return t
    t = checkTypeOfTile(col + 1, lin + 1, type) : if t then return t
    
    if not yIsEven then
        t = checkTypeOfTile(col, lin + 2, type) : if t then return t
        t = checkTypeOfTile(col + 1, lin + 2, type) : if t then return t
    end if
    
    if not xIsEven then
        t = checkTypeOfTile(col + 2, lin, type) : if t then return t
        t = checkTypeOfTile(col + 2, lin + 1, type) : if t then return t
    end if
    
    if not xIsEven and not yIsEven then
        t = checkTypeOfTile(col + 2, lin + 2, type) : if t then return t
    end if
    
    return 0
End Function

sub removeTilesFromScreen(tile as ubyte)
    dim index, basePtr as uinteger
    dim y, x as ubyte
    
    x = 0
    y = 0
    basePtr = arrayBasePtr(decompressedMap)
    
    for index=0 to SCREEN_LENGTH
        if peek(basePtr + index) - 1 = tile then
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
        
        Dim wallJump As Ubyte = 0
        
        #ifdef WALL_JUMP_ENABLED
            If landed = 0 Then
                If CheckCollision(protaX + 1, protaY, 1) Then
                    wallJump = 1
                    protaDirection = 0
                    protaFrame = 4
                    If protaX > 0 Then protaX = protaX - 1
                    wallJumpTimer = 8
                Elseif CheckCollision(protaX - 1, protaY, 1) Then
                    wallJump = 1
                    protaDirection = 1
                    protaFrame = 1
                    If protaX < 60 Then protaX = protaX + 1
                    wallJumpTimer = 8
                End If
            End If
        #endif
        
        if (jumpCurrentKey = jumpStopValue and landed) or wallJump then
            landed = 0
            #ifdef DASH_ENABLED
                hasDashed = 0
            #endif
            jumpCurrentKey = 0
            #ifdef DASH_ENABLED
            Elseif landed = 0 And hasDashed = 0 And dashActive Then
                hasDashed = 1
                dashTimer = DASH_DURATION
                jumpCurrentKey = jumpStopValue
                BeepFX_Play(2)
            #endif
        end if
    end sub
#endif

#define saveProta(lin, col, tile, directionRight) protaX = col : protaY = lin : protaTile = tile : protaDirection = directionRight

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
    Return (attrSet(tile) bAnd 135) + (attrSet(besideTile) bAnd 120)  ' ink+flash + paper+bright
End Function

#define replaceTileWithBackground(col, lin) SetTile(GetTile(col, (lin) + 1), attrSet(GetTile(col, (lin) + 1)), col, lin)

#ifdef IDLE_ENABLED
    Function getNextProtaIdleSprite() As Ubyte
        If protaTile = PROTA_IDLE_SPRITE_ID Then
            Return PROTA_IDLE_SPRITE_ID + 1
        Else
            Return PROTA_IDLE_SPRITE_ID
        End If
    End Function
#endif

#define getFirstCharInk() (Peek(22528) bAnd 7)
#define getFirstCharPaper() ((Peek(22528) bAnd 56) >> 3)
#define getFirstCharBright() ((Peek(22528) bAnd 64) >> 6)

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

#ifdef TEXTS_ENABLED    
    Sub showTextInTheScreen(screenId As Ubyte, inkColor As Ubyte, paperColor As Ubyte)
        If messageCoolDown > 0 Then Return
        
        ' Find text ID for this screen
        Dim textId As Ubyte = 0
        While textLocations(textId, 0) <> screenId
            textId = textId + 1
        Wend
        Dim actualTextId As Ubyte = textLocations(textId, 1)
        
        SetBank(TEXTS_BANK)
        Dim textPtr As UInteger = $C000
        Dim textsSkipped As Ubyte = 0
        
        ' 1. Find Text Start
        While textsSkipped < actualTextId
            If PEEK(textPtr) = 255 Then
                textsSkipped = textsSkipped + 1
            End If
            textPtr = textPtr + 1
        Wend
        
        ' Window definition
        Const BUFFER_ADDR as UInteger = $E000
        
        Dim bufPtr As UInteger
        Dim scrPtr As UInteger
        Dim i as Ubyte
        Dim j as Ubyte
        Dim attrVal as Ubyte
        
        Dim currentX as Ubyte
        Dim currentY as Ubyte
        Dim charCode as Ubyte
        Dim scanPtr as UInteger
        Dim wordLen as Ubyte
        
        ' --- SAVE BACKGROUND (FULL SCREEN) ---
        ' 16384 (Pixels) + 6144 (Size of Pixels) = 22528 (Start of Attributes)
        ' 22528 + 768 (Size of Attributes) = 23296
        ' Total size = 6912 bytes
        ' We can copy everything in one go since they are contiguous
        MemCopy(16384, BUFFER_ADDR, 6912)
        SetBank(0)
        
        ' --- DRAW WINDOW ---
        Ink inkColor: Paper paperColor
        
        ' Clear Window Area (Pixels)
        ClearBox(TEXTS_WINDOW_X, TEXTS_WINDOW_Y, TEXTS_WINDOW_WIDTH, TEXTS_WINDOW_HEIGHT)
        
        ' Set Attributes for Window Area
        ' Calculate Attribute Byte: (PAPER * 8) + INK
        attrVal = (paperColor << 3) + (inkColor bAnd 7)
        For j = 0 To TEXTS_WINDOW_HEIGHT - 1
            scrPtr = 22528 + (Cast(UInteger, TEXTS_WINDOW_Y) + j) * 32 + TEXTS_WINDOW_X
            MemSet(scrPtr, attrVal, TEXTS_WINDOW_WIDTH)
        Next j
        
        ' --- STREAM PRINT TEXT ---
        SetBank(TEXTS_BANK)
        
        currentX = TEXTS_WINDOW_X + 1
        currentY = TEXTS_WINDOW_Y + 1
        
        ' Loop until End of Text (255)
        While PEEK(textPtr) <> 255
            charCode = PEEK(textPtr)
            
            If charCode = 10 Then
                ' Line Feed (Enter key) = Carriage Return
                currentX = TEXTS_WINDOW_X + 1
                currentY = currentY + 1
                textPtr = textPtr + 1
                
            ElseIf charCode = 32 Then
                ' Space
                If currentX <= TEXTS_WINDOW_X + TEXTS_WINDOW_WIDTH - 1 Then
                    PrintString(" ", 7, currentX, currentY)
                    currentX = currentX + 1
                End If
                textPtr = textPtr + 1
                
            Else
                ' Word Start: Calc length of next word
                scanPtr = textPtr
                wordLen = 0
                While PEEK(scanPtr) <> 32 AND PEEK(scanPtr) <> 10 AND PEEK(scanPtr) <> 255
                    wordLen = wordLen + 1
                    scanPtr = scanPtr + 1
                Wend
                
                ' Wrap check
                If currentX + wordLen > TEXTS_WINDOW_X + TEXTS_WINDOW_WIDTH - 1 Then
                    currentX = TEXTS_WINDOW_X + 1
                    currentY = currentY + 1
                End If
                
                ' Print Word
                If currentY <= TEXTS_WINDOW_Y + TEXTS_WINDOW_HEIGHT - 1 Then
                    While PEEK(textPtr) <> 32 AND PEEK(textPtr) <> 10 AND PEEK(textPtr) <> 255
                        PrintString(Chr$(PEEK(textPtr)), 7, currentX, currentY)
                        currentX = currentX + 1
                        textPtr = textPtr + 1
                    Wend
                Else
                    ' Skip word (out of bounds)
                    textPtr = textPtr + wordLen
                End If
            End If
        Wend
        
        ' Wait
        Do
        Loop Until skipScreenPressed()
        
        Paper PAPER_VALUE: Ink INK_VALUE
        
        ' --- RESTORE BACKGROUND (FULL SCREEN) ---
        SetBank(TEXTS_BANK)
        MemCopy(BUFFER_ADDR, 16384, 6912)
        SetBank(0)
        
        messageCoolDown = MESSAGE_COOLDOWN_LOOPS
    End Sub
#endif

Function checkAABB(x0a As Ubyte, y0a As Ubyte, x1a As Ubyte, y1a As Ubyte, x0b As Ubyte, y0b As Ubyte, x1b As Ubyte, y1b As Ubyte) As Ubyte
    If x1a < x0b Then Return 0
    If x0a > x1b Then Return 0
    If y1a < y0b Then Return 0
    If y0a > y1b Then Return 0
    Return 1
End Function

sub debugA(value as UBYTE)
    PrintString("----", 7, 0, 0)
    PrintString(STR$(value), 7, 0, 0)
end sub

sub debugB(value as UBYTE)
    PrintString("  ", 7, 5, 0)
    PrintString(STR$(value), 7, 5, 0)
end sub

sub debugC(value as UBYTE)
    PrintString("  ", 7, 10, 0)
    PrintString(STR$(value), 7, 10, 0)
end sub

sub debugD(value as UBYTE)
    PrintString("  ", 7, 15, 0)
    PrintString(STR$(value), 7, 15, 0)
end sub