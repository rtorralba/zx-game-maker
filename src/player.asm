ORG 49152
;BeepFX player by Shiru
;You are free to do whatever you want with this code
Play:
  ld a, 19
  ld hl,FXAddress    ;address of sound effects data

  ld b,0
  ld c,a
  add hl,bc
  add hl,bc
  ld  c, (hl)
  inc hl
  ld  b, (hl)
  ld (FX),bc
  ret
NextNote:
  ; dirección del efecto a reproducir, este valor debería ser más dinámico, quizá en las posiciones 5CB0 (23728) y 5CB1 (23729)
  ld hl,(FX)
  ld a, l
  or h
  ret z

  di
  push ix
  push iy
  push hl
  pop ix        ;put it into ix

  ld a,(23624)    ;get border color from BASIC vars to keep it unchanged
  rra
  rra
  rra
  and 7
  ld (sfxRoutineToneBorder  +1),a
  ld (sfxRoutineNoiseBorder +1),a


readData:
  ld a,(ix+0)      ;read block type
  ld c,(ix+1)      ;read duration 1
  ld b,(ix+2)
  ld e,(ix+3)      ;read duration 2
  ld d,(ix+4)
  push de
  pop iy

  dec a
  jr z,sfxRoutineTone
  dec a
  jr z,sfxRoutineNoise
endData:
  pop iy
  pop ix
  ei
  ret
   
nextData:
  add ix,bc    ;skip to the next block
  ld  (FX), ix
  jr endData

;generate tone with many parameters

sfxRoutineTone:
  ld e,(ix+5)      ;freq
  ld d,(ix+6)
  ld a,(ix+9)      ;duty
  ld (sfxRoutineToneDuty+1),a
  ld hl,0

sfxRT0:
  push bc
  push iy
  pop bc
sfxRT1:
  add hl,de      ;11
  ld a,h        ;4
sfxRoutineToneDuty:
  cp 0        ;7
  sbc a,a        ;4
  and 16        ;7
sfxRoutineToneBorder:
  or 0        ;7
  out (254),a      ;11
  ld a,(0)      ;13  dummy
  dec bc        ;6
  ld a,b        ;4
  or c        ;4
  jr nz,sfxRT1    ;10=88t

  ld a,(sfxRoutineToneDuty+1)   ;duty change
  add a,(ix+10)
  ld (sfxRoutineToneDuty+1),a

  ld c,(ix+7)      ;slide
  ld b,(ix+8)
  ex de,hl
  add hl,bc
  ex de,hl

  pop bc
  dec bc
  ld a,b
  or c
  jr nz,sfxRT0

  ld c,11
  jr nextData

;generate noise with two parameters

sfxRoutineNoise:
  ld e,(ix+5)      ;pitch

  ld d,1
  ld h,d
  ld l,d
sfxRN0:
  push bc
  push iy
  pop bc
sfxRN1:
  ld a,(hl)      ;7
  and 16        ;7
sfxRoutineNoiseBorder:
  or 0        ;7
  out (254),a      ;11
  dec d        ;4
  jr z,sfxRN2      ;10
  nop          ;4  dummy
  jr sfxRN3      ;10  dummy
sfxRN2:
  ld d,e        ;4
  inc hl        ;6
  ld a,h        ;4
  and 31        ;7
  ld h,a        ;4
  ld a,(0)      ;13 dummy
sfxRN3:
  nop          ;4  dummy
  dec bc        ;6
  ld a,b        ;4
  or c        ;4
  jr nz,sfxRN1    ;10=88 or 112t

  ld a,e
  add a,(ix+6)    ;slide
  ld e,a

  pop bc
  dec bc
  ld a,b
  or c
  jr nz,sfxRN0

  ld c,7
  jr nextData


FX:
dw $0000

FXAddress:
include "assets/fx/fx.asm"