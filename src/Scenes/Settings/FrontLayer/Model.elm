module Scenes.Settings.FrontLayer.Model exposing (layer)

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
import Scenes.Settings.SceneBase exposing (..)


type alias Data =
    {}


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    {}


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    --( data, [], ( env, False ) )
    case evt of
        KeyDown 27 ->
            ( data, [ Parent (SOMMsg (SOMChangeScene Nothing "Home")) ], ( env, False ) )

        _ ->
            ( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    P.textbox ( 300, 400 ) 50 guidance "consolas" Color.black


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

    Esc: Back to Home
    """
