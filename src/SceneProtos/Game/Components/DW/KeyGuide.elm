module SceneProtos.Game.Components.DW.KeyGuide exposing
    ( getKeyBlockPos
    , renderKeyGuide
    )

{-|


# KeyGuide

Functions for rendering key guide icon in the game.

The icons can only be viewable in digital world.

It's designed to tell the player where are the keys in this level.

@docs getKeyBlockPos
@docs renderKeyGuide

-}

import Color
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Camera, Renderable, group)
import SceneProtos.Game.Components.DW.KeyGuideHelp exposing (decideAngle, takeFirstThreePos, toTuple)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..))
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The function obtain the positions of keys in the map.
-}
getKeyBlockPos : List ( Int, Int, Tile ) -> Maybe ( ( Float, Float ), ( Float, Float ), ( Float, Float ) )
getKeyBlockPos tiles =
    let
        keyTiles =
            tiles
                |> List.filter
                    (\( _, _, t ) ->
                        t.kind
                            == KeyBlock
                            && t.solid
                    )

        tempKeyPos =
            keyTiles
                |> List.map
                    (\( x, y, t ) ->
                        ( toFloat x, toFloat y )
                    )

        keyPos =
            tempKeyPos
                |> takeFirstThreePos
                |> toTuple
    in
    keyPos


judgeRender : ( Float, Float ) -> ( Float, Float ) -> Bool
judgeRender keyPos dwPos =
    let
        ( x, y ) =
            keyPos

        ( x0, y0 ) =
            dwPos

        judge =
            (abs (x - x0) >= 1960 / 3 || abs (y - y0) >= 1080 / 3) && keyPos /= ( 0, 0 )
    in
    judge


decideDir : Float -> Float -> Float
decideDir x1 x0 =
    if x1 - x0 >= 0 then
        1

    else
        -1


renderOneKey : Float -> Bool -> ( Float, Float ) -> ( Float, Float ) -> Camera -> ( List Renderable, ( ( Float, Float ), Bool ) )
renderOneKey angle judge dwPos keyPos camera =
    let
        ( x0, y0 ) =
            dwPos

        ( x1, y1 ) =
            keyPos

        dir =
            decideDir x1 x0

        cameraPos =
            ( toFloat (round camera.x), toFloat (round camera.y) )

        pos =
            generatePos dir
                angle
                dwPos
                cameraPos

        floorAngle =
            round (angle * 10)

        roundedAngle =
            toFloat floorAngle / toFloat 10

        keyAngle =
            if dir >= 0 then
                roundedAngle + (pi / 2)

            else
                roundedAngle - (pi / 2)

        render =
            if judge then
                [ P.centeredTexture pos ( dir * 50, 55 ) keyAngle "keyArrow" ]

            else
                [ P.empty ]
    in
    ( render, ( pos, judge ) )


addDis : Float -> ( Float, Float ) -> Float -> ( Float, Float )
addDis dir pos angle =
    let
        ( x0, y0 ) =
            pos

        newPos =
            ( x0 + dir * 20 * cos angle, y0 - dir * 20 * sin angle )
    in
    newPos


judgeEdge : Float -> Float -> ( Float, Float ) -> ( Float, Float ) -> Bool
judgeEdge dir angle keyPos cameraPos =
    let
        ( x, y ) =
            cameraPos

        ( x0, y0 ) =
            keyPos

        judge =
            if dir >= 0 then
                if abs angle <= pi / 4 then
                    (x + 1960 / 2)
                        - x0
                        >= 70

                else if angle >= 0 then
                    y0
                        - (y - 1080 / 2)
                        >= 70

                else
                    (y + 1080 / 2)
                        - y0
                        >= 70

            else if abs angle <= pi / 4 then
                x0
                    - (x - 1960 / 2)
                    >= 70

            else if angle >= 0 then
                (y + 1080 / 2)
                    - y0
                    >= 70

            else
                y0
                    - (y - 1080 / 2)
                    >= 70
    in
    judge



--Helper function to get the current edge position of the screen (camera).


edgeCameraPos : ( Float, Float ) -> Float -> Float -> ( Float, Float )
edgeCameraPos cameraPos dir angle =
    let
        ( x, y ) =
            cameraPos

        newPos =
            if dir >= 0 then
                if angle >= 0 then
                    ( x + 1960 / 2, y - 1080 / 2 )

                else
                    ( x + 1960 / 2, y + 1080 / 2 )

            else if angle >= 0 then
                ( x - 1960 / 2, y + 1080 / 2 )

            else
                ( x - 1960 / 2, y - 1080 / 2 )
    in
    newPos



-- Fuunction to avoid high-frequency shaking of the texture.


stablePos : Float -> Float -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
stablePos dir angle keyPos edgePos =
    let
        ( ( x0, y0 ), ( x1, y1 ) ) =
            ( keyPos, edgePos )

        x =
            if abs (x0 - x1) <= 80 then
                x1 - dir * 80

            else
                x0

        y =
            if abs (y0 - y1) <= 80 then
                if dir * angle >= 0 then
                    y1 + 80

                else
                    y1 - 80

            else
                y0
    in
    ( x, y )


generatePos : Float -> Float -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
generatePos dir angle pos cameraPos =
    if judgeEdge dir angle pos cameraPos then
        let
            newPos =
                addDis dir pos angle
        in
        generatePos dir angle newPos cameraPos

    else
        let
            ( x0, y0 ) =
                pos

            ( x1, y1 ) =
                edgeCameraPos cameraPos dir angle

            ( x, y ) =
                stablePos dir angle pos ( x1, y1 )
        in
        ( toFloat (round x), toFloat (round y) )


{-| The function to render key guide icons in DW.
-}
renderKeyGuide : Env SceneCommonData UserData -> ( Float, Float ) -> Maybe ( ( Float, Float ), ( Float, Float ), ( Float, Float ) ) -> ( List Renderable, ( ( ( Float, Float ), Bool ), ( ( Float, Float ), Bool ), ( ( Float, Float ), Bool ) ) )
renderKeyGuide env dwPos keyPos =
    let
        ( first, second, third ) =
            case keyPos of
                Just pos ->
                    pos

                Nothing ->
                    ( ( 0, 0 ), ( 0, 0 ), ( 0, 0 ) )

        camera =
            env.globalData.camera

        ( angle1, judge1 ) =
            ( decideAngle first dwPos, judgeRender first dwPos )

        ( angle2, judge2 ) =
            ( decideAngle second dwPos, judgeRender second dwPos )

        ( angle3, judge3 ) =
            ( decideAngle third dwPos, judgeRender third dwPos )

        renderGuides =
            Tuple.first (renderOneKey angle1 judge1 dwPos first camera)
                ++ Tuple.first (renderOneKey angle2 judge2 dwPos second camera)
                ++ Tuple.first (renderOneKey angle3 judge3 dwPos third camera)
    in
    ( renderGuides, ( Tuple.second (renderOneKey angle1 judge1 dwPos first camera), Tuple.second (renderOneKey angle2 judge2 dwPos first camera), Tuple.second (renderOneKey angle3 judge3 dwPos first camera) ) )
