module Scenes.Level1.Generateenemy exposing (egenerator, cgenerator, sortPoints, generateenemies, generatecameras)

{-|


# Generateenemy

Functions to generate enemies and surveillance cameras in the game scene.

@docs egenerator, cgenerator, sortPoints, generateenemies, generatecameras

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Random
import SceneProtos.Game.Components.Enemy.Init as EnemyInit exposing (..)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..))
import SceneProtos.Game.Components.Survcamera.Init as SurvcameraInit exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)
import Scenes.Level1.Getbound exposing (..)


{-| Generate an enemy at a specified position with a list of tiles and a skin type.
-}
egenerator : Int -> ( ( Float, Float ), Int ) -> List ( Int, Int, Tile ) -> Enemy
egenerator pattern ( newposition, skin ) temptiles =
    let
        ( m, n ) =
            newposition

        randomDir =
            decideDir pattern skin

        newtiles =
            List.filter
                (\t ->
                    let
                        ( tempx, tempy, _ ) =
                            t

                        x =
                            toFloat tempx

                        y =
                            toFloat tempy

                        judge =
                            n - 30 <= y && y <= n + 100 && abs (x - m) <= 540
                    in
                    judge
                )
                temptiles
    in
    { position = newposition
    , defaultposition = newposition

    -- (290,1950), (1200,1770),( 1020, 2070 )
    , direction = randomDir
    , vx = 0.2
    , vy = 0
    , hp = 200
    , enemystate = EnemyInit.Default
    , enemytype = EnemyInit.Advanced
    , angle = 0
    , time = 0
    , appear = skin
    , target = ( 0, 0 )
    , tiles = newtiles
    , have_droped_or_not = False
    }


genRandomNum : Int -> Int -> Int -> Int
genRandomNum lowerBound upperBound time =
    let
        ( value, _ ) =
            Random.step (Random.int lowerBound upperBound) <|
                Random.initialSeed <|
                    time
    in
    value


dirPattern : Env () UserData -> Int
dirPattern env =
    let
        time =
            round env.globalData.currentTimeStamp

        pattern =
            genRandomNum 1 3 time
    in
    pattern


decideDirHelp : Int -> Int -> Float
decideDirHelp p s =
    if p == s then
        1

    else
        -1


decideDir : Int -> Int -> Float
decideDir pattern skin =
    if pattern == 1 then
        decideDirHelp 1 skin

    else if pattern == 2 then
        decideDirHelp 2 skin

    else
        decideDirHelp 3 skin


{-| Generate a surveillance camera at a specified position with a list of tiles.
-}
cgenerator : ( ( Float, Float ), Float ) -> List ( Int, Int, Tile ) -> Survcamera
cgenerator ( newposition, nowheight ) temptiles =
    let
        ( m, n ) =
            newposition

        newtiles =
            List.filter
                (\t ->
                    let
                        ( tempx, tempy, tile ) =
                            t

                        x =
                            toFloat tempx

                        y =
                            toFloat tempy

                        judge1 =
                            n <= y && y <= n + nowheight * 60 + 120 && abs (x - m) <= (300 / 3 * nowheight + 120)

                        judge2 =
                            tile.kind == SolidTop || tile.kind == SolidMiddle || tile.kind == FakeBlock || tile.kind == Frame
                    in
                    judge1 && judge2
                )
                temptiles

        temp1bounds =
            List.map
                (\t ->
                    let
                        ( tempx, tempy, _ ) =
                            t
                    in
                    [ ( toFloat tempx - 30, toFloat tempy - 30 ), ( toFloat tempx + 30, toFloat tempy - 30 ) ]
                )
                newtiles
                |> List.concat

        temp2bounds =
            getboundpoints newtiles

        newbounds =
            List.filter
                (\p ->
                    List.member p temp1bounds
                )
                temp2bounds
                |> sortPoints
    in
    { --( 1020, 1920 )
      position = newposition
    , defaultpoint = ( m, n + 60 * nowheight )
    , direction = -1
    , angle = pi / 2
    , hp = 100
    , bounds = ( ( m - 14 * nowheight, n + 60 * nowheight ), ( m + 20 * nowheight, n + 60 * nowheight ) )
    , drawpoints = [ ( m + 20 * nowheight, n + 60 * nowheight ), newposition, ( m - 14 * nowheight, n + 60 * nowheight ) ]

    -- Okay, I think adding drawpoints manually would be much faster and time-effective
    , isAlive = True
    , time = 0
    , camerastate = SurvcameraInit.Default
    , tiles = newtiles
    , tilebound = newbounds
    , target = ( 0, 0 )
    , height = nowheight
    }


{-| Sort a list of points based on their x and y coordinates.
-}
sortPoints : List ( Float, Float ) -> List ( Float, Float )
sortPoints points =
    List.sortBy (\( x, y ) -> ( x, y )) points


{-| Function of generating cameras.
-}
generatecameras : List ( ( Float, Float ), Float ) -> List ( Int, Int, Tile ) -> List Survcamera
generatecameras points tile =
    List.map
        (\p ->
            cgenerator p tile
        )
        points


{-| Function of generating enemies.
-}
generateenemies : Env () UserData -> List ( ( Float, Float ), Int ) -> List ( Int, Int, Tile ) -> List Enemy
generateenemies env infolist tiles =
    let
        pattern =
            dirPattern env
    in
    List.map
        (\info ->
            egenerator pattern info tiles
        )
        infolist
