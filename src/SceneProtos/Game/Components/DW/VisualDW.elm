module SceneProtos.Game.Components.DW.VisualDW exposing
    ( decideAlpha
    , genRandomNum
    , refreshSurroundedTiles
    )

{-|


# VisualDW

Functions to implement core visual effects in DW.

The glitching effects and random type update special bricks are implemented here.

@docs decideAlpha
@docs genRandomNum
@docs refreshSurroundedTiles

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import Random
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..))
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


distance : ( Float, Float ) -> ( Float, Float ) -> Float
distance ( x1, y1 ) ( x2, y2 ) =
    sqrt ((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))


updateDistance : ( Float, Float ) -> ( Float, Float ) -> Float
updateDistance dwPos effectPos =
    let
        dis =
            distance dwPos effectPos

        newDis =
            if dis >= 100 then
                dis

            else
                dis + 5
    in
    newDis



-- decideAlpha : Env SceneCommonData UserData -> Int -> Float
-- decideAlpha env time =
--     if genRandomNum 0 1 time == 1 then
--         if modBy 6 (floor (env.globalData.currentTimeStamp / 1000)) == 0 then
--             toFloat random / toFloat 4
--         else
--             1
--     else
--         1


{-| Funciton to genetate glitching effect of player in the digital world.
-}
decideAlpha : Env SceneCommonData UserData -> Int -> Float
decideAlpha env time =
    let
        randomValue =
            toFloat (genRandomNum 0 1000 time) / 1000

        shouldGlitch =
            randomValue < glitchChance

        glitchDuration =
            0.2

        intensity =
            1.0

        glitchChance =
            0.5

        currentTimeSec =
            env.globalData.currentTimeStamp / 1000

        isGlitching =
            shouldGlitch
                && (modBy 5 (floor currentTimeSec) == 0)

        glitchIntensity =
            if isGlitching then
                intensity * (0.3 + 0.7 * (toFloat (genRandomNum 0 100 (time + 1)) / 100))

            else
                0

        alpha =
            if isGlitching then
                if modBy 3 (floor (currentTimeSec * 10)) == 0 then
                    0

                else
                    1 - glitchIntensity

            else
                1
    in
    alpha



-- renderEffect : ( Float, Float ) -> Float -> Float -> List Renderable
-- renderEffect dwPos dis dir =
--     let


{-| Funciton to generate random number.

To use it, you need to input the lowerBound and the upperBound of the random number.

And it needs a time seed as an input too.

-}
genRandomNum : Int -> Int -> Int -> Int
genRandomNum lowerBound upperBound time =
    let
        ( value, _ ) =
            Random.step (Random.int lowerBound upperBound) <|
                Random.initialSeed <|
                    time
    in
    value


getRandomType : ( Int, Int, Tile ) -> Int -> ( Int, Int, Tile )
getRandomType tileInfo time =
    let
        ( x, y, t ) =
            tileInfo

        tileKind =
            t.kind

        newKind =
            getNewKind tileKind time

        newTile =
            { solid = True, kind = newKind }
    in
    ( x, y, newTile )


getNewKind : TileKind -> Int -> TileKind
getNewKind kind time =
    let
        tempRandomNum =
            genRandomNum 0 1000 time

        randomNum =
            toFloat tempRandomNum / 1000

        timeSec =
            toFloat time / 1000

        updateJudge =
            modBy 3 (floor timeSec) == 0

        tempKind1 =
            if randomNum <= 0.2 then
                SolidTop

            else if randomNum <= 0.8 then
                DamageBlock

            else
                RecoverBlock

        tempKind2 =
            if randomNum <= 0.7 then
                DamageBlock

            else if randomNum <= 0.9 then
                RecoverBlock

            else
                SolidTop

        tempKind3 =
            if randomNum <= 0.6 then
                RecoverBlock

            else if randomNum <= 0.8 then
                DamageBlock

            else
                SolidTop

        newKind =
            if updateJudge then
                case kind of
                    SolidTop ->
                        tempKind1

                    DamageBlock ->
                        tempKind2

                    RecoverBlock ->
                        tempKind3

                    _ ->
                        kind

            else
                kind
    in
    newKind


{-| Funciton to refresh surrounded tiles of dw randomly.
-}
refreshSurroundedTiles : List ( Int, Int, Tile ) -> ( Float, Float ) -> Int -> List ( Int, Int, Tile )
refreshSurroundedTiles tiles dwPos time =
    let
        ( x0, y0 ) =
            dwPos

        judge ( x1, y1 ) ( x2, y2 ) =
            distance ( toFloat x1, toFloat y1 ) ( x2, y2 ) <= 600

        -- tileList =
        --     tiles
        --         |> List.filter
        --             (\( x, y, t ) ->
        --                 t.solid
        --                     && judge ( x, y ) ( x0, y0 )
        --             )
        -- -- |> List.filter (\( x, y, t ) -> judge ( x, y ) ( x0, y0 ))
        -- updatedTiles =
        --     tileList
        --         |> List.map
        --             (\( x, y, t ) ->
        --                 getRandomType ( x, y, t ) time
        --             )
        -- unchangedTiles =
        --     tiles
        --         |> List.filter (\tile -> not (List.member tile tileList))
        -- newTiles =
        --     updatedTiles ++ unchangedTiles
        newTiles =
            tiles
                |> List.map
                    (\( x, y, t ) ->
                        if t.solid && judge ( x, y ) ( x0, y0 ) then
                            getRandomType ( x, y, t ) time

                        else
                            ( x, y, t )
                    )
    in
    newTiles
