#include <keys.bas>
#include "../output/config.bas"

Const LEFT As Ubyte = 0
Const RIGHT As Ubyte = 1
Const UP As Ubyte = 2
Const DOWN As Ubyte = 3
Const FIRE As Ubyte = 4

Const COMM_KEY_ARRAY_PTR As Uinteger = 65520
Const COMM_KEMPSTON_AVAIL As Uinteger = 65522
Const COMM_HISCORE As Uinteger = 65523
Const COMM_RESULT As Uinteger = 65525

Dim keyArrayPtr As Uinteger
Dim kempstonInterfaceAvailable As Ubyte
#ifdef HISCORE_ENABLED
    Dim hiScoreVal As Uinteger
#endif

Dim keyLeft As Uinteger
Dim keyRight As Uinteger
Dim keyUp As Uinteger
Dim keyDown As Uinteger
Dim keyFire As Uinteger

Goto startMenu

asm
ROM_CHARSET EQU 15616 - 256

PROC
PRINT_CHAR:
    ; input: a = char, c = color, e = x, l = y
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, de
    ex de, hl
    
    ld hl, $5800
    add hl, de
    ld (hl), c
    
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    ld bc, ROM_CHARSET
    add hl, bc
    
    ld a, d
    rla
    rla
    rla
    or %01000000
    ld d, a
    
    ld a, (hl)
    ld (de), a
    inc hl
    inc d
    ld a, (hl)
    ld (de), a
    inc hl
    inc d
    ld a, (hl)
    ld (de), a
    inc hl
    inc d
    ld a, (hl)
    ld (de), a
    inc hl
    inc d
    ld a, (hl)
    ld (de), a
    inc hl
    inc d
    ld a, (hl)
    ld (de), a
    inc hl
    inc d
    ld a, (hl)
    ld (de), a
    inc hl
    inc d
    ld a, (hl)
    ld (de), a
    ret
ENDP
end asm

sub fastcall PrintChar(CharNumber as uByte, Color as uInteger, X as uInteger, Y as uInteger)
asm
    exx
    pop hl
    exx
    pop bc
    pop de
    pop hl
    exx
    push hl
    exx
    call PRINT_CHAR
end asm
end sub

sub PrintString(text as string, Color as uInteger, X as uInteger, Y as uInteger)
    Dim buc as uByte
    Dim tmpVal as uByte = len(text)
    Dim strPtr as uInteger = peek(uInteger, @text)
    Dim charAddr as uInteger = strPtr + 2

    for buc = 0 to tmpVal - 1
        PrintChar(peek(charAddr + buc), Color, X + buc, Y)
    next buc
end sub

#ifdef HISCORE_ENABLED
Sub PrintZeroPadded(value As Uinteger, padLength As Ubyte, Color As uInteger, X As uInteger, Y As uInteger)
    Dim i As Ubyte
    For i = 0 To padLength - 1
        PrintChar(48 + (value MOD 10), Color, X + padLength - 1 - i, Y)
        value = value / 10
    Next i
End Sub
#endif

Function LeerTecla() As Uinteger
    Do Loop While GetKeyScanCode()
    Do Loop Until GetKeyScanCode()
    Return GetKeyScanCode()
End Function

Sub saveKeys()
    Poke Uinteger keyArrayPtr + 0, keyLeft
    Poke Uinteger keyArrayPtr + 2, keyRight
    Poke Uinteger keyArrayPtr + 4, keyUp
    Poke Uinteger keyArrayPtr + 6, keyDown
    Poke Uinteger keyArrayPtr + 8, keyFire
End Sub

#ifdef REDEFINE_KEYS_ENABLED
Sub redefineKeys()
    Cls
    
    PrintString("REDEFINE KEYS", 7, 10, 4)
    
    PrintString("LEFT:", 7, 8, 8)
    PrintString("<", 7, 18, 8)    
    keyLeft = LeerTecla()
    PrintString("OK", 4, 22, 8)
    
    PrintString("RIGHT:", 7, 8, 10)
    PrintString(">", 7, 18, 10)
    keyRight = LeerTecla()
    PrintString("OK", 4, 22, 10)
    
    PrintString("UP:", 7, 8, 12)
    PrintString("^", 7, 18, 12)
    keyUp = LeerTecla()
    PrintString("OK", 4, 22, 12)
    
    PrintString("DOWN:", 7, 8, 14)
    PrintString("v", 7, 18, 14)
    keyDown = LeerTecla()
    PrintString("OK", 4, 22, 14)
    
    #ifdef SHOOTING_ENABLED
        PrintString("FIRE:", 7, 8, 16)
        PrintString("*", 7, 18, 16)
        keyFire = LeerTecla()
        PrintString("OK", 4, 22, 16)
    #endif
    
    saveKeys()
    Do Loop While GetKeyScanCode()
End Sub
#endif

startMenu:
keyArrayPtr = Peek(Uinteger, COMM_KEY_ARRAY_PTR)
kempstonInterfaceAvailable = Peek(COMM_KEMPSTON_AVAIL)
#ifdef HISCORE_ENABLED
    hiScoreVal = Peek(Uinteger, COMM_HISCORE)
#endif

keyLeft = Peek(Uinteger, keyArrayPtr + 0)
keyRight = Peek(Uinteger, keyArrayPtr + 2)
keyUp = Peek(Uinteger, keyArrayPtr + 4)
keyDown = Peek(Uinteger, keyArrayPtr + 6)
keyFire = Peek(Uinteger, keyArrayPtr + 8)

' Main menu logic
#ifdef HISCORE_ENABLED
    PrintString("HI:", 7, 6, 23)
    PrintZeroPadded(hiScoreVal, 5, 7, 9, 23)
#endif

Do
    If MultiKeys(KEY1) Then
        If Not keyLeft Then
            keyLeft = KEYO
            keyRight = KEYP
            keyUp = KEYQ
            keyDown = KEYA
            keyFire = KEYSPACE
            saveKeys()
        End If
        Poke COMM_RESULT, 1 ' Keyboard
        Exit Do
    ElseIf MultiKeys(KEY2) Then
        Poke COMM_RESULT, 2 ' Kempston
        Exit Do
    ElseIf MultiKeys(KEY3) Then
        keyLeft = KEY6
        keyRight = KEY7
        keyUp = KEY9
        keyDown = KEY8
        keyFire = KEY0
        saveKeys()
        Poke COMM_RESULT, 1 ' Keyboard (Sinclair)
        Exit Do
    #ifdef REDEFINE_KEYS_ENABLED
    ElseIf MultiKeys(KEY4) Then
        redefineKeys()
        Poke COMM_RESULT, 0 ' Redefined keys, redraw title menu
        Exit Do
    #endif
    ElseIf kempstonInterfaceAvailable Then
        Dim n As Ubyte = In 31
        If n bAND %10000 Then
            Poke COMM_RESULT, 2 ' Kempston
            Exit Do
        End If
    End If
Loop
