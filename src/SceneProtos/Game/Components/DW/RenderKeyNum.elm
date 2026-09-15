module SceneProtos.Game.Components.DW.RenderKeyNum exposing
    ( keyAnimation
    , keyNumRender
    , updateKeyPos
    )

{-|


# RenderKeyNum

Functions to render curent keyNum.

The icon will appear on the left top corner of the screen.

@docs keyAnimation
@docs keyNumRender
@docs updateKeyPos

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.Coordinate.Camera exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Camera, Renderable, group)
import Random
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection(..), Tile, TileKind(..))
import SceneProtos.Game.Components.Player.Coordtransform exposing (screentocanvas)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


type alias Data =
    { id : Int
    , ty : String
    , state : State
    , pendingCollisions : List CollisionDirection
    , dwcamera : Camera
    , playerpos : ( Float, Float )
    , tiles : List ( Int, Int, Tile )
    , keyPos : Maybe ( ( Float, Float ), ( Float, Float ), ( Float, Float ) )
    , currentKeyPos : ( Float, Float )
    , keyAnimation : Bool
    }


first : ( a, b, c ) -> a
first ( a, _, _ ) =
    a


second : ( a, b, c ) -> b
second ( _, b, _ ) =
    b


third : ( a, b, c ) -> c
third ( _, _, c ) =
    c


decideAlpha : Data -> ( Float, Float, Float )
decideAlpha data =
    let
        keyNum =
            data.state.keyNum

        judge =
            data.keyAnimation
    in
    if keyNum == 0 then
        ( 0.5, 0.5, 0.5 )

    else if keyNum == 1 then
        if judge then
            ( 0.5, 0.5, 0.5 )

        else
            ( 1, 0.5, 0.5 )

    else if keyNum == 2 then
        if judge then
            ( 1, 0.5, 0.5 )

        else
            ( 1, 1, 0.5 )

    else if judge then
        ( 1, 1, 0.5 )

    else
        ( 1, 1, 1 )


{-| Funciton to render current key number.
-}
keyNumRender : Env SceneCommonData UserData -> Data -> List Renderable
keyNumRender env data =
    let
        alphas =
            decideAlpha data

        alpha1 =
            first alphas

        alpha2 =
            second alphas

        alpha3 =
            third alphas
    in
    [ P.centeredTextureWithAlpha (screentocanvas env.globalData.camera ( 80, 200 ))
        ( 80, 80 )
        0
        alpha1
        ("Key" ++ "0")
    ]
        ++ [ P.centeredTextureWithAlpha (screentocanvas env.globalData.camera ( 160, 200 ))
                ( 80, 80 )
                0
                alpha2
                ("Key" ++ "0")
           ]
        ++ [ P.centeredTextureWithAlpha (screentocanvas env.globalData.camera ( 240, 200 ))
                ( 80, 80 )
                0
                alpha3
                ("Key" ++ "0")
           ]


getTargetPos : Env SceneCommonData UserData -> Float -> ( Float, Float )
getTargetPos env keyNum =
    if keyNum == 1 then
        screentocanvas env.globalData.camera ( 80, 200 )

    else if keyNum == 2 then
        screentocanvas env.globalData.camera ( 160, 200 )

    else if keyNum == 3 then
        screentocanvas env.globalData.camera ( 240, 200 )

    else
        ( 0, 0 )


judgeEnd : ( Float, Float ) -> ( Float, Float ) -> Bool
judgeEnd keyPos targetPos =
    let
        ( x0, y0 ) =
            keyPos

        ( x1, y1 ) =
            targetPos

        judge =
            abs (x1 - x0)
                <= 5
                && abs (y1 - y0)
                <= 5
    in
    judge


decideAngle : ( Float, Float ) -> ( Float, Float ) -> Float
decideAngle pos1 pos2 =
    let
        slope =
            (Tuple.second pos2 - Tuple.second pos1) / (Tuple.first pos1 - Tuple.first pos2)

        angle =
            atan slope
    in
    angle


{-| Function to update position of the key animation.
-}
updateKeyPos : Env SceneCommonData UserData -> Float -> Data -> ( ( Float, Float ), Bool )
updateKeyPos env dt data =
    let
        ( x0, y0 ) =
            data.currentKeyPos

        target =
            getTargetPos env data.state.keyNum

        angle =
            decideAngle ( x0, y0 ) target

        ( x1, y1 ) =
            target

        stiffness =
            1000.0

        vx =
            max (stiffness * abs (x1 - x0) / 1000) 200

        vy =
            max (stiffness * abs (y1 - y0) / 1000) 200

        newX =
            x0 - vx * dt * cos angle / 1000

        newY =
            y0 + vy * dt * sin angle / 1000

        judge =
            judgeEnd ( newX, newY ) target
    in
    if judge then
        ( ( 0, 0 ), False )

    else
        ( ( newX, newY ), True )


{-| Function to rneder keyAnimation.
-}
keyAnimation : Data -> List Renderable
keyAnimation data =
    let
        keyPos =
            data.currentKeyPos
    in
    [ P.centeredTextureWithAlpha keyPos
        ( 80, 80 )
        0
        1
        ("Key" ++ "0")
    ]
