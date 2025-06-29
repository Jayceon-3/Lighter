module SceneProtos.Game.Components.Player.Model exposing (component)

{-| Component model

@docs component

-}

import Color exposing (Color)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import REGL.Effects exposing (alphamult)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


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
            ( { state = { position = ( 100, 500 ), vx = 0, vy = 0, direction = 1, hp = 100, alive = True, a_pressed = False, d_pressed = False }, id = 1, ty = "Player" }, () )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    let
        sta =
            data.state

        vx =
            sta.vx

        vy =
            sta.vy

        dir =
            sta.direction

        ( x, y ) =
            sta.position
    in
    case evnt of
        Tick dt ->
            let
                x1 =
                    x + vx * dt / 1000 * dir

                y1 =
                    y + vy * dt / 1000 * dir

                g =
                    200

                a =
                    1500

                vx1 =
                    max 0 (vx - a * dt / 1000)

                vx2 =
                    min 600 (vx + a * dt / 1000)

                vy1 =
                    max 0 (vy - g * dt / 1000)

                stat =
                    { sta | position = ( x1, y1 ), vx = vx1, vy = vy1 }

                stat2 =
                    { sta | position = ( x1, y1 ), vx = vx2, vy = vy1 }
            in
            if stat.a_pressed || stat.d_pressed then
                -- move env { data | state = stat } basedata
                ( ( { data | state = stat2 }, basedata ), [], ( env, False ) )

            else
                ( ( { data | state = stat }, basedata ), [], ( env, False ) )

        KeyDown 65 ->
            -- move_left_or_right env data basedata -1
            ( ( { data | state = { sta | a_pressed = True, direction = -1, vx = min sta.vx 100 } }, basedata ), [], ( env, False ) )

        KeyUp 65 ->
            ( ( { data | state = { sta | a_pressed = False } }, basedata ), [], ( env, False ) )

        KeyDown 68 ->
            -- move_left_or_right env data basedata 1
            ( ( { data | state = { sta | d_pressed = True, direction = 1, vx = min sta.vx 100 } }, basedata ), [], ( env, False ) )

        KeyUp 68 ->
            ( ( { data | state = { sta | d_pressed = False } }, basedata ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( group [] [ P.rectCentered data.state.position ( 30, 60 ) 0 Color.black ], 0 )


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
