Sub loadDataFromTape()
    #ifdef ENABLED_128k
        PaginarMemoria(6)
        load "" CODE $c000 ' Load fx
        PaginarMemoria(0)
    #Else
        load "" CODE ' Load fx
    #endif
    
    load "" CODE ' Load files
    
    #ifdef ENABLED_128k
        PaginarMemoria(MUSIC_BANK)
        load "" CODE ' Load vtplayer
        load "" CODE 51312 ' Load title music
        load "" CODE 54354 ' Load ingame music
        
        PaginarMemoria(DATA_BANK)
        load "" CODE TITLE_SCREEN_ADDRESS ' Load title Screen
        load "" CODE ENDING_SCREEN_ADDRESS ' Load ending Screen
        load "" CODE HUD_SCREEN_ADDRESS ' Load hud Screen
        #ifdef INTRO_SCREEN_ENABLED
            load "" CODE INTRO_SCREEN_ADDRESS ' Load intro Screen
        #endif
        #ifdef GAMEOVER_SCREEN_ENABLED
            load "" CODE GAMEOVER_SCREEN_ADDRESS ' Load game over Screen
        #endif
        PaginarMemoria(0)
    #endif
End Sub