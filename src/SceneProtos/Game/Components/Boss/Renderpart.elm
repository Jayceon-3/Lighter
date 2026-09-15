module SceneProtos.Game.Components.Boss.Renderpart exposing (renderlasers)

{-|


# Renderpart

Render boss laser.

@docs renderlasers

-}

import Color
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import Random
import SceneProtos.Game.Components.Boss.Droneupdate exposing (otherlist)
import SceneProtos.Game.Components.Boss.Init exposing (..)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance)


{-| Render boss lasers.
-}
renderlasers : List Elaser -> Float -> Renderable
renderlasers laser time =
    group
        []
        (List.map
            (\l ->
                renderalaser l time
            )
            laser
        )


renderalaser : Elaser -> Float -> Renderable
renderalaser laser time =
    let
        render =
            group
                []
                (List.map
                    (\a ->
                        let
                            ( x, y ) =
                                a.position

                            ( m, n, k ) =
                                if a.color == 1 then
                                    color1 time a

                                else
                                    otherlist time a

                            result =
                                P.rect ( x - 5, y - 5 ) ( 10, 10 ) (Color.rgb m n k)
                        in
                        result
                    )
                    laser.atoms
                )
    in
    render


color1 : Float -> Atom -> ( Float, Float, Float )
color1 time a =
    if time - a.releasetime <= 0.25 * a.targettime then
        ( 0.9, 0.7, 0.1 )
        -- (0.5, 0.4, 0.0) lighter

    else if time - a.releasetime <= 0.5 * a.targettime then
        ( 1.0, 0.8, 0.3 )
        -- (0.8, 0.6, 0.2) lighter

    else if time - a.releasetime <= 0.75 * a.targettime then
        ( 1.0, 1.0, 0.3 )
        -- (1.0, 0.9, 0.0) lighter

    else
        ( 1.0, 1.0, 0.9 )



-- (1.0, 1.0, 0.8) lighter
