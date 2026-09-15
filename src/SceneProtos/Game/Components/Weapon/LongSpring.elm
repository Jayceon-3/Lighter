module SceneProtos.Game.Components.Weapon.LongSpring exposing (longSpring)

{-|


# LongSpring

This module contains functions for the update function of Long swing mode of mechanical arm.

@docs longSpring

-}

-- theta0 = pi/4 k = 20, L0 = 1


{-| Update function for long spring.
-}
longSpring : Float -> ( Float, Float ) -> Float -> ( Float, Float )
longSpring dir initPos deltaT =
    let
        ( x0, y0 ) =
            initPos

        a4_x =
            0.8242 * 400

        w_x =
            0.4924 * 1.5

        x =
            x0 + dir * a4_x * (1 - cos (4 * w_x * deltaT))

        a0_y =
            -1.364 * 150

        a3_y =
            0.6695 * 150

        a4_y =
            0.0158 * 150

        w_y =
            1.312 * 1.5

        y =
            y0 + (a0_y + a3_y + a4_y) - (a0_y + a3_y * cos (3 * w_y * deltaT) + a4_y * cos (4 * w_y * deltaT))
    in
    ( x, y )
