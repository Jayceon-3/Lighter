module Scenes.Transition2.Layer1.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import REGL.Effects exposing (alphamult)
import Random
import Scenes.Transition1.Layer1.DataHelp exposing (Data, TransitionState(..))
import Scenes.Transition1.Layer1.FunctionHelp exposing (crossButton, fadeOutAlpha, gen_text, inExit)
import Scenes.Transition1.Layer1.Grid exposing (Coderain, grid, update_codes, view_rain)
import Scenes.Transition2.Layer1.FunctionHelp exposing (dialogueLine, handleOptionSelect, update_data, userOptions)
import Scenes.Transition2.SceneBase exposing (..)


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { para = 1
    , num_of_char = 0
    , char_lasttime = env.globalData.currentTimeStamp
    , isFinished = False
    , transition = EndTransition
    , userSelectedOption = Nothing
    , inOptionMode = False
    , coderain = Coderain [] (Random.initialSeed 123) env.globalData.currentTimeStamp
    }


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    case evt of
        KeyDown 13 ->
            if data.inOptionMode then
                ( data, [], ( env, False ) )

            else
                let
                    line =
                        dialogueLine data

                    lineLen =
                        String.length line.text
                in
                if not data.isFinished then
                    ( { data | num_of_char = lineLen, isFinished = True }, [], ( env, False ) )

                else if data.para == 12 then
                    ( { data | transition = StartTransition env.globalData.currentTimeStamp }, [], ( env, False ) )

                else
                    let
                        options =
                            userOptions (data.para + 1)
                    in
                    ( { data
                        | para = data.para + 1
                        , num_of_char = 0
                        , char_lasttime = env.globalData.currentTimeStamp
                        , isFinished = False
                        , inOptionMode = not (List.isEmpty options)
                        , userSelectedOption = Nothing
                      }
                    , []
                    , ( env, False )
                    )

        KeyDown keyCode ->
            if data.inOptionMode then
                case keyCode of
                    49 ->
                        handleOptionSelect 0 env data

                    50 ->
                        handleOptionSelect 1 env data

                    _ ->
                        ( data, [], ( env, False ) )

            else
                ( data, [], ( env, False ) )

        MouseDown 0 ( x, y ) ->
            if inExit ( x, y ) then
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Home")) ], ( env, False ) )

            else
                ( data, [], ( env, False ) )

        Tick dt ->
            let
                now =
                    env.globalData.currentTimeStamp

                data0 =
                    update_data env data

                rain =
                    data0.coderain

                newRain =
                    update_codes rain dt now False

                data1 =
                    { data0 | coderain = newRain }

                gdata =
                    env.globalData

                userdata =
                    gdata.userData

                newuserdata =
                    { userdata | currentlevel = 2 }
            in
            case data1.transition of
                StartTransition start ->
                    if now - start > 500 then
                        ( { data1 | transition = EndTransition }
                        , [ Parent (SOMMsg (SOMChangeScene Nothing "Level2"))
                          , Parent (SOMMsg SOMSaveGlobalData)
                          ]
                        , ( { env | globalData = { gdata | userData = newuserdata } }, False )
                        )

                    else
                        ( data1, [], ( env, False ) )

                _ ->
                    ( data1, [], ( env, False ) )

        _ ->
            ( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    let
        t =
            env.globalData.currentTimeStamp

        base =
            P.rectCentered ( 960, 540 ) ( 1920, 1080 ) 0 Color.black
    in
    case data.transition of
        StartTransition startTime ->
            let
                alpha =
                    fadeOutAlpha startTime t
            in
            group []
                [ base
                , group [ alphamult alpha ]
                    [ P.rectCentered ( 960, 540 ) ( 1920, 1080 ) 0 Color.darkBlue ]
                ]

        _ ->
            let
                line =
                    dialogueLine data

                text =
                    gen_text data.num_of_char line.text

                ( position, color ) =
                    case line.speaker of
                        "nova" ->
                            ( ( 100, 200 ), Color.rgba (153 / 255) (214 / 255) (255 / 255) 1 )

                        "user" ->
                            ( ( 1200, 800 ), Color.white )

                        _ ->
                            ( ( 0, 0 ), Color.black )

                options =
                    userOptions data.para

                optionViews =
                    if data.inOptionMode then
                        List.indexedMap
                            (\i opt ->
                                P.textboxCentered ( 960, 800 + toFloat i * 60 ) 60 (String.fromInt (i + 1) ++ ". " ++ opt) "consolas" Color.white
                            )
                            options

                    else
                        []
            in
            group []
                ([ base
                 , grid False
                 , P.textbox position 60 text "consolas" color
                 , view_rain data.coderain
                 , crossButton
                 ]
                    ++ optionViews
                    ++ [ if data.inOptionMode then
                            P.textboxCentered ( 960, 1000 ) 30 "Press number key to select." "consolas" Color.grey

                         else
                            P.textboxCentered ( 960, 1000 ) 30 "Press 'Enter' to continue." "consolas" Color.grey
                       ]
                )


matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "Layer1"


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
