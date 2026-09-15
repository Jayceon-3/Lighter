module SceneProtos.Game.Components.Drop.Dropview exposing (genColor, chooseColor, viewsingledrop, viewdrops, choosetexture, viewsingledropWithTexture, viewdropsWithTexture, coordoncanvas, firstpos, singlepos, textsize, iconsize, interval, textpos, whiteColor, view_life_got)

{-|


# Dropview

Functions to render drops in the game scene.

@docs genColor, chooseColor, viewsingledrop, viewdrops, choosetexture, viewsingledropWithTexture, viewdropsWithTexture, coordoncanvas, firstpos, singlepos, textsize, iconsize, interval, textpos, whiteColor, view_life_got

-}

import Color exposing (Color)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Camera, Renderable, group)
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


{-| Generates a color based on the provided RGBA values.
-}
genColor : Float -> Float -> Float -> Float -> Color
genColor r g b a =
    Color.fromRgba { red = r, green = g, blue = b, alpha = a }


{-| Chooses a color for the drop based on its type.
-}
chooseColor : Singledrop -> Color
chooseColor drop =
    case drop.droptype of
        -- Green for Life
        Life ->
            genColor 0 1 0 1

        -- Blue for Energy
        Energy ->
            genColor 0 0 1 1

        -- Red for Scatter
        Scatterbullet ->
            genColor 1 0 0 1


{-| Renders a single drop as a rounded rectangle with the chosen color.
-}
viewsingledrop : Singledrop -> Renderable
viewsingledrop drop =
    let
        ( x, y ) =
            drop.viewpos

        color =
            chooseColor drop
    in
    P.roundedRect
        ( x, y )
        ( drop.size, drop.size )
        0.5
        color


{-| Renders a list of drops as a group of rounded rectangles.
-}
viewdrops : List Singledrop -> Renderable
viewdrops drops =
    group
        []
        (List.map viewsingledrop drops)


{-| Chooses the texture for a drop based on its type.
-}
choosetexture : Singledrop -> String
choosetexture drop =
    case drop.droptype of
        Life ->
            "life"

        Energy ->
            "energy"

        Scatterbullet ->
            "scatter"


{-| Renders a single drop with its texture.
-}
viewsingledropWithTexture : Singledrop -> Renderable
viewsingledropWithTexture drop =
    let
        a =
            drop.viewpos
                |> Tuple.first

        s =
            drop.size + 20

        texture =
            choosetexture drop

        b =
            Tuple.second <|
                drop.viewpos
    in
    P.centeredTexture
        ( a, b )
        ( s, s )
        0
        texture


{-| Renders a list of drops with their textures.
-}
viewdropsWithTexture : List Singledrop -> Renderable
viewdropsWithTexture drops =
    group
        []
        (List.map viewsingledropWithTexture drops)


{-| Converts the coordinates of a drop to canvas coordinates based on the camera's position and zoom.
-}
coordoncanvas : Camera -> ( Float, Float ) -> ( Float, Float )
coordoncanvas camera ( x, y ) =
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


{-| The size of the text used for displaying drop counts.
-}
textsize : Float
textsize =
    20


{-| The size of the icons used for displaying drops.
-}
iconsize : Float
iconsize =
    60


{-| The interval between the positions of the drops in the scene.
-}
interval : Float
interval =
    80


{-| Calculates the position for displaying text above the drop icons.
-}
textpos : ( Float, Float ) -> ( Float, Float )
textpos ( x, y ) =
    ( x, y + iconsize - 10 )


{-| A white color used for text rendering.
-}
whiteColor : Color
whiteColor =
    genColor 1 1 1 1


{-| Renders the life drop count as text and an icon.
-}
view_life_got : Camera -> Data -> Renderable
view_life_got camera data =
    let
        pos =
            coordoncanvas camera firstpos

        life =
            data.lifedrop

        s =
            "x" ++ String.fromInt life

        c =
            "consolas"

        -- iconsize =
        --     30
        -- textsize =
        --     20
        icon =
            ( iconsize, iconsize )

        -- lifetextpos =
        --     textpos pos
        lifetext =
            P.textboxCentered
                (textpos pos)
                textsize
                s
                c
                (genColor 1 1 1 1)

        angle =
            0

        lifeicon =
            P.centeredTexture
                pos
                icon
                angle
                "life"
    in
    group [] [ lifetext, lifeicon ]



-- keyrender : Camera -> Renderable
-- keyrender camera =
--         pos =
--             coordoncanvas camera firstpos
--         ( x1, y ) =
--             ( Tuple.first pos - iconsize / 2 + 5, Tuple.second pos - iconsize / 2 + 10 )
--         ( x2, x3 ) =
--             ( x1 + interval, x1 + interval * 2 )
