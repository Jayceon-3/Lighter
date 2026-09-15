module SceneProtos.Game.Components.Player.Handleevent exposing (handleEvent)

{-|


# handleEvent

Functions for handling events for players

@docs handleEvent

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Player.Bosscorrect exposing (..)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.Components.Player.Doublejump exposing (..)
import SceneProtos.Game.Components.Player.Helper exposing (Data, help_stat)
import SceneProtos.Game.Components.Player.Playerhelp exposing (help_update_1)
import SceneProtos.Game.Components.Player.Playerlogic exposing (a, g, resolveCollisions)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArmState(..), ShieldState(..), SwingMode(..))
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Helper function to handle player events.
-}
handleEvent : UserEvent -> Env SceneCommonData UserData -> Data -> BaseData -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
handleEvent evnt env data basedata =
    let
        ( sta, olduserdata ) =
            ( data.state, env.globalData.userData )

        ( w, h ) =
            ( 30, 60 )

        ( ( ( vx, vy ), dir, ( x, y ) ), ( gdata, oldcamera, currentArm ) ) =
            ( ( ( sta.vx, sta.vy ), sta.direction, sta.position ), ( env.globalData, data.playercamera, data.mechanicalArm ) )
    in
    case evnt of
        Tick dt ->
            let
                ( ( x1, y1 ), ( vx1, vx2, vy1 ) ) =
                    ( ( x + vx * dt / 1000 * dir, y + vy * dt / 1000 ), ( max 0 (vx - a * dt / 1000), min 600 (vx + a * dt / 1000), vy + g * dt / 1000 ) )

                stat =
                    help_stat sta x1 y1 vx1 vy1 vx2

                statFixed =
                    resolveCollisions stat data.pendingCollisions
            in
            help_update_1 env data basedata statFixed oldcamera gdata stat ( dt, x1, y1 ) olduserdata ( ( x, y ), ( w, h ) )

        KeyDown 65 ->
            ( ( { data | state = { sta | a_pressed = True, direction = -1, vx = min sta.vx 100 } }, basedata ), [], ( env, False ) )

        KeyUp 65 ->
            ( ( { data | state = { sta | a_pressed = False } }, basedata ), [], ( env, False ) )

        KeyDown 68 ->
            ( ( { data | state = { sta | d_pressed = True, direction = 1, vx = min sta.vx 100 } }, basedata ), [], ( env, False ) )

        KeyUp 68 ->
            ( ( { data | state = { sta | d_pressed = False } }, basedata ), [], ( env, False ) )

        KeyDown 87 ->
            if can_jump sta then
                ( ( { data | state = { sta | canjump = sta.canjump - 1, vy = -550, position = ( Tuple.first sta.position, Tuple.second sta.position - 2 ) } }, basedata ), double_jump_msg sta, ( env, False ) )

            else
                ( ( data, basedata ), [], ( env, False ) )

        KeyDown 83 ->
            ( ( { data | state = { sta | s_pressed = True } }, basedata ), [], ( env, False ) )

        KeyUp 83 ->
            ( ( { data | state = { sta | s_pressed = False } }, basedata ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )
