Sub initGraphics()
    InitGFXLib()
    SetTileset(@tileSet(0, 0))
    #ifdef CUSTOM_FONT_ENABLED
        Poke Uinteger 23606, FONT_DATA_ADDRESS - 256
    #endif
End Sub