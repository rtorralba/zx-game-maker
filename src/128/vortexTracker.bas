' - Módulo de reproducción de Vortex Tracker --------------
' - Defines -----------------------------------------------
' Generated from tiled
' #DEFINE VTPLAYER_INIT $EFAD
' #DEFINE VTPLAYER_NEXTNOTE $EFB2
' #DEFINE VTPLAYER_MUTE $EFB5
' - Variables ---------------------------------------------
' Estado del reproductor, 0=parado, 1=sonando
DIM VortexTracker_Status AS UByte = 0
' - Inicializa el motor de Vortex Tracker -----------------
' Parámetros:
'
'usarIM2 (byte): 1 utiliza el motor de interrupciones
'
'' solo inicializa el motor de Vortex
SUB VortexTracker_Inicializar(usarIM2 AS UByte)
  PaginarMemoria(4)
    ASM
        push ix
        ; Guardamos ix
        call VTPLAYER_INIT ; Inicializamos el motor
        pop ix
        ; Recuperamos ix
    END ASM
  PaginarMemoria(0)
  ' Si usamos interrupciones...
  IF usarIM2 = 1 THEN
      ' Inicializamos el motor de interrupciones para
      ' que se ejecute "VortexTracker_NextNote" en cada
      ' interrupción
      IM2_Inicializar(@VortexTracker_NextNote)
  END IF
  ' Estado: 1 (sonando)
  VortexTracker_Status = 1
END SUB

' - Toca la próxima nota de la canción --------------------
' Se invoca de forma automática por el gestor de
' interrupciones. Si no usamos el gestor, se debe llamar a
' este método cada 20ms.
SUB FASTCALL VortexTracker_NextNote()
  ' Solo toca si el estado es 1 (sonando)
  if VortexTracker_Status = 1 THEN
    ASM
      ld a,($5b5c)
      push af
      AND %11111000
      OR          4; PaginarMemoria(4)
      ld bc,$7ffd
      OUT (c),a
      push ix ; Guardamos ix
      call VTPLAYER_NEXTNOTE ; Reproducimos una nota
      pop ix ; Recuperamos ix
      pop af
      ld bc,$7ffd
      ld ($5b5c),a
      OUT (c),a
    END ASM
  end if
  ' framec = framec + 1
END SUB
' - Detiene la reproducción de la música ------------------
SUB VortexTracker_Stop()
  ' Estado igual a 0 (detenido)
  VortexTracker_Status = 0
  PaginarMemoria(4)
    ASM
        push ix
        ; Guardamos ix
        call VTPLAYER_MUTE ; Bajamos el volumen a 0
        pop ix
        ; Recuperamos ix
    END ASM
  PaginarMemoria(0)
END SUB