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
        #ifdef MUSIC_ENABLED
            PaginarMemoria(MUSIC_BANK)
            load "" CODE ' Load vtplayer
            load "" CODE MUSIC_ADDRESS ' Load ingame music

            #ifdef TITLE_MUSIC_ENABLED
                load "" CODE TITLE_MUSIC_ADDRESS ' Load title music
            #endif

            #ifdef MUSIC_2_ENABLED
                load "" CODE MUSIC_2_ADDRESS ' Load music 2
            #endif

            #ifdef MUSIC_3_ENABLED
                load "" CODE MUSIC_3_ADDRESS ' Load music 3
            #endif

        #endif
        
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