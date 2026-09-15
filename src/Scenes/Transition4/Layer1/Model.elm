module Scenes.Transition4.Layer1.Model exposing (layer)

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
import Scenes.Transition1.Layer1.Grid exposing (Coderain, grid, update_codes, view_rain)
import Scenes.Transition4.SceneBase exposing (..)


type alias Data =
    { startTime : Float
    , num_of_char : Int
    , char_lasttime : Float
    , coderain : Coderain
    }


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { startTime = env.globalData.currentTimeStamp
    , num_of_char = 0
    , char_lasttime = env.globalData.currentTimeStamp + 1500
    , coderain = Coderain [] (Random.initialSeed 123) env.globalData.currentTimeStamp
    }


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    let
        elapsed =
            (env.globalData.currentTimeStamp - data.startTime) / 1000
    in
    case evt of
        Tick dt ->
            let
                now =
                    env.globalData.currentTimeStamp

                rain =
                    data.coderain

                newRain =
                    update_codes rain dt now True

                data1 =
                    { data | coderain = newRain }

                gdata =
                    env.globalData

                userdata =
                    gdata.userData

                newuserdata =
                    { userdata | currentlevel = 4 }
            in
            if elapsed > 5 then
                ( data1
                , [ Parent (SOMMsg (SOMChangeScene Nothing "Level4"))
                  , Parent (SOMMsg SOMSaveGlobalData)
                  ]
                , ( { env | globalData = { gdata | userData = newuserdata } }, False )
                )

            else
                ( data1, [], ( env, False ) )

        _ ->
            ( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    let
        elapsed =
            (env.globalData.currentTimeStamp - data.startTime) / 1000

        fadeIn =
            1.0

        hold =
            3.0

        fadeOut =
            1.0

        total =
            hold + fadeOut + fadeIn

        alpha =
            if elapsed < fadeIn then
                elapsed / fadeIn

            else if elapsed < fadeIn + hold then
                1.0

            else if elapsed < total then
                1.0 - (elapsed - fadeIn - hold) / fadeOut

            else
                0.0

        background =
            P.rect ( 0, 0 ) ( 1920, 1080 ) Color.black

        content =
            P.textboxCentered ( 960, 540 ) 50 text "consolas" Color.darkRed
    in
    group []
        [ background
        , grid True
        , view_rain data.coderain
        , group [ alphamult alpha ] [ content ]
        ]


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


text : String
text =
    "The death of the body is not the true end."
