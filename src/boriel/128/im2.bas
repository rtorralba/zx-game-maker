' - Librería de gestión de interrupciones -----------------
' - Inicializa el motor de interrupciones -----------------
' Parámetros:
'address (Uinteger): Dirección a la que se saltará en
'cada interrupción.
Sub Fastcall IM2_Inicializar(address As Uinteger)
    ASM
        push ix
        ; Guardamos ix
        ld (IM2_SubAddress),hl ; Guardamos la dirección de salto
        ld hl,IM2_Tick
        ld a,l
        ld (IM2_Table-1),a
        ld a,h
        ld (IM2_Table),a
        ; Ponemos la dirección de IM2_Tick
        ; Al final de la tabla
        ld hl,IM2_Table-256 ; Dirección del final de la tabla
        ld a,h
        ; Ajustamos el valor de I al final de la tabla
        ld i,a
        im 2
        ; Ajustamos el modo de interrupción a 2
        jp IM2_Fin: ; Saltamos al final para salir
        ; Aquí saltará en cada interrupción
        IM2_Tick:
        ; Guardamos todos los registros
        push af
        push hl
        push bc
        push de
        push ix
        push iy
        exx
        ex af, af'
        push af
        push hl
        push bc
        push de
        ld hl,IM2_Tick_Fin
        push hl
        ld hl,(IM2_SubAddress)
        jp (hl)
        ; Definimos la dirección de ret
        ; Saltamos a nuestra rutina
        IM2_Tick_Fin:
        ; Recuperamos todos los registros que hemos guardado
        pop de
        pop bc
        pop hl
        pop af
        ex af, af'
        exx
        pop iy
        pop ix
        pop de
        pop bc
        pop hl
        pop af
        ei
        ret
        ; Activamos las interrupciones
        ; Salimos de la interrupción
        ; Espacio para la tabla de vectores de interrupción
        ; Debe empezar en una dirección múltiplo de 256
        db 0
        ALIGN 256
        IM2_Table:
        db 0
        IM2_SubAddress:
        defw 0
        ; El primer valor de salto está en $ff
        ; Alineamos a 256
        ; El segundo valor de salto está en $00
        ; Dirección de la subrutina a llamar
        IM2_Fin:
        pop ix ; Recuperamos ix para salir
    End ASM
End Sub
' - Detiene las interrupciones ----------------------------
Sub IM2_Stop()
    ASM
        im 1
        ; Definimos las interrupciones IM 1
    End ASM
End Sub
