#define isPlatform(tile) ((tile) < 16)
#define isEnemy(tile) ((tile) > 15)
#define checkLeftDirection(enemyHorizontalDirection, tile) If enemyHorizontalDirection = -1 Then tile = tile + 16
#define moveEnemyPosition(enemyCol, enemyLin, horizontalDirection, verticalDirection) enemyCol = enemyCol + enemyHorizontalDirection : enemyLin = enemyLin + enemyVerticalDirection
#define isEnemyDeath(enemyLife) ((enemyLife) <= 0)
#define isEnemyVulnerable(enemyLife) ((enemyLife) < 99)
#define freezeOnSight(enemyColEnd) ((enemyColEnd) = -1)
#define areLookingAtEachOther(enemyHorizontalDirection) ((protaDirection = 1 And (enemyHorizontalDirection) = -1) Or (protaDirection = 0 And (enemyHorizontalDirection) = 1))
#define hasDefaultBehaviour(enemyBehaviour) (enemyBehaviour = ENEMY_BEHAVIOUR_DEFAULT Or enemyBehaviour = ENEMY_BEHAVIOUR_DEFAULT_SHOOT)
#define hasRectangularBehaviour(enemyBehaviour) (enemyBehaviour = ENEMY_BEHAVIOUR_RECTANGULAR Or enemyBehaviour = ENEMY_BEHAVIOUR_RECTANGULAR_SHOOT)
#define hasStalkerBehaviour(enemyBehaviour) (enemyBehaviour = ENEMY_BEHAVIOUR_STALKER Or enemyBehaviour = ENEMY_BEHAVIOUR_STALKER_SHOOT)
#define hasNoReturnBehaviour(enemyBehaviour) (enemyBehaviour = ENEMY_BEHAVIOUR_NO_RETURN)
#define enemyShouldShoot(enemyBehaviour) (enemyBehaviour = ENEMY_BEHAVIOUR_DEFAULT_SHOOT Or enemyBehaviour = ENEMY_BEHAVIOUR_STALKER_SHOOT Or enemyBehaviour = ENEMY_BEHAVIOUR_RECTANGULAR_SHOOT)
#define isEnemyStopped(enemyLinEnd, enemyBehaviour) ((enemyLinEnd = -1) And (enemyBehaviour <> ENEMY_BEHAVIOUR_STALKER) And (enemyBehaviour <> ENEMY_BEHAVIOUR_STALKER_SHOOT))

#ifdef SIDE_VIEW
    Function checkPlatformHasProtaOnTop(x As Ubyte, y As Ubyte) As Ubyte
        If jumpCurrentKey <> jumpStopValue Then Return 0
        
        If checkAABB(protaX, protaY, protaX + 2, protaY + 4, x, y - 2, x + 4, y) = 0 Then Return 0
        
        Return 1
    End Function
    
    Function checkPlatformByXY(x As Ubyte, y As Ubyte) As Ubyte
        If enemiesPerScreen(currentScreen) = 0 Then Return 0
        
        For enemyId=0 To enemiesPerScreen(currentScreen) - 1
            If decompressedEnemiesScreen(enemyId, ENEMY_TILE) < 16 Then
                Dim enemyCol As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
                Dim enemyLin As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
                
                If x < enemyCol - 2 Then continue For
                If x > enemyCol + 4 Then continue For
                If y <> enemyLin Then continue For
                
                Return 1
            End If
        Next enemyId
        
        Return 0
    End Function
    
    #ifdef KILL_JUMPING_ON_TOP
        Function checkHitOnTop(enemyId As Ubyte, protaX1 As Ubyte, protaY1 As Ubyte, enemyX0 As Ubyte, enemyY0 As Ubyte, enemyX1 As Ubyte, enemyY1 As Ubyte) As Ubyte
            If jumpCurrentKey <> jumpStopValue Then Return 0
            If landed Then Return 0
            
            If enemyY0 > protaY1 + 2 Then Return 0
            If enemyY0 < protaY1 Then Return 0
            
            If checkAABB(protaX, protaY, protaX1, protaY1, enemyX0, enemyY0, enemyX1, enemyY1) Then
                damageEnemy(enemyId)
                landed = 1
                jumpCurrentKey = jumpStopValue
                jump()
                Return 1
            End If
            
            Return 0
        End Function
    #endif
