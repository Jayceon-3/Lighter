module Scenes.Home.FrontLayer.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color exposing (..)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GeneralModel exposing (..)
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import REGL.Effects exposing (alphamult)
import Scenes.Home.SceneBase exposing (..)


type alias Data =
    { size_set : Float
    , size_game : Float
    , current_time : Float
    }


setButtonX : Float
setButtonX =
    850


setButtonY : Float
setButtonY =
    500


buttonWidth : Float
buttonWidth =
    240


buttonHeight : Float
buttonHeight =
    80


gameButtonX : Float
gameButtonX =
    850


gameButtonY : Float
gameButtonY =
    650


inSetButton : Float -> Float -> Bool
inSetButton x y =
    (x >= setButtonX)
        && (x <= setButtonX + buttonWidth)
        && (y >= setButtonY)
        && (y <= setButtonY + buttonHeight)


inGameButton : Float -> Float -> Bool
inGameButton x y =
    (x >= gameButtonX)
        && (x <= gameButtonX + buttonWidth)
        && (y >= gameButtonY)
        && (y <= gameButtonY + buttonHeight)


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { size_set = 1.0
    , size_game = 1.0
    , current_time = env.globalData.currentTimeStamp
    }


adjustSize : Float -> Float -> Float
adjustSize targetSize size =
    let
        speed =
            0.01

        newSize =
            if size < targetSize then
                size + speed

            else if size > targetSize then
                size - speed

            else
                size
    in
    if newSize < 1.0 then
        1.0

    else if newSize > 1.1 then
        1.1

    else
        newSize


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    --( data, [], ( env, False ) )
    case evt of
        MouseDown 0 ( x, y ) ->
            if inSetButton x y then
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Settings")) ], ( env, False ) )

            else if inGameButton x y then
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Level1")) ], ( env, False ) )

            else
                ( data, [], ( env, False ) )

        _ ->
            let
                ( x, y ) =
                    env.globalData.mousePos

                now =
                    env.globalData.currentTimeStamp

                dt =
                    now - data.current_time

                updatedData =
                    if dt > 10 then
                        --10ms
                        if inSetButton x y then
                            { data
                                | size_set = adjustSize 1.1 data.size_set
                                , size_game = adjustSize 1.0 data.size_game
                                , current_time = now
                            }

                        else if inGameButton x y then
                            { data
                                | size_game = adjustSize 1.1 data.size_game
                                , size_set = adjustSize 1.0 data.size_set
                                , current_time = now
                            }

                        else
                            { data
                                | size_game = adjustSize 1.0 data.size_game
                                , size_set = adjustSize 1.0 data.size_set
                                , current_time = now
                            }

                    else
                        data
            in
            ( updatedData, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    let
        set =
            P.textbox ( setButtonX, setButtonY ) (buttonHeight * data.size_set) "Settings" "consolas" Color.black

        game =
            P.textbox ( gameButtonX, gameButtonY ) (buttonHeight * data.size_game) "Game" "consolas" Color.black

        background =
            P.rect ( 0, 0 ) ( 1920, 1080 ) Color.white

        --remain to be changed
    in
    group [ alphamult 1 ]
        [ background
        , set
        , game
        ]


matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "FrontLayer"


layercon : ConcreteLayer Data SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Layer generator
-}
layer : LayerStorage SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layer =
    genLayer layercon
