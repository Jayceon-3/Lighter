module SceneProtos.Game.Components.Player.Recoil exposing (recoil, upperLimit)

{-|


# Recoil

Functions for handling recoil mechanics for player weapons.

@docs recoil, upperLimit

-}

import SceneProtos.Game.Components.Bullet.Init exposing (BulletType(..), SingleBullet)


{-| Calculates the recoil effect based on the bullet type, weapon direction, and bullet properties.
-}
recoil : BulletType -> Float -> SingleBullet -> ( Float, Float )
recoil bulletType weaponDir bullet =
    let
        angle =
            bullet.angle

        recoilForce =
            if bulletType == Ordinary then
                500

            else
                2000

        dvy =
            if angle * weaponDir > 0 then
                recoilForce * abs (sin angle)

            else
                -recoilForce * abs (sin angle)

        dvx =
            recoilForce * cos angle
    in
    ( dvx, dvy )


{-| Limits the recoil effect based on the bullet type to prevent excessive movement.
-}
upperLimit : BulletType -> Float -> Float
upperLimit bulletType v =
    let
        limit =
            if bulletType == Ordinary then
                600

            else
                1500
    in
    if v >= limit then
        limit

    else if v <= -limit then
        -limit

    else
        v
