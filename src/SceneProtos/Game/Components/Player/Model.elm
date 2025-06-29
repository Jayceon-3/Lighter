module SceneProtos.Game.Components.Player.Model exposing (component)

{-| Component model

@docs component

-}

import Color exposing (Color)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)
import Speed exposing (Speed)


type alias Data =
    { id : Int
    , ty : String
    , state : State
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        PlayerInitMsg data ->
            ( { state = data.state, id = data.id, ty = data.ty }, () )

        _ ->
            ( { state = { position = ( 100, 100 ), speed = 10, direction = 1, hp = 100, alive = True }, id = 1, ty = "Player" }, () )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( group [] [ P.rectCentered data.state.position ( 10, 20 ) 0 Color.black ], 0 )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Player"


componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Component generator
-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
