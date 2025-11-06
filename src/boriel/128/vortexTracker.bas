Dim VortexTracker_Status As Ubyte = 0

' This Sub used PaginarMemoria previously, which included/d DI/EI.
' Without PaginarMemoria, DI/EI *must* be done explicitly.
'usarIM2 (Byte): 1 utiliza el motor de interrupciones
Sub VortexTracker_Init()
    Asm
        di
    End Asm
    
    VortexTracker_Status = 0
    
    Asm
        ei
    End Asm
End Sub

Sub Fastcall VortexTracker_Play(address As Uinteger)

    Asm
        di
        ld a,($5b5c)
        push af
        And %11111000
        ld  bc, (_musicBank)
        Or c
        ld bc,$7ffd
        push bc
        Out (c),a
        push ix ; Guardamos ix
        call $C003
        pop ix ; Recuperamos ix
        pop bc
        pop af
        Out (c),a
    End Asm
        VortexTracker_Status = 1
    Asm
        ei
    End Asm
End Sub

' Se invoca de forma automática por el gestor de
' interrupciones. Si no usamos el gestor, se debe llamar a
' este método cada 20ms.
Sub Fastcall VortexTracker_NextNote()
    If VortexTracker_Status <> 1 Then Return
    
    callVtAddress($C005)
    #ifdef TIMER_ENABLED
        #ifdef HURRY_UP_SECONDS
            If vortexTracker2x Then
                If framec Mod 2 = 0 Then
                    callVtAddress($C005)
                End If
            End If
        #endif
    #endif
End Sub

' This Sub used PaginarMemoria previously, which included DI/EI.
' Without PaginarMemoria, DI/EI *must* be done explicitly.
Sub VortexTracker_Stop()
    VortexTracker_Status = 0
    
    Asm
        di
    End Asm
        callVtAddress($C008)
    Asm
        ei
    End Asm
End Sub

' This Sub *must* be used with dissabled INTs:
' either inside an ISR (VortexTracker_NextNote),
' Or between DI/EI (VortexTracker_Inicializar And VortexTracker_Stop)
Sub Fastcall callVtAddress(address As Uinteger)
    Asm
        ld a,($5b5c)
        push af
        And %11111000
        ld  bc, (_musicBank)
        Or c
        ld bc,$7ffd
        push bc
        Out (c),a
        push ix ; Guardamos ix
        ld (callhl+1),hl
        callhl:
        call $1234; Saltar a la dirección en HL
        pop ix ; Recuperamos ix
        pop bc
        pop af
        Out (c),a
    End Asm
End Sub