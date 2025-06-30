module SceneProtos.Game.Components.Player.Model exposing (component)

{-| Component model

@docs component

-}

import Color exposing (Color)
import Json.Decode exposing (bool)
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
            ( { state = { position = ( 100, 700 ), vx = 0, vy = 0, direction = 1, hp = 100, alive = True, a_pressed = False, d_pressed = False, canjump = 1, weaponDir = 1 }, id = 1, ty = "Player" }, () )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    let
        -- _ =
        --     Debug.log "direction: " data.state.direction
        dat =
            jumprestore data

        sta =
            dat.state

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
                    y + vy * dt / 1000

                g =
                    1500

                a =
                    1500

                vx1 =
                    max 0 (vx - a * dt / 1000)

                vx2 =
                    min 600 (vx + a * dt / 1000)

                vy1 =
                    vy + g * dt / 1000

                stat =
                    { sta | position = ( x1, y1 ), vx = vx1, vy = vy1 }

                stat2 =
                    { sta | position = ( x1, y1 ), vx = vx2, vy = vy1 }
            in
            if stat.a_pressed || stat.d_pressed then
                -- move env { data | state = stat } basedata
                ( ( { dat | state = stat2 }, basedata ), [ Other ( "Weapon", PlayerStateMsg stat2 ) ], ( env, False ) )

            else
                ( ( { dat | state = stat }, basedata ), [ Other ( "Weapon", PlayerStateMsg stat ) ], ( env, False ) )

        KeyDown 65 ->
            -- move_left_or_right env data basedata -1
            ( ( { dat | state = { sta | a_pressed = True, direction = -1, vx = min sta.vx 100 } }, basedata ), [], ( env, False ) )

        KeyUp 65 ->
            ( ( { dat | state = { sta | a_pressed = False } }, basedata ), [], ( env, False ) )

        KeyDown 68 ->
            -- move_left_or_right env data basedata 1
            ( ( { dat | state = { sta | d_pressed = True, direction = 1, vx = min sta.vx 100 } }, basedata ), [], ( env, False ) )

        KeyUp 68 ->
            ( ( { dat | state = { sta | d_pressed = False } }, basedata ), [], ( env, False ) )

        KeyDown 87 ->
            if can_jump dat then
                ( ( { dat | state = { sta | canjump = sta.canjump - 1, vy = -500, position = ( Tuple.first sta.position, Tuple.second sta.position - 2 ) } }, basedata ), [], ( env, False ) )

            else
                ( ( dat, basedata ), [], ( env, False ) )

        _ ->
            ( ( dat, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    let
        sta =
            data.state
    in
    case msg of
        WeaponDir direction ->
            ( ( { data | state = { sta | weaponDir = direction } }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    if data.state.weaponDir == 1 then
        ( group [] [ P.rectCentered data.state.position ( 30, 60 ) 0 Color.blue, P.rectCentered ( Tuple.first data.state.position - 10, Tuple.second data.state.position - 30 ) ( 20, 20 ) 0 Color.yellow, P.rect ( 0, 730 ) ( 1920, 5 ) Color.black ], 0 )

    else
        ( group [] [ P.rectCentered data.state.position ( 30, 60 ) 0 Color.blue, P.rectCentered ( Tuple.first data.state.position + 10, Tuple.second data.state.position - 30 ) ( 20, 20 ) 0 Color.yellow, P.rect ( 0, 730 ) ( 1920, 5 ) Color.black ], 0 )


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


if_on_ground : Data -> Bool
if_on_ground data =
    if Tuple.second data.state.position < 699 then
        False

    else
        True


jumprestore : Data -> Data
jumprestore data =
    let
        sta =
            data.state
    in
    if if_on_ground data then
        { data | state = { sta | canjump = 2, vy = 0, position = ( Tuple.first sta.position, 700 ) } }

    else
        data


can_jump : Data -> Bool
can_jump data =
    if data.state.canjump == 2 && if_on_ground data then
        True

    else if data.state.canjump == 1 && not (if_on_ground data) then
        True

    else
        False
