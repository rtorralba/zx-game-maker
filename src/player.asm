; BeepFX player by Shiru
; You are free to do whatever you want with this code
; Modificado por Juan Antonio Rubio García

; Si se va a usar desde fuera de ASM, antes de Play poner ORG Dirección para que calcule las
; direcciones al ensamblar

; Primero: en la dirección Play+$01 cargar el sonido a reproducir
;     LD   Play+$01,$03   POKE Play+1,3           Indica cargar el sonido 3
; Segundo: llamar a Play
;     CALL Play           RANDOMIZE USR Play      Pone en memoria la dirección del sonido 3
; Tercero: llamar a NextTone cuando sea preciso
;     CALL NextTone       RANDOMIZE USR Play+12   Reproduce un bloque del efecto y sale
;                                                 Si no hay ningún efecto cargado sale
Play:
  ld   bc, $00          ; BC = A, efecto a reproducir
  ld   hl,FXAddress     ; Dirección en la que están las direcciones de los efectos
  add  hl,bc
  add  hl,bc            ; HL = dirección donde está la dirección del sonido a reproducir
  ld   (FX),hl          ; Guarda en memoria la dirección del sonido a reproducir
  ret

NextNote:
  ld   hl,(FX)          ; HL = dirección del siguiente bloque a reproducir
  ld   a, l
  or   h                ; Comprueba si HL es 0
  ret  z                ; Si es 0, no hay ningún sonido para reproducir y sale

  di                    ; Desactiva las interrupciuones
  push ix
  push iy               ; Preserva los registros índice
  push hl
  pop  ix               ; Carga en IX el valor de HL (dirección del efecto), ver línea 29

  ld   a, ($5C48)       ; Obtiene los atributos del borde
  rra
  rra
  rra                   ; Los pone en los bits 0 a 2
  and  $07              ; Se queda con los atributos del borde
  ld (sfxRoutineToneBorder  +$01),a
  ld (sfxRoutineNoiseBorder +$01),a ; Modifica las rutinas con el valor del borde
                                    ; OR $00, sustituye 0 por el valor de A, en líneas 102 y 150

readData:
  ld   a, (ix+0)        ; A = tipo de bloque
  ld   c, (ix+1)
  ld   b, (ix+2)        ; BC = Frames
  ld   e, (ix+3)
  ld   d, (ix+4)        ; DE = Frame lenght
  push de
  pop  iy               ; Carga en iy el valor de DE, Frame lenght

  dec  a                ; Decrementa A
  jr   z,sfxRoutineTone ; Si es 0, es tono, salta
  dec  a                ; Decrementa A
  jr   z,sfxRoutineNoise; Si es 0, es ruido, salta
endData:
  pop  iy
  pop  ix               ; Recupera los registros índice
  ei                    ; Reactiva las interrupciones
  ret                   ; Sale de la rutina
   
nextData:
  add  ix,bc            ; Apunta IX al bloque siguiente, ver líneas 126 y 180
  ld   (FX),ix          ; Guarda en memoria la dirección del siguiente bloque 
  jr   endData          ; Salta para salir de la rutina

; Genera tono con séis parámetros, 11 bytes por bloque. Frame length 32768 = 1 segundo aprox.
; Tono
;       0
;	      Type = Tone
;  defb 1
;       1 - 2 	3 - 4 		    5 - 6     	7 - 8 			9 - 10
;	      Frames	Frame lenght  Pitch	      Pith slide  Duty y Duty slide
;                             Frecuencia
;  defw 65536,	65536,		    65535,	    32768,			33023
sfxRoutineTone:
  ld   e, (ix+$05)
  ld   d, (ix+$06)      ; DE = Pitch, ver línea 38
  ld   a, (ix+$09)      ; A = Duty
  ld   (sfxRoutineToneDuty+1),a ; Modifica la rutina con el valor de Duty
                                ; CP $00, susituye 0 por el valor de A, ver línea 98
  ld   hl,$00           ; HL = 0

sfxRT0:
  push bc               ; Preserva BC (Frames), ver líneas 52 y 53
  push iy
  pop  bc               ; Carga en BC el valor de IY (Frame lenght), ver líneas 55 y 56
sfxRT1: ; Desde aquí la rutina tarda 88 t-sates hasta la línea 108 (sincronización).
  add  hl,de            ; Suma DE (Pitch) a HL (11 t-states)
  ld   a, h             ; Carga el byte alto en A (4 t-sates)
sfxRoutineToneDuty:
  cp   $00              ; Lo compara con el valor de Duty ($00 se modifica en las líneas 110 a 112) (7 t-sates) 
  sbc  a, a             ; Resta A - A teniendo en cuenta el acarreo (4 t-states)
  and  $10              ; Se queda con el bit 4, EAR y altavoz interno activo/desactivo (7 t-states)