#endif

#ifdef SHOOTING_ENABLED
    Function checkBulletProtaCollision(enemyX0 As Ubyte, enemyY0 As Ubyte, enemyX1 As Ubyte, enemyY1 As Ubyte, enemyId As Ubyte) As Ubyte
        If bulletPositionX = 0 Then Return 0
        
        If checkAABB(bulletPositionX, bulletPositionY, bulletPositionX + 1, bulletPositionY + 1, enemyX0, enemyY0, enemyX1, enemyY1) Then
            damageEnemy(enemyId)
            resetBullet()
            Return 1
        End If
        
        Return 0
    End Function
#endif

#ifdef SWORD_ENABLED
    Function checkSwordEnemyCollision(enemyX0 As Ubyte, enemyY0 As Ubyte, enemyX1 As Ubyte, enemyY1 As Ubyte, enemyId As Ubyte) As Ubyte
        If Not isEnemyVulnerable(decompressedEnemiesScreen(enemyId, ENEMY_LIFE)) Then Return 0
        
        If swordTimer = 0 Then Return 0
        
        Dim swordX As Ubyte
        If swordDirection = 1 Then
            swordX = protaX + 3
            If swordX >= 60 Then swordX = 60
        Else
            If protaX >= 2 Then swordX = protaX - 2 Else swordX = 0
        End If

        If checkAABB(swordX, protaY + 1, swordX + 1, protaY + 2, enemyX0, enemyY0, enemyX1, enemyY1) = 0 Then Return 0
        
        #ifdef SWORD_KILL_ENEMY
            killEnemy(enemyId)
        #else
            damageEnemy(enemyId)
        #endif
        Return 1
    End Function
#endif

Function checkProtaAndBulletCollision(enemyId As Ubyte) As Ubyte
    If invincible Then Return 0
    
    Dim protaX1 As Ubyte = protaX + SPRITE_COLLISION_SIZE
    Dim protaY1 As Ubyte = protaY + SPRITE_COLLISION_SIZE
    
    Dim enemyX0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL)
    Dim enemyY0 As Ubyte = decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN)
    Dim enemyX1 As Ubyte = enemyX0 + SPRITE_COLLISION_SIZE
    Dim enemyY1 As Ubyte = enemyY0 + SPRITE_COLLISION_SIZE
    
    Dim damage As Ubyte = 0
    
    #ifdef SHOOTING_ENABLED
        If checkBulletProtaCollision(enemyX0, enemyY0, enemyX1, enemyY1, enemyId) Then Return 1
    #endif
    
    #ifdef SWORD_ENABLED
        If checkSwordEnemyCollision(enemyX0, enemyY0, enemyX1, enemyY1, enemyId) Then Return 1
    #endif
    
    #ifdef SIDE_VIEW
        #ifdef KILL_JUMPING_ON_TOP
            If checkHitOnTop(enemyId, protaX1, protaY1, enemyX0, enemyY0, enemyX1, enemyY1) Then Return 1
        #endif
    #endif

    If checkAABB(protaX, protaY, protaX1, protaY1, enemyX0, enemyY0, enemyX1, enemyY1) = 0 Then Return 0
    
    decrementLife()
    
    Return 0
End Function

#define checkShouldSkipMoveBySpeed(enemySpeed) ((enemySpeed) <= 2 And skipMove(enemySpeed))

#define updateEnemyFrame(enemyId) currentEnemyFrame(enemyId) = currentEnemyFrame(enemyId) Xor 1

#define drawEnemy(enemyId, tile, enemyCol, enemyLin) currentEnemyFrame(enemyId) = currentEnemyFrame(enemyId) And (resetReturnMovement(enemyId) Xor 1) : Draw2x2Sprite(tile + currentEnemyFrame(enemyId), enemyCol, enemyLin)

#define saveData(enemyId, horizontalDirection, verticalDirection, enemyCol, enemyLin) decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) = enemyCol : decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) = enemyLin : decompressedEnemiesScreen(enemyId, ENEMY_HORIZONTAL_DIRECTION) = horizontalDirection : decompressedEnemiesScreen(enemyId, ENEMY_VERTICAL_DIRECTION) = verticalDirection

