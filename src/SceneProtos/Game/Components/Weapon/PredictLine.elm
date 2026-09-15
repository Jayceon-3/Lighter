module SceneProtos.Game.Components.Weapon.PredictLine exposing (predictLine)

{-|


# PredictLine

This module contains functions for the logic for the predict line generation in the game.

@docs predictLine

-}

import Color
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable)
import SceneProtos.Game.Components.Map.Init as MapInit exposing (Tile)


addPos : Float -> List ( Float, Float ) -> Float -> List ( Float, Float )
addPos weaponDir posList angle =
    let
        ( x0, y0 ) =
            case List.head posList of
                Just p ->
                    p

                _ ->
                    ( 0, 0 )

        newPos =
            ( x0 + weaponDir * 20 * cos angle, y0 - weaponDir * 20 * sin angle )

        newList =
            newPos :: posList
    in
    newList


generatePosList : Int -> Float -> Float -> List ( Float, Float ) -> List ( Float, Float )
generatePosList n weaponDir angle initialPosList =
    if n <= 0 then
        initialPosList

    else
        let
            newPosList =
                addPos weaponDir initialPosList angle
        in
        generatePosList (n - 1) weaponDir angle newPosList


{-| Render function for predict line.
-}
predictLine : Float -> Float -> ( Float, Float ) -> List ( Int, Int, Tile ) -> List Renderable
predictLine weaponDir angle position tiles =
    let
        length =
            10

        width =
            5

        ( x0, y0 ) =
            position

        initialPosList =
            [ ( x0 + weaponDir * 40 * cos angle, y0 - weaponDir * 40 * sin angle ) ]

        n =
            decideN 0 position angle weaponDir tiles

        positionList =
            generatePosList n weaponDir angle initialPosList
    in
    List.map
        (\pos ->
            let
                ( x, y ) =
                    pos
            in
            [ P.rectCentered ( x, y ) ( length, width ) angle Color.red ]
        )
        positionList
        |> List.concat


judgeLineTile : ( Float, Float ) -> ( Int, Int, Tile ) -> Bool
judgeLineTile lineEdge tile =
    let
        ( x1, y1 ) =
            lineEdge

        ( x2, y2, t ) =
            tile

        judge =
            t.solid && abs (x1 - toFloat x2) <= 30 && abs (y1 - toFloat y2) <= 30
    in
    judge


decideN : Int -> ( Float, Float ) -> Float -> Float -> List ( Int, Int, Tile ) -> Int
decideN j ( x0, y0 ) angle weaponDir tiles =
    let
        lineEdge =
            ( x0 + toFloat j * weaponDir * 20 * cos angle, y0 - toFloat j * weaponDir * 20 * sin angle )

        judge =
            List.map (\( x, y, t ) -> judgeLineTile lineEdge ( x, y, t )) tiles
                |> List.any identity
    in
    if judge then
        j - 3

    else
        decideN (j + 1) ( x0, y0 ) angle weaponDir tiles
