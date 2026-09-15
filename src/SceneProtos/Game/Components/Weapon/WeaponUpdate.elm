module SceneProtos.Game.Components.Weapon.WeaponUpdate exposing (decideAngle, decideWeaponDirection, initBulletAndLaser, shieldValidBullet)

{-|


# WeaponUpdate

This module contains logic functions for weapon update.

@docs decideAngle, decideWeaponDirection, initBulletAndLaser, shieldValidBullet

-}

import Random
import SceneProtos.Game.Components.Bullet.Init exposing (BulletType(..), SingleBullet)
import SceneProtos.Game.Components.Enemy.Init exposing (EnemyBullet)
import SceneProtos.Game.Components.Weapon.Init exposing (Shield, ShieldState(..))


{-| Function for weapon direction.
-}
decideWeaponDirection : Float -> Float -> Float -> Float
decideWeaponDirection diff currentDirection currentDeltaPosition =
    if abs diff >= 92 && abs diff <= 108 || (abs diff <= 5) then
        currentDirection

    else if currentDeltaPosition >= 0 then
        1

    else
        -1


{-| Function for weapon angle.
-}
decideAngle : ( Float, Float ) -> ( Float, Float ) -> Float
decideAngle mousePos weaponpos =
    let
        slope =
            (Tuple.second weaponpos - Tuple.second mousePos) / (Tuple.first mousePos - Tuple.first weaponpos)

        angle =
            atan slope
    in
    angle


{-| Function for bullet and laser init.
-}
initBulletAndLaser : ( Float, Float ) -> Float -> Float -> ( SingleBullet, SingleBullet )
initBulletAndLaser position angle direction =
    let
        ( x, y ) =
            position

        ( x1, y1 ) =
            ( x + 30 * cos angle * direction, y - 30 * sin angle * direction )

        ( x2, y2 ) =
            ( x + 325 * cos angle * direction, y - 325 * sin angle * direction )

        bullet =
            { position = ( x1, y1 )
            , direction = direction
            , shape = ( 10, 5 )
            , angle = angle
            , bulletType = Ordinary
            , attack = 20
            }

        laser =
            { position = ( x2, y2 )
            , direction = direction
            , shape = ( 600, 40 )
            , angle = angle
            , bulletType = Laser
            , attack = 50
            }
    in
    ( bullet, laser )


{-| Function for shield bullet detect.
-}
shieldValidBullet : List EnemyBullet -> Shield -> List EnemyBullet
shieldValidBullet enemybullet shield =
    let
        ( x0, y0 ) =
            shield.position

        angle =
            shield.angle

        state =
            shield.shieldState

        isShield bullet =
            let
                ( a, b ) =
                    bullet.position

                deltaX =
                    x0 - a

                deltaY =
                    y0 - b

                rotateX =
                    deltaX * cos angle + deltaY * sin angle

                rotateY =
                    -deltaX * sin angle + deltaY * cos angle
            in
            (abs rotateX <= 15) && (abs rotateY <= 30)

        valid =
            List.filter (\b -> not (isShield b)) enemybullet
    in
    if state /= Unused then
        valid

    else
        enemybullet
