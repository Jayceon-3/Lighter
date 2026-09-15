module SceneProtos.Game.Components.Weapon.SpringPendulum exposing (shortSpring, mediumSpring)

{-|


# SpringPendulum

This module contains functions for the short and medium spring update.

@docs shortSpring, mediumSpring

-}

-- theta0 = pi/4 k = 90 L0 = 0.5


{-| Update function for short spring.
-}
shortSpring : Float -> ( Float, Float ) -> Float -> ( Float, Float )
shortSpring dir initPos deltaT =
    let
        ( x0, y0 ) =
            initPos

        -- a4_x =
        --     0.4173 * 400
        a4_x =
            0.4173 * 400

        w_x =
            0.8693 * 2

        x =
            x0 + dir * a4_x * (1 - cos (4 * w_x * deltaT))

        a0_y =
            -0.5345 * 200

        a2_y =
            0.1715 * 200

        a3_y =
            0.0255 * 200

        w_y =
            3.477 * 2

        y =
            y0 + (a0_y + a2_y + a3_y) - (a0_y + a2_y * cos (2 * w_y * deltaT) + a3_y * cos (3 * w_y * deltaT))
    in
    ( x, y )



-- theta0 = pi/4 k = 70 L0 = 0.7


{-| Update function for medium spring.
-}
mediumSpring : Float -> ( Float, Float ) -> Float -> ( Float, Float )
mediumSpring dir initPos deltaT =
    let
        ( x0, y0 ) =
            initPos

        a4_x =
            0.5797 * 300

        w_x =
            0.7479 * 2

        x =
            x0 + dir * a4_x * (1 - cos (4 * w_x * deltaT))

        a0_y =
            -0.7363 * 200

        a2_y =
            0.2249 * 200

        a3_y =
            0.001466 * 200

        b3_y =
            -0.02781 * 200

        w_y =
            2.944 * 2

        y =
            y0 + (a0_y + a2_y + a3_y) - (a0_y + a2_y * cos (2 * w_y * deltaT) + a3_y * cos (3 * w_y * deltaT)) + b3_y * sin (3 * w_y * deltaT)
    in
    ( x, y )
