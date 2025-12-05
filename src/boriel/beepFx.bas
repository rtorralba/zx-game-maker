Sub Fastcall BeepFX_Play(Sound As Ubyte)
    #ifdef ENABLED_128k
        ASM
            push af
        End ASM
        SetBank(fxBank)
        ASM
            pop af
        End ASM
    #endif
    ASM
        push ix ; Guardamos ix
        ld [49153],a ; Cargamos el sonido a reproducir
        call 49152 ; Reproducimos el sonido
        pop ix ; Recuperamos ix
    End ASM
    #ifdef ENABLED_128k
        SetBank(0)
    #endif
End Sub

#ifdef NEW_BEEPER_PLAYER
    Sub Fastcall BeepFX_NextNote()
        #ifdef ENABLED_128k
            SetBank(fxBank)
        #endif
        ASM
            call 49169 ; Siguiente nota
        End ASM
        #ifdef ENABLED_128k
            SetBank(0)
        #endif
    End Sub
    
    Sub Fastcall BeepFX_Reset()
        #ifdef ENABLED_128k
            SetBank(fxBank)
        #endif
        ASM
            call 49361 ; Reset
        End ASM
        #ifdef ENABLED_128k
            SetBank(0)
        #endif
    End Sub
#endif