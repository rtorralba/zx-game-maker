Sub loadDataFromTape()
    #ifdef ENABLED_128k
        SetBank(fxBank)
        load "" CODE $c000 ' Load fx
        SetBank(0)
    #Else
        load "" CODE ' Load fx
    #endif
    
    load "" CODE ' Load files
    
    #ifdef ENABLED_128k
        #ifdef MUSIC_ENABLED
            SetBank(musicBank)
            load "" CODE ' Load vtplayer
            load "" CODE MUSIC_ADDRESS ' Load ingame music

            #ifdef MUSIC_TITLE_ENABLED
                load "" CODE MUSIC_TITLE_ADDRESS ' Load title music
            #endif

            #ifdef MUSIC_2_ENABLED
                load "" CODE MUSIC_2_ADDRESS ' Load music 2
            #endif

            #ifdef MUSIC_3_ENABLED
                load "" CODE MUSIC_3_ADDRESS ' Load music 3
            #endif

            #ifdef MUSIC_ENDING_ENABLED
                load "" CODE MUSIC_ENDING_ADDRESS ' Load ending music
            #endif

            #ifdef MUSIC_GAMEOVER_ENABLED
                load "" CODE MUSIC_GAMEOVER_ADDRESS ' Load game over music
            #endif

            #ifdef MUSIC_STAGE_CLEAR_ENABLED
                load "" CODE MUSIC_STAGE_CLEAR_ADDRESS ' Load stage clear music
            #endif
            
            #ifdef MUSIC_INTRO_ENABLED
                load "" CODE MUSIC_INTRO_ADDRESS ' Load intro music
            #endif

        #endif
        
        SetBank(screensBank)
        load "" CODE TITLE_SCREEN_ADDRESS ' Load title Screen
        load "" CODE ENDING_SCREEN_ADDRESS ' Load ending Screen
        load "" CODE HUD_SCREEN_ADDRESS ' Load hud Screen
        #ifdef INTRO_SCREEN_ENABLED
            load "" CODE INTRO_SCREEN_ADDRESS ' Load intro Screen
        #endif
        #ifdef GAMEOVER_SCREEN_ENABLED
            load "" CODE GAMEOVER_SCREEN_ADDRESS ' Load game over Screen
        #endif
        SetBank(0)
    #endif
End Sub