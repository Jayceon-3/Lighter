module Scenes.Settings.FrontLayer.Model exposing (layer)

{-|


# Model

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
import REGL.Common exposing (Renderable, group)
import Scenes.Settings.SceneBase exposing (..)


type alias Data =
    { changeVolume : Bool }


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    { changeVolume = False }


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    case evt of
        MouseDown 0 ( x, y ) ->
            if x >= 950 && x <= 1450 && y >= 894 && y <= 906 then
                ( { data | changeVolume = True }, [], ( env, False ) )

            else if inExit ( x, y ) then
                ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Home")) ], ( env, False ) )

            else
                ( data, [], ( env, False ) )

        MouseUp 0 _ ->
            if data.changeVolume then
                ( { data | changeVolume = False }, [], ( env, False ) )

            else
                ( data, [], ( env, False ) )

        _ ->
            if data.changeVolume then
                let
                    ( x, _ ) =
                        env.globalData.mousePos

                    volume =
                        clamp 0 1 ((x - 950) / 500)
                in
                ( data, [ Parent (SOMMsg (SOMSetVolume volume)) ], ( env, False ) )

            else
                ( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    let
        volumex =
            950 + 500 * env.globalData.volume

        volumetext =
            P.textbox ( 830, 887 ) 35 "Volume:" "consolas" Color.white

        volumenbar1 =
            P.rect ( 950, 900 ) ( 500, 12 ) Color.grey

        volumenbar2 =
            P.rect ( 950, 900 ) ( volumex - 950, 12 ) (Color.rgb 0.0 0.941 0.988)
    in
    group []
        [ P.centeredTexture ( 960, 540 ) ( 1920, 1280 ) 0 "home"
        , P.rectCentered ( 1200, 540 ) ( 1100, 600 ) 0 (Color.rgba 0 0 0 0.7)
        , P.textboxCentered ( 1160, 540 ) 40 guidance "consolas" Color.white
        , volumetext
        , volumenbar1
        , volumenbar2
        , crossButton
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


guidance : String
guidance =
    """
    A/D: Move Left or Right

    W: Jump and Double Jump

    E: Hold a Shield

    Q: Activate Digital World
    
    Left Mouse Button: Shoot; Long press: Activate Laser Gun
    
    Right Mouse Button: Use Hook or Place a Shield

    Esc: Pause
    """


crossButton : Renderable
crossButton =
    group []
        [ P.rectCentered ( 1725, 265 ) ( 50, 50 ) 0 Color.white
        , P.rectCentered ( 1725, 265 ) ( 40, 40 ) 0 Color.black
        , P.rectCentered ( 1725, 265 ) ( 50, 5 ) 0.785 Color.white
        , P.rectCentered ( 1725, 265 ) ( 50, 5 ) 2.356 Color.white
        ]


inExit : ( Float, Float ) -> Bool
inExit ( x, y ) =
    let
        centerX =
            1725

        centerY =
            265

        halfW =
            25

        halfH =
            25
    in
    x
        >= centerX
        - halfW
        && x
        <= centerX
        + halfW
        && y
        >= centerY
        - halfH
        && y
        <= centerY
        + halfH