sfxRoutineToneBorder:
  or   $00              ; Añade el color del borde (se modificó en las línea 45) (7 t-states)
  out  ($fe),a          ; Manda el valor al puerto 254 para activar/desactivar EAR y altavoz interno (11 t-sates)
  ld   a,(0)            ; (13 t-states)
  dec  bc               ; Decrementa BC (6 t-sates)
  ld   a, b             ; (4 t-states)
  or   c                ; Comprueba si BC = 0 (4 t-sates)
  jp  nz, sfxRT1        ; Si no es 0, bucle hasta que Frame lenght = 0 (10 t-states, Total 88 t-states)

  ld   a,(sfxRoutineToneDuty+1) ; Cambio de Duty en línea 98
  add  a,(ix+$0a)               ; Añade el valor de Duty slide
  ld   (sfxRoutineToneDuty+1),a ; Cambia el valor de la línea 98

  ld   c, (ix+$07)
  ld   b, (ix+$08)      ; BC = Pitch slide
  ex   de,hl            ; Intercambia los valores de DE y HL
  add  hl,bc            ; Suma Pitch slide a Pitch
  ex   de,hl            ; Intercambia los valores de DE y HL (DE = Pitch + Pitch slide)

  pop  bc               ; Recupera BC (Frames)
  dec  bc               ; Decrementa BC
  ld   a, b
  or   c                ; Comprueba si BC = 0
  jr   nz,sfxRT0        ; Si no es 0, bucle hasta que Frame = 0

  ld   c, $0b           ; C = bytes a los que está el siguiente bloque, BC viene a 0
  jp   nextData

; Genera ruido con dos parámetros, 7 bytes por bloque. Frame length 32768 = 1 segundo +/-.
;       0
;       Type = Noise
; defb  2 ;noise
;       1 - 2   3 - 4         5 - 6
;       Frames  Frame lenght  Pitch y Pitch slide
; defw  65535,  65535,        33023
sfxRoutineNoise:
  ld   e, (ix+$05)      ; E = Pitch
  ld   d, $01
  ld   h, d
  ld   l, d             ; HL = $11
sfxRN0:
  push bc               ; Preserva BC (Frames)
  push iy
  pop  bc               ; Carga en BC el valor de IY (Frame lenght)
sfxRN1: 
; Desde aquí, la rutina tarda 88 t-states hasta la línea 168 si en la línea 153 D=0 y 112 si D<>0
  ld   a, (hl)          ; A = Valor de la dirección a la que apunta HL (en los primeros 8Kb de la ROM) (7 t-states)
  and  $10              ; Se queda con el bit 4, activa o desactiva el EAR (7 t-states)
sfxRoutineNoiseBorder:
  or   $00              ; Añade el color del borde ($00 se modificó en las línea 46) (7 t-states)
  out  ($fe),a          ; Manda el valor al puerto 254 para emitir el sonido (11 t-sates)
  dec  d                ; Decrementa D (4 t-states)
  jp   z, sfxRN2        ; Si es 0 salta (10 t-states)
  nop                   ; (4 t-states)
  jp   sfxRN3           ; Salta (10 t-states)
sfxRN2:
  ld   d, e             ; D = Pitch (4 t-states)
  inc  hl               ; HL += 1 (6 t-states)
  ld   a, h             ; A = H (4 t-states)
  and  $1F              ; Se queda con el valor de los bits 0 a 4 (7 t-states)
  ld   h, a             ; H = A, dejando HL apuntando a alguna dirección de los primeros 8Kb de la ROM (4 t-states)
  ld   a, ($00)         ; (13 t-sates)
sfxRN3:
  nop                   ; (4 t-states)
  dec  bc               ; Decrementa BC (6 t-states)
  ld   a, b             ; (4 t-states)
  or   c                ; Comprueba si BC = 0 (4 t-states)
  jp   nz, sfxRN1       ; Si no es 0, bucle hasta que Frame lenght = 0 (10 t-states, Total 88 o 112 t-states)

  ld   a, e             ; A = Pitch
  add  a, (ix+$06)      ; A += Pitch slide
  ld   e, a             ; Actualiza Pitch

  pop  bc               ; Recupera BC (Frames)
  dec  bc               ; BC -= 1
  ld   a, b
  or   c                ; Comprueba si BC = 0
  jr   nz,sfxRN0        ; Si no es 0, bucle hasta que Frame = 0

  ld   c, $07           ; C = bytes a los que está el siguiente bloque, BC viene a 0
  jp   nextData

FX:
dw $0000

FXAddress:
include "assets/fx/fx.asm"