Sub saveAndDraw(enemyId as Ubyte, tile As Ubyte, horizontalDirection As Ubyte, verticalDirection As Ubyte, enemyCol As Byte, enemyLin As Byte, enemySpeed As Ubyte)
    ' If platform, update frame every time, otherwise only when moving
    If isPlatform(tile) Then
        updateEnemyFrame(enemyId)
    End If

    If checkShouldSkipMoveBySpeed(enemySpeed) Then
        drawEnemy(enemyId, tile, decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL), decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN))
    Else
        If isEnemy(tile) Then
            If decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_COL) <> enemyCol Or decompressedEnemiesScreen(enemyId, ENEMY_CURRENT_LIN) <> enemyLin Then
                updateEnemyFrame(enemyId)
            End If
        End If
        drawEnemy(enemyId, tile, enemyCol, enemyLin)
        saveData(enemyId, horizontalDirection, verticalDirection, enemyCol, enemyLin)
    End If
End Sub

Sub checkCollisionSaveAndDraw(enemyId as Ubyte, tile As Ubyte, horizontalDirection As Ubyte, verticalDirection As Ubyte, enemyCol As Byte, enemyLin As Byte, enemySpeed As Ubyte)
    If checkProtaAndBulletCollision(enemyId) Then
        If decompressedEnemiesScreen(enemyId, ENEMY_LIFE) <= 0 Then Return
    End If

    saveAndDraw(enemyId, tile, horizontalDirection, verticalDirection, enemyCol, enemyLin, enemySpeed)
End Sub

' Updates enemy position and flips tile for direction. Expands inline (no call overhead).
#define calculatePositionAndTile(tile, enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection) moveEnemyPosition(enemyCol, enemyLin, enemyHorizontalDirection, enemyVerticalDirection) : If isEnemy(tile) Then checkLeftDirection(enemyHorizontalDirection, tile)

#ifdef ENEMY_SHOOT_ENABLED
    Sub shootEnemyBullet(enemyCol As Byte, enemyLin As Byte)
        If enemyBulletX <> 0 Then Return
        Dim dx As Integer = protaX - enemyCol
        Dim dy As Integer = protaY - enemyLin
        If dx = 0 And dy = 0 Then Return
        enemyBulletDirX = Sgn(dx)
        enemyBulletDirY = Sgn(dy)
        enemyBulletX = enemyCol + 1
        enemyBulletY = enemyLin + 1
        enemyBulletSpriteId = ENEMY_BULLET_SPRITE_ID
    End Sub

    Sub moveEnemyBullet()
        If enemyBulletX = 0 Then Return

        Dim newX As Integer = enemyBulletX + enemyBulletDirX
        Dim newY As Integer = enemyBulletY + enemyBulletDirY

        If newX < 2 Or newX > 60 Or newY < 2 Or newY > 40 Then
            enemyBulletX = 0
            Return
        End If

        #ifdef ENEMY_SHOOT_SOLID_COLLIDE
            If isSolidTileByColLin(newX >> 1, newY >> 1) Then
                enemyBulletX = 0
                Return
            End If
        #endif

        enemyBulletX = newX
        enemyBulletY = newY

        If invincible Then Return

        If checkAABB(enemyBulletX, enemyBulletY, enemyBulletX + 1, enemyBulletY + 1, protaX, protaY, protaX + SPRITE_COLLISION_SIZE, protaY + SPRITE_COLLISION_SIZE) Then
            enemyBulletX = 0
            decrementLife()
        End If
    End Sub
#endif

Sub setEnemyDirectionForDefaulMovement(enemyCol As Byte, enemyLin As Byte, enemyColIni As Byte, enemyLinIni As Byte, enemyColEnd As Byte, enemyLinEnd As Byte, ByRef enemyHorizontalDirection As Byte, ByRef enemyVerticalDirection As Byte)
    If enemyHorizontalDirection Then
        If enemyColIni = enemyCol Or enemyColEnd = enemyCol Then
            enemyHorizontalDirection = enemyHorizontalDirection * -1
        End If
    End If
    
    If enemyVerticalDirection Then
        If enemyLinIni = enemyLin Or enemyLinEnd = enemyLin Then
            enemyVerticalDirection = enemyVerticalDirection * -1
        End If
    End If
End Sub