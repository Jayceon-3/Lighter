module SceneProtos.Game.Components.Drop.Viewhelper exposing
    ( keyrender
    , view_scatter_got, view_energy_got
    )

{-|


# Viewhelper

Functions for rendering drops in the game.

@docs keyrender
@docs view_scatter_got, view_energy_got

-}

import Color exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Camera, Renderable, group)
import SceneProtos.Game.Components.Drop.Dropview exposing (coordoncanvas, firstpos, iconsize, interval, textsize, whiteColor)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..), Singledrop)


{-| The data structure for the drop component. Copied from the Model to avoid import loop.
-}
type alias Data =
    { drops : List Singledrop
    , playerpos : ( Float, Float )
    , lifedrop : Int
    , energydrop : Int
    , scatterdrop : Int
    }


{-| Renders the key indicators for the drop types in the game.
-}
keyrender : Camera -> Renderable
keyrender camera =
    let
        pos =
            coordoncanvas camera firstpos

        ( x1, y ) =
            ( Tuple.first pos - iconsize / 2 + 5, Tuple.second pos - iconsize / 2 + 10 )

        ( x2, x3 ) =
            ( x1 + interval, x1 + interval * 2 )
    in
    group []
        [ P.textboxCentered
            ( x1, y )
            textsize
            "1"
            "consolas"
            whiteColor
        , P.textboxCentered
            ( x2, y )
            textsize
            "2"
            "consolas"
            whiteColor
        , P.textboxCentered
            ( x3, y )
            textsize
            "3"
            "consolas"
            whiteColor
        ]


{-| The initial position for the first drop in the scene.
-}
firstpos : ( Float, Float )
firstpos =
    ( 1660, 880 )


{-| Converts a single position offset to a coordinate based on the first position.
-}
singlepos : Float -> ( Float, Float )
singlepos x =
    ( (firstpos |> Tuple.first) + x, firstpos |> Tuple.second )


{-| Calculates the position for displaying text above the drop icons.
-}
textpos : ( Float, Float ) -> ( Float, Float )
textpos ( x, y ) =
    ( x, y + iconsize - 10 )


{-| Renders the scatter drop count as text and an icon.
-}
view_scatter_got : Camera -> Data -> Renderable
view_scatter_got camera data =
    let
        ( xscatter, yscatter ) =
            coordoncanvas camera (singlepos (interval * 2))

        scatter =
            data.scatterdrop

        scattertextpos =
            textpos ( xscatter, yscatter )

        scattertext =
            P.textboxCentered
                scattertextpos
                textsize
                ("x" ++ String.fromInt scatter)
                "consolas"
                whiteColor

        scattericon =
            P.centeredTexture
                ( xscatter, yscatter )
                ( iconsize, iconsize )
                0
                "scatter"
    in
    group []
        [ scattertext, scattericon ]


{-| Renders the energy drop count as text and an icon.
-}
view_energy_got : Camera -> Data -> Renderable
view_energy_got camera data =
    let
        ( xenergy, yenergy ) =
            coordoncanvas
                camera
                (singlepos interval)

        energy =
            data.energydrop

        -- energytextpos =
        --     ( xenergy, yenergy + iconsize )
        txt =
            "x" ++ String.fromInt energy

        energytext =
            P.textboxCentered
                ( xenergy, yenergy + iconsize - 10 )
                textsize
                txt
                "consolas"
                whiteColor

        energyicon =
            P.centeredTexture
                (coordoncanvas camera (singlepos interval))
                ( iconsize, iconsize )
                0
                "energy"
    in
    group [] [ energytext, energyicon ]
