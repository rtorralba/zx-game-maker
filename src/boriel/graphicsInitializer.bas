Sub initGraphics()
    InitGFXLib()
    SetTileset(@tileSet)
    
    For i = 0 To 47
        spritesSet(i) = Create2x2Sprite(@sprites + (32 * spriteAddressIndex))
        spriteAddressIndex = spriteAddressIndex + 1
    Next i
    
    createSpriteFromTile(1, BULLET_SPRITE_RIGHT_ID)
    createSpriteFromTile(192, BULLET_SPRITE_LEFT_ID)
    
    #ifdef OVERHEAD_VIEW
        createSpriteFromTile(193, BULLET_SPRITE_UP_ID)
        createSpriteFromTile(194, BULLET_SPRITE_DOWN_ID)
    #endif
End Sub

Sub createSpriteFromTile(tile as ubyte, sprite as ubyte)
    For i = 0 To 7
        bullet(i) = tileSet(tile, i)
    Next i
    spritesSet(sprite) = Create1x1Sprite(@bullet)
End Sub