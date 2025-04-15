Dim VortexTracker_Status As Ubyte = 0

' This Sub used PaginarMemoria previously, which included/d DI/EI.
' Without PaginarMemoria, DI/EI *must* be done explicitly.
'usarIM2 (Byte): 1 utiliza el motor de interrupciones
Sub VortexTracker_Inicializar(usarIM2 As Ubyte)
    ASM
        di
    End ASM
    If inMenu Then
        callVtAddress($C000)
    Else
        callVtAddress(VTPLAYER_INIT)
    End If
    
    If usarIM2 = 1 Then
        ' Inicializamos el motor de interrupciones para
        ' que se ejecute "VortexTracker_NextNote" en cada
        ' interrupción
        IM2_Inicializar(@VortexTracker_NextNote)
    End If
    ASM
        ei
    End ASM
    ' Estado: 1 (sonando)
    VortexTracker_Status = 1
End Sub

' Se invoca de forma automática por el gestor de
' interrupciones. Si no usamos el gestor, se debe llamar a
' este método cada 20ms.
Sub Fastcall VortexTracker_NextNote()
    If VortexTracker_Status <> 1 Then Return
    
    If inMenu Then
        callVtAddress($C005)
    Else
        callVtAddress(VTPLAYER_NEXTNOTE)
    End If
End Sub

' This Sub used PaginarMemoria previously, which included DI/EI.
' Without PaginarMemoria, DI/EI *must* be done explicitly.
Sub VortexTracker_Stop()
    VortexTracker_Status = 0
    
    ASM
        di
    End ASM
    If inMenu Then
        callVtAddress($C008)
    Else
        callVtAddress(VTPLAYER_MUTE)
    End If
    ASM
        ei
    End ASM
End Sub

' This Sub *must* be used with dissabled INTs:
' either inside an ISR (VortexTracker_NextNote),
' Or between DI/EI (VortexTracker_Inicializar And VortexTracker_Stop)
Sub Fastcall callVtAddress(address As Uinteger)
    ASM
        ld a,($5b5c)
        push af
        And %11111000
        Or  MUSIC_BANK; Memory Bank
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
    End ASM
End Sub