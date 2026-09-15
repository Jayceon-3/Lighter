module Scenes.Transition5.Layer1.Model exposing (layer)

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
import Scenes.Transition1.Layer1.FunctionHelp exposing (crossButton, fadeOutAlpha, gen_text, inExit)
import Scenes.Transition1.Layer1.Grid exposing (Coderain, grid, update_codes, view_rain)
import Scenes.Transition5.Layer1.DataHelp exposing (Data, DialoguePhase(..), TransitionState(..))
import Scenes.Transition5.Layer1.FunctionHelp exposing (dialogueLine, enterButton, handleOptionSelect, inEnterButton, newDialogueLine, update_data, userOptions)
import Scenes.Transition5.SceneBase exposing (..)


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { para = 1
    , num_of_char = 0
    , char_lasttime = env.globalData.currentTimeStamp
    , isFinished = False
    , transition = EndTransition
    , userSelectedOption = Nothing
    , inOptionMode = False
    , enterBtnStartTime = Nothing
    , phase = NormalPhase
    , coderain = Coderain [] (Random.initialSeed 123) env.globalData.currentTimeStamp
    }


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    case data.transition of
        StartTransition startTime ->
            if fadeOutAlpha startTime env.globalData.currentTimeStamp >= 1 then
                ( { data | transition = EndTransition, para = 1, phase = AfterTransitionPhase, num_of_char = 0, char_lasttime = env.globalData.currentTimeStamp, isFinished = False }, [], ( env, False ) )

            else
                ( data, [], ( env, False ) )

        SecondTransition startTime ->
            if fadeOutAlpha startTime env.globalData.currentTimeStamp >= 1 then
                ( { data | transition = EndTransition }, [ Parent (SOMMsg (SOMChangeScene Nothing "Home")) ], ( env, False ) )

            else
                ( data, [], ( env, False ) )

        _ ->
            case evt of
                KeyDown 13 ->
                    if data.inOptionMode || data.para == 6 then
                        ( data, [], ( env, False ) )

                    else if data.phase == AfterTransitionPhase && data.para == 2 && data.isFinished then
                        ( { data | transition = SecondTransition env.globalData.currentTimeStamp }, [], ( env, False ) )

                    else if not data.isFinished then
                        let
                            line =
                                case data.phase of
                                    NormalPhase ->
                                        dialogueLine data

                                    AfterTransitionPhase ->
                                        newDialogueLine data

                            lineLen =
                                String.length line.text
                        in
                        if data.num_of_char < lineLen then
                            ( { data | num_of_char = lineLen, isFinished = True }, [], ( env, False ) )

                        else
                            let
                                options =
                                    userOptions (data.para + 1)
                            in
                            ( { data | para = data.para + 1, num_of_char = 0, char_lasttime = env.globalData.currentTimeStamp, isFinished = False, inOptionMode = not (List.isEmpty options), userSelectedOption = Nothing }, [], ( env, False ) )

                    else
                        let
                            options =
                                userOptions (data.para + 1)
                        in
                        ( { data | para = data.para + 1, num_of_char = 0, char_lasttime = env.globalData.currentTimeStamp, isFinished = False, inOptionMode = not (List.isEmpty options), userSelectedOption = Nothing }, [], ( env, False ) )

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

                    else if data.para == 6 && inEnterButton ( x, y ) then
                        ( { data | transition = StartTransition env.globalData.currentTimeStamp }, [], ( env, False ) )

                    else
                        ( data, [], ( env, False ) )

                Tick dt ->
                    let
                        now =
                            env.globalData.currentTimeStamp + 1000

                        data0 =
                            update_data env data

                        data1 =
                            { data0 | coderain = update_codes data0.coderain dt env.globalData.currentTimeStamp False }

                        data2 =
                            if data1.para == 6 && data1.isFinished && data1.enterBtnStartTime == Nothing then
                                { data1 | enterBtnStartTime = Just now }

                            else
                                data1
                    in
                    ( data2, [], ( env, False ) )

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
            if data.phase == NormalPhase then
                P.rectCentered ( 960, 540 ) ( 1920, 1080 ) 0 Color.black

            else
                P.rectCentered ( 960, 540 ) ( 1920, 1080 ) 0 Color.white
    in
    case data.transition of
        StartTransition startTime ->
            let
                alpha =
                    fadeOutAlpha startTime t
            in
            group []
                [ base, group [ alphamult alpha ] [ P.rectCentered ( 960, 540 ) ( 1920, 1080 ) 0 Color.white ] ]

        SecondTransition startTime ->
            let
                alpha =
                    fadeOutAlpha startTime t
            in
            group []
                [ base, group [ alphamult alpha ] [ P.rectCentered ( 960, 540 ) ( 1920, 1080 ) 0 Color.black ] ]

        _ ->
            let
                line =
                    case data.phase of
                        NormalPhase ->
                            dialogueLine data

                        AfterTransitionPhase ->
                            newDialogueLine data

                text =
                    gen_text data.num_of_char line.text

                ( position, color ) =
                    case line.speaker of
                        "boss" ->
                            ( ( 100, 200 ), Color.darkRed )

                        "nova" ->
                            ( ( 100, 200 ), Color.rgba (153 / 255) (214 / 255) (255 / 255) 1 )

                        "user" ->
                            ( ( 1200, 800 ), Color.white )

                        "default" ->
                            ( ( 450, 500 ), Color.black )

                        _ ->
                            ( ( 0, 0 ), Color.black )

                options =
                    userOptions data.para

                optionViews =
                    if data.inOptionMode then
                        List.indexedMap
                            (\i opt ->
                                P.textboxCentered ( 960, 800 + toFloat i * 60 ) 50 (String.fromInt (i + 1) ++ ". " ++ opt) "consolas" Color.white
                            )
                            options

                    else
                        []
            in
            group []
                ([ base, grid False, view_rain data.coderain, P.textbox position 50 text "consolas" color, crossButton ]
                    ++ optionViews
                    ++ [ if data.inOptionMode then
                            P.textboxCentered ( 960, 1000 ) 30 "Press number key to select." "consolas" Color.grey

                         else if data.para == 6 then
                            let
                                alpha =
                                    case data.enterBtnStartTime of
                                        Just startTime ->
                                            let
                                                elapsed =
                                                    t - startTime

                                                fadeIn =
                                                    clamp 0 1 (elapsed / 1500)
                                            in
                                            fadeIn

                                        Nothing ->
                                            0

                                mouse_Pos =
                                    env.globalData.mousePos

                                isLighted =
                                    inEnterButton mouse_Pos

                                newColor =
                                    if isLighted then
                                        Color.lightGreen

                                    else
                                        Color.darkGreen
                            in
                            group [ alphamult alpha ] [ enterButton newColor ]

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
