Sub Fastcall PaginarMemoria(banco As Ubyte)
    ASM
        ld d,a
        ; Con Fastcall banco se coloca en A
        ld a,($5b5c)
        ; Leemos BANKM
        And %11111000
        ; Reseteamos los 3 primeros bits
        Or d
        ; Ajustamos los 3 primeros bits con el
        ; "banco"
        ld bc,$7ffd
        ; Puerto donde haremos el Out
        di
        ; Deshabilitamos las interrupciones
        ld ($5b5c),a
        ; Actualizamos BANKM
        Out (c),a
        ; Hacemos el Out
        ei
        ; Habilitamos las interrupciones
    End ASM
End Sub