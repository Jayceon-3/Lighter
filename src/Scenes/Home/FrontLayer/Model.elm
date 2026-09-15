module Scenes.Home.FrontLayer.Model exposing (layer, inButton, adjustSize)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer, inButton, adjustSize

-}

import Color exposing (..)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, UserEvent(..))
import Messenger.GeneralModel exposing (..)
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.Common exposing (group)
import Scenes.Home.FrontLayer.Buttonupdate exposing (updateButtondata)
import Scenes.Home.FrontLayer.DataHelp exposing (Buttonstate(..), Data, ScreenState(..))
import Scenes.Home.FrontLayer.RenderHelp exposing (buttonHeight, buttonWidth, gameButtonX, gameButtonY, homePage, logoPage, setButtonX, setButtonY)
import Scenes.Home.FrontLayer.Viewbutton exposing (Axis(..), viewButtonFrame)
import Scenes.Home.SceneBase exposing (..)


{-| Judge whether the mouse is in a specific button
-}
inButton : Float -> Float -> Float -> Float -> Float -> Float -> Bool
inButton px py cx cy w h =
    (px >= cx - w / 2)
        && (px <= cx + w / 2)
        && (py >= cy - h / 2)
        && (py <= cy + h / 2)


inSetButton : Float -> Float -> Bool
inSetButton x y =
    inButton x y setButtonX setButtonY buttonWidth buttonHeight


inGameButton : Float -> Float -> Bool
inGameButton x y =
    inButton x y gameButtonX gameButtonY buttonWidth buttonHeight


inDemoButton : Float -> Float -> Bool
inDemoButton x y =
    inButton x y 1800 1000 200 100


{-| Adjust size to the targeted size
-}
adjustSize : Float -> Float -> Float
adjustSize targetSize size =
    let
        speed =
            0.1

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


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { screenState =
        if env.globalData.userData.displayLogo then
            HomeScreen

        else
            LogoScreen
    , startTime = env.globalData.currentTimeStamp
    , num_of_char = 0
    , char_lasttime = env.globalData.currentTimeStamp + 1500
    , size_set = 1.0
    , size_game = 1.0
    , current_time = env.globalData.currentTimeStamp
    , help =
        { position = ( setButtonX, setButtonY )
        , size = ( buttonWidth, buttonHeight )
        , state = Off
        , inittime = 0
        }
    , game =
        { position = ( gameButtonX - 5, gameButtonY )
        , size = ( buttonWidth + 8, buttonHeight )
        , state = Off
        , inittime = 0
        }
    }


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    case data.screenState of
        LogoScreen ->
            let
                elapsed =
                    (env.globalData.currentTimeStamp - data.startTime) / 1000
            in
            case evt of
                Tick _ ->
                    if elapsed > 8 then
                        let
                            gdata =
                                env.globalData

                            oldUD =
                                gdata.userData

                            newUD =
                                { oldUD | displayLogo = True }

                            newGdata =
                                { gdata | userData = newUD }

                            newEnv =
                                { env | globalData = newGdata }
                        in
                        ( { data | screenState = HomeScreen }, [ Parent (SOMMsg SOMSaveGlobalData) ], ( newEnv, False ) )

                    else
                        ( update_logo_data env data, [], ( env, False ) )

                KeyDown 46 ->
                    let
                        gdata =
                            env.globalData

                        oldUD =
                            gdata.userData

                        newUD =
                            { oldUD | displayLogo = True }

                        newGdata =
                            { gdata | userData = newUD }

                        newEnv =
                            { env | globalData = newGdata }
                    in
                    ( { data | screenState = HomeScreen }, [ Parent (SOMMsg SOMSaveGlobalData) ], ( newEnv, False ) )

                _ ->
                    ( update_logo_data env data, [], ( env, False ) )

        HomeScreen ->
            case evt of
                MouseDown 0 ( x, y ) ->
                    if inSetButton x y then
                        ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Settings")) ], ( env, False ) )

                    else if inDemoButton x y then
                        ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Demo")) ], ( env, False ) )

                    else if inGameButton x y then
                        ( data
                        , [ Parent (SOMMsg SOMSaveGlobalData)
                          , Parent (SOMMsg (SOMChangeScene Nothing "Transition1"))
                          ]
                        , ( env, False )
                        )

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
                    ( { updatedData | help = updateButtondata data.help env ( x, y ), game = updateButtondata data.game env ( x, y ) }, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    case data.screenState of
        LogoScreen ->
            logoPage env data

        HomeScreen ->
            group []
                [ homePage env data
                , viewButtonFrame env data.help
                , viewButtonFrame env data.game
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


update_logo_data : Env SceneCommonData UserData -> Data -> Data
update_logo_data env data =
    if env.globalData.currentTimeStamp - data.char_lasttime > 40 then
        { data
            | char_lasttime = env.globalData.currentTimeStamp
            , num_of_char = data.num_of_char + 1
        }

    else
        data
