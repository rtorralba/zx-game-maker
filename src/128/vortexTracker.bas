DIM VortexTracker_Status AS UByte = 0

' This SUB used PaginarMemoria previously, which included/d DI/EI.
' Without PaginarMemoria, DI/EI *must* be done explicitly.
'usarIM2 (byte): 1 utiliza el motor de interrupciones
SUB VortexTracker_Inicializar(usarIM2 AS UByte)
  ASM
    di
  END ASM
  if inMenu then
    callVtAddress($C000)
  else
    callVtAddress(VTPLAYER_INIT)
  end if

  IF usarIM2 = 1 THEN
      ' Inicializamos el motor de interrupciones para
      ' que se ejecute "VortexTracker_NextNote" en cada
      ' interrupción
      IM2_Inicializar(@VortexTracker_NextNote)
  END IF
  ASM
    ei
  END ASM
  ' Estado: 1 (sonando)
  VortexTracker_Status = 1
END SUB

' Se invoca de forma automática por el gestor de
' interrupciones. Si no usamos el gestor, se debe llamar a
' este método cada 20ms.
SUB FASTCALL VortexTracker_NextNote()
  if VortexTracker_Status <> 1 THEN return

  if inMenu then
    callVtAddress($C005)
  else
    callVtAddress(VTPLAYER_NEXTNOTE)
  end if
END SUB

' This SUB used PaginarMemoria previously, which included DI/EI.
' Without PaginarMemoria, DI/EI *must* be done explicitly.
SUB VortexTracker_Stop()
  VortexTracker_Status = 0

  ASM
    di
  END ASM
  if inMenu then
    callVtAddress($C008)
  else
    callVtAddress(VTPLAYER_MUTE)
  end if
  ASM
    ei
  END ASM
END SUB

' This SUB *must* be used with dissabled INTs:
' either inside an ISR (VortexTracker_NextNote),
' or between DI/EI (VortexTracker_Inicializar and VortexTracker_Stop)
sub fastcall callVtAddress(address as uinteger)
  ASM
    ld a,($5b5c)
    push af
    AND %11111000
    OR  MUSIC_BANK; Memory Bank
    ld bc,$7ffd
    push bc
    OUT (c),a
    push ix ; Guardamos ix
    ld (callhl+1),hl
callhl:
    call $1234; Saltar a la dirección en HL
    pop ix ; Recuperamos ix
    pop bc
    pop af
    OUT (c),a
  END ASM
end sub