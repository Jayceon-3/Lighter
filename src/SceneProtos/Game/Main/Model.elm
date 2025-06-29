module SceneProtos.Game.Main.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Component.Component exposing (AbstractComponent, updateComponents, viewComponents)
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (ConcreteLayer, Handler, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer, handleComponentMsgs)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg, ComponentTarget)
import SceneProtos.Game.SceneBase exposing (..)


type alias Data =
    { components : List (AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
    }


init : LayerInit SceneCommonData UserData (LayerMsg SceneMsg) Data
init env initMsg =
    Data []


handleComponentMsg : Handler Data SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg ComponentMsg
handleComponentMsg env compmsg data =
    case compmsg of
        SOMMsg som ->
            ( data, [ Parent <| SOMMsg som ], env )

        _ ->
            ( data, [], env )


update : LayerUpdate SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg Data
update env evt data =
    let
        ( comps1, msgs1, ( env1, block1 ) ) =
            updateComponents env evt data.components

        ( data1, msgs2, env2 ) =
            handleComponentMsgs env1 msgs1 { data | components = comps1 } [] handleComponentMsg
    in
    ( data1, msgs2, ( env2, block1 ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    viewComponents env data.components


matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "Main"


layercon : ConcreteLayer Data SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Layer generator
-}
layer : LayerStorage SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg
layer =
    genLayer layercon
