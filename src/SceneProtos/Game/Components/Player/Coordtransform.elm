module SceneProtos.Game.Components.Player.Coordtransform exposing (screentocanvas, canvastoscreen, help_vx1)

{-|


# Coordtransform

Functions for transforming coordinates between screen and canvas space.

@docs screentocanvas, canvastoscreen, help_vx1

-}

import REGL.Common exposing (Camera)


{-| Converts screen coordinates to canvas coordinates based on the camera.
-}
screentocanvas : Camera -> ( Float, Float ) -> ( Float, Float )
screentocanvas camera ( x, y ) =
    let
        scale =
            camera.zoom

        angle =
            camera.rotation

        cosAngle =
            cos angle

        sinAngle =
            sin angle

        xvector =
            camera.x - 1920 / 2

        yvector =
            camera.y - 1080 / 2

        newx =
            x / scale + xvector

        newy =
            y / scale + yvector
    in
    if angle == 0 then
        ( newx, newy )

    else
        ( newx * cosAngle + newy * sinAngle
        , newy * cosAngle - newx * sinAngle
        )


{-| Converts canvas coordinates to screen coordinates based on the camera.
-}
canvastoscreen : Camera -> ( Float, Float ) -> ( Float, Float )
canvastoscreen camera ( x, y ) =
    let
        ag =
            camera.rotation

        ( sa, ca ) =
            ( sin ag, cos ag )

        ( yv, xv ) =
            ( 1080 / 2 - camera.y, 1920 / 2 - camera.x )

        s =
            camera.zoom

        x1 =
            (x + xv) * s

        y1 =
            (y + yv) * s
    in
    if ag == 0 then
        ( x1, y1 )

    else
        ( y1 * sa + x1 * ca
        , (-x1 * sa) + y1 * ca
        )


{-| Helper function to calculate a velocity based on an angle.
-}
help_vx1 : Float -> Float
help_vx1 angle =
    if (angle > 0) && (angle <= pi / 2) then
        (pi / 2 - angle) / (pi / 2) * 3000

    else if (angle > -pi / 2) && (angle < 0) then
        -(angle + pi / 2) / (pi / 2) * 3000

    else
        0
