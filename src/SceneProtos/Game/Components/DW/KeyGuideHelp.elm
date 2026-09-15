module SceneProtos.Game.Components.DW.KeyGuideHelp exposing
    ( decideAngle
    , takeFirstThreePos
    , toTuple
    )

{-|


# KeyGuideHelp

Helper functions for rendering key guide icon in the game.

@docs decideAngle
@docs takeFirstThreePos
@docs toTuple

-}


{-| Helper function to get first three elements in a list.
-}
takeFirstThreePos : List ( Float, Float ) -> List ( Float, Float )
takeFirstThreePos list =
    list
        |> List.take 3


{-| Helper function to turn a list into a tuple.
-}
toTuple : List ( Float, Float ) -> Maybe ( ( Float, Float ), ( Float, Float ), ( Float, Float ) )
toTuple list =
    case list of
        [ x, y, z ] ->
            Just ( x, y, z )

        [ x, y ] ->
            Just ( x, y, ( 0, 0 ) )

        [ x ] ->
            Just ( x, ( 0, 0 ), ( 0, 0 ) )

        _ ->
            Nothing


{-| Helper function to decide the angle of the keyGuide icon.
-}
decideAngle : ( Float, Float ) -> ( Float, Float ) -> Float
decideAngle pos1 pos2 =
    let
        slope =
            (Tuple.second pos2 - Tuple.second pos1) / (Tuple.first pos1 - Tuple.first pos2)

        angle =
            atan slope
    in
    angle
