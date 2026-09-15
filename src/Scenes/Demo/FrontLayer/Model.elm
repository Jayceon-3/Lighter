module Scenes.Demo.FrontLayer.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, UserEvent(..))
import Messenger.GeneralModel exposing (..)
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import Scenes.Demo.FrontLayer.Helper exposing (..)
import Scenes.Demo.SceneBase exposing (..)
import Scenes.Home.FrontLayer.Buttonupdate exposing (updateButtondata)
import Scenes.Home.FrontLayer.DataHelp exposing (ButtonData, Buttonstate(..))
import Scenes.Home.FrontLayer.Model exposing (adjustSize, inButton)
import Scenes.Home.FrontLayer.RenderHelp exposing (viewButton)
import Scenes.Home.FrontLayer.Viewbutton exposing (Axis(..), viewButtonFrame)


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { size1 = 1.0
    , size2 = 1.0
    , size3 = 1.0
    , size4 = 1.0
    , current_time = env.globalData.currentTimeStamp
    , level1 = { position = ( level12X, level13Y ), size = ( buttonWidth - 5, buttonHeight ), state = Off, inittime = 0 }
    , level2 = { position = ( level12X, level24Y ), size = ( buttonWidth - 5, buttonHeight ), state = Off, inittime = 0 }
    , level3 = { position = ( level34X, level13Y ), size = ( buttonWidth - 5, buttonHeight ), state = Off, inittime = 0 }
    , level4 = { position = ( level34X, level24Y ), size = ( buttonWidth - 5, buttonHeight ), state = Off, inittime = 0 }
    }


in1button : Float -> Float -> Bool
in1button x y =
    inButton x y level12X level13Y buttonWidth buttonHeight


in2button : Float -> Float -> Bool
in2button x y =
    inButton x y level12X level24Y buttonWidth buttonHeight


in3button : Float -> Float -> Bool
in3button x y =
    inButton x y level34X level13Y buttonWidth buttonHeight


in4button : Float -> Float -> Bool
in4button x y =
    inButton x y level34X level24Y buttonWidth buttonHeight


inHomeButton : Float -> Float -> Bool
inHomeButton x y =
    inButton x y 1800 1000 200 100


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    case evt of
        MouseDown 0 ( x, y ) ->
            if in1button x y then
                let
                    newEnv =
                        setCurrentLevel 1 env
                in
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Level1")), Parent <| SOMMsg <| SOMSaveGlobalData ], ( newEnv, False ) )

            else if in2button x y then
                let
                    newEnv =
                        setCurrentLevel 2 env
                in
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Level2")), Parent <| SOMMsg <| SOMSaveGlobalData ], ( newEnv, False ) )

            else if in3button x y then
                let
                    newEnv =
                        setCurrentLevel 3 env
                in
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Level3")), Parent <| SOMMsg <| SOMSaveGlobalData ], ( newEnv, False ) )

            else if in4button x y then
                let
                    newEnv =
                        setCurrentLevel 4 env
                in
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Level4")), Parent <| SOMMsg <| SOMSaveGlobalData ], ( newEnv, False ) )

            else if inHomeButton x y then
                let
                    newEnv =
                        setCurrentLevel 1 env
                in
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Home")), Parent <| SOMMsg <| SOMSaveGlobalData ], ( newEnv, False ) )

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

                newlevel1 =
                    updateButtondata data.level1 env ( x, y )

                newlevel2 =
                    updateButtondata data.level2 env ( x, y )

                newlevel3 =
                    updateButtondata data.level3 env ( x, y )

                newlevel4 =
                    updateButtondata data.level4 env ( x, y )

                updatedData =
                    if dt > 10 then
                        if in1button x y then
                            { data
                                | size1 = adjustSize 1.1 data.size1
                                , size2 = adjustSize 1.0 data.size2
                                , size3 = adjustSize 1.0 data.size3
                                , size4 = adjustSize 1.0 data.size4
                                , current_time = now
                            }

                        else if in2button x y then
                            { data
                                | size2 = adjustSize 1.1 data.size2
                                , size1 = adjustSize 1.0 data.size1
                                , size3 = adjustSize 1.0 data.size3
                                , size4 = adjustSize 1.0 data.size4
                                , current_time = now
                            }

                        else if in3button x y then
                            { data
                                | size3 = adjustSize 1.1 data.size3
                                , size1 = adjustSize 1.0 data.size1
                                , size2 = adjustSize 1.0 data.size2
                                , size4 = adjustSize 1.0 data.size4
                                , current_time = now
                            }

                        else if in4button x y then
                            { data
                                | size4 = adjustSize 1.1 data.size4
                                , size1 = adjustSize 1.0 data.size1
                                , size2 = adjustSize 1.0 data.size2
                                , size3 = adjustSize 1.0 data.size3
                                , current_time = now
                            }

                        else
                            { data
                                | size4 = adjustSize 1.0 data.size4
                                , size1 = adjustSize 1.0 data.size1
                                , size2 = adjustSize 1.0 data.size2
                                , size3 = adjustSize 1.0 data.size3
                                , current_time = now
                            }

                    else
                        data
            in
            ( { updatedData | level1 = newlevel1, level2 = newlevel2, level3 = newlevel3, level4 = newlevel4 }, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    let
        lv1 =
            viewButton level12X level13Y data.size1 "level1"

        lv2 =
            viewButton level12X level24Y data.size2 "level2"

        lv3 =
            viewButton level34X level13Y data.size3 "level3"

        lv4 =
            viewButton level34X level24Y data.size4 "level4"

        home =
            let
                mp =
                    env.globalData.mousePos
            in
            if abs (Tuple.first mp - 1800) <= 100 && abs (Tuple.second mp - 1000) <= 50 then
                P.textboxCentered ( 1800, 1000 ) 40 "Home" "consolas" Color.white

            else
                P.textboxCentered ( 1800, 1000 ) 40 "Home" "consolas" Color.lightPurple

        background =
            P.centeredTexture ( 960, 540 ) ( 1920, 1280 ) 0 "home"
    in
    group []
        [ background
        , lv1
        , lv2
        , lv3
        , lv4
        , home
        , viewButtonFrame env data.level1
        , viewButtonFrame env data.level2
        , viewButtonFrame env data.level3
        , viewButtonFrame env data.level4
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


setCurrentLevel : Int -> Env SceneCommonData UserData -> Env SceneCommonData UserData
setCurrentLevel lv env =
    let
        gdata =
            env.globalData

        ud =
            gdata.userData

        newLV =
            { ud | currentlevel = lv }

        newGData =
            { gdata | userData = newLV }

        newEnv =
            { env | globalData = newGData }
    in
    newEnv
