DIM VortexTracker_Status AS UByte = 0
'usarIM2 (byte): 1 utiliza el motor de interrupciones
SUB VortexTracker_Inicializar(usarIM2 AS UByte)
  if inMenu
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
  ' Estado: 1 (sonando)
  VortexTracker_Status = 1
END SUB

' Se invoca de forma automática por el gestor de
' interrupciones. Si no usamos el gestor, se debe llamar a
' este método cada 20ms.
SUB FASTCALL VortexTracker_NextNote()
  if VortexTracker_Status <> 1 THEN return

  if inMenu
    callVtAddress($C005)
  else
    callVtAddress(VTPLAYER_NEXTNOTE)
  end if
END SUB

SUB VortexTracker_Stop()
  VortexTracker_Status = 0

  if inMenu
    callVtAddress($C008)
  else
    callVtAddress(VTPLAYER_MUTE)
  end if
END SUB

sub fastcall callVtAddress(address as uinteger)
  ASM
    ld a,($5b5c)
    push af
    AND %11111000
    OR          MUSIC_BANK; Memory Bank
    ld bc,$7ffd
    OUT (c),a
    push ix ; Guardamos ix
    ld (callhl+1),hl
callhl:
    call $1234; Saltar a la dirección en HL
    pop ix ; Recuperamos ix
    pop af
    ld bc,$7ffd
    OUT (c),a
  END ASM
end sub