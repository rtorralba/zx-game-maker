const FIRST_RUNNING_PROTA_SPRITE_RIGHT as ubyte = 0
const FIRST_RUNNING_PROTA_SPRITE_LEFT as ubyte = 4

DIM spritesLinColTileAndFrame(MAX_ENEMIES_PER_SCREEN, 4) as ubyte

sub saveSprite(sprite as ubyte, lin as ubyte, col as ubyte, tile as ubyte, directionRight as ubyte)
    if sprite = PROTA_SPRITE then
        protaX = col
        protaY = lin
        protaDirection = directionRight
    end if
    spritesLinColTileAndFrame(sprite, 0) = lin
    spritesLinColTileAndFrame(sprite, 1) = col
    spritesLinColTileAndFrame(sprite, 2) = tile
    spritesLinColTileAndFrame(sprite, 3) = directionRight
    if spritesLinColTileAndFrame(sprite, 4) = 6 then
        spritesLinColTileAndFrame(sprite, 4) = 0
    else
        spritesLinColTileAndFrame(sprite, 4) = spritesLinColTileAndFrame(sprite, 4) + 1
    end if
end sub

function getSpriteLin(sprite as ubyte) as ubyte
    if sprite = PROTA_SPRITE then
        return protaY
    end if
    return spritesLinColTileAndFrame(sprite, 0)
end function

function getSpriteCol(sprite as ubyte) as ubyte
    if sprite = PROTA_SPRITE then
        return protaX
    end if
    return spritesLinColTileAndFrame(sprite, 1)
end function

function getSpriteTile(sprite as ubyte) as ubyte
    return spritesLinColTileAndFrame(sprite, 2)
end function

function getSpriteDirection(sprite as ubyte) as ubyte
    return spritesLinColTileAndFrame(sprite, 3)
end function

#ifdef SIDE_VIEW
    sub resetProtaSpriteToRunning()
        if protaDirection then
            saveSprite(PROTA_SPRITE, protaY, protaX, FIRST_RUNNING_PROTA_SPRITE_RIGHT, protaDirection)
        else
            saveSprite(PROTA_SPRITE, protaY, protaX, FIRST_RUNNING_PROTA_SPRITE_LEFT, protaDirection)
        end if
    end sub
#endif

function onLastColumn(sprite as ubyte) as ubyte
    return getSpriteCol(sprite) = 60
end function

function onFirstColumn(sprite as ubyte) as ubyte
    return getSpriteCol(sprite) = 0
end function

' sub removeScreenObjectFromBuffer()
'     for i = 0 to 4
'         for j = 0 to spritesDataCount - 1
'             spritesLinColTileAndFrame(i, j) = 0
'         next j
'     next i
' end sub