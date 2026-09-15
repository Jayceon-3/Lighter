module SceneProtos.Game.Components.Weapon.DashShorteningHelp exposing (dashMove, shortening)

{-|


# DashShorteningHelp

This module contains functions for the logic for mechanical arm dash mode and shortening mode movements in the game.

@docs dashMove, shortening

-}


updatePosition : Float -> Float -> Float -> ( ( Float, Float ), ( Float, Float ) ) -> ( ( Float, Float ), ( Float, Float ) )
updatePosition ax ay dt ( position, speed ) =
    let
        ( x0, y0 ) =
            position

        ( vx0, vy0 ) =
            speed

        ( vx, vy ) =
            ( vx0 + ax * dt / 1000, vy0 + ay * dt / 1000 )

        ( x, y ) =
            ( x0 + vx * dt / 1000, y0 + vy * dt / 1000 )
    in
    ( ( x, y ), ( vx, vy ) )


{-| Function for dash mode update.
-}
dashMove : Float -> Float -> ( Float, Float ) -> Float -> ( Float, Float )
dashMove dir angle pos dt =
    let
        ( x0, y0 ) =
            pos

        v =
            800

        vx =
            v * cos angle

        vy =
            v * abs (sin angle)

        ( x, y ) =
            ( x0 + dir * vx * dt / 1000, y0 - vy * dt / 1000 )
    in
    ( x, y )


{-| Function for shortening mode update.
-}
shortening : Float -> ( ( Float, Float ), ( Float, Float ) ) -> Float -> ( ( ( Float, Float ), ( Float, Float ) ), Float, Bool )
shortening dt ( position, speed ) length =
    let
        ( ( x, y ), ( vx, vy ) ) =
            updatePosition 0 2000 dt ( position, speed )
    in
    if length > 0 then
        ( ( ( x, y ), ( vx, vy ) ), length - 72, True )

    else
        ( ( ( x, y ), ( vx, vy ) ), 0, False )
