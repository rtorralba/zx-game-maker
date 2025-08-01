Sub Fastcall CountFrames()
    framec=framec+1
End Sub

Sub IM2_Setup()
    Asm
        di
    End Asm
    
    IM2_Inicializar(@atEveryInterrupt)
    
    Asm
        ei
    End Asm
End Sub

Sub Fastcall atEveryInterrupt()
    CountFrames()
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            VortexTracker_NextNote()
        #endif
    #endif
End Sub