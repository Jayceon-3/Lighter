module SceneProtos.Game.Components.Survcamera.Cchangemode exposing (judgeactivate)

{-|


# Cchangemode

Functions for changing mode of survcameras

@docs judgeactivate

-}

import Length exposing (points)
import REGL.BuiltinPrograms exposing (poly)


getlines : List ( Float, Float ) -> List ( ( Float, Float ), ( Float, Float ) )
getlines points =
    case points of
        [] ->
            []

        _ ->
            let
                nextPoints =
                    List.drop 1 points ++ [ List.head points |> Maybe.withDefault ( 0, 0 ) ]
            in
            List.map2 Tuple.pair points nextPoints


onepointoneline : ( Float, Float ) -> ( ( Float, Float ), ( Float, Float ) ) -> Bool
onepointoneline ( x, y ) ( ( x1, y1 ), ( x2, y2 ) ) =
    if abs (y2 - y1) > 0.0001 then
        ((y1 <= y && y2 >= y)
            || (y1 >= y && y2 <= y)
        )
            && (x <= (x2 - x1) * (y - y1) / (y2 - y1) + x1)

    else if abs (y - y1) < 0.0001 && x >= x1 && x <= x2 then
        True

    else
        False


onepointlines : ( Float, Float ) -> List ( ( Float, Float ), ( Float, Float ) ) -> Bool
onepointlines player lines =
    let
        points =
            List.filter
                (\l ->
                    let
                        myjudge =
                            onepointoneline player l
                    in
                    myjudge
                )
                lines

        length =
            List.length points

        judge =
            modBy 2 length == 1
    in
    judge


{-| judge whether the survcamera should be activated
-}
judgeactivate : ( Float, Float ) -> List ( Float, Float ) -> Float -> Float -> Bool
judgeactivate player poly middle height =
    let
        lines =
            getlines poly

        ( x, y ) =
            player

        judge1 =
            onepointlines ( x - 15, y - 30 ) lines
                || onepointlines ( x + 15, y - 30 ) lines
                || onepointlines ( x - 15, y + 30 ) lines
                || onepointlines ( x + 15, y + 30 ) lines

        judge2 =
            abs (x - middle) <= 240 / 3 * height

        judge =
            judge1 && judge2
    in
    judge
