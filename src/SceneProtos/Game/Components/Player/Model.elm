module SceneProtos.Game.Components.Player.Model exposing (component, Data)

{-| Component model

@docs component, Data

-}

import Color exposing (..)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.Coordinate.Camera exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Camera, group)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.DW.BlockLogic exposing (UpdateKind(..), specialBlockEffect)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..))
import SceneProtos.Game.Components.Map.Init exposing (..)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.Components.Player.Doublejump exposing (..)
import SceneProtos.Game.Components.Player.GetUnstuck exposing (getUnstuck)
import SceneProtos.Game.Components.Player.Handleevent exposing (..)
import SceneProtos.Game.Components.Player.Helper exposing (msg3)
import SceneProtos.Game.Components.Player.HpbarRender exposing (hpBarRender)
import SceneProtos.Game.Components.Player.Init exposing (Spritetype(..), State)
import SceneProtos.Game.Components.Player.Playerhelp exposing (..)
import SceneProtos.Game.Components.Player.Playerlogic exposing (..)
import SceneProtos.Game.Components.Player.Playerview exposing (..)
import SceneProtos.Game.Components.Player.Receive exposing (help_updaterec)
import SceneProtos.Game.Components.Player.Viewhelper exposing (shieldRender)
import SceneProtos.Game.Components.Weapon.DashShorteningHelp exposing (shortening)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, MechanicalArmState(..), Shield, ShieldState(..), SwingMode(..))
import SceneProtos.Game.Components.Weapon.MechanicalArm exposing (distance, judgeArmTile, stretching, swing, swingArmChange)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data model for the player component.
`id`: Unique identifier for the player component.
`ty`: Type of the component, typically "Player".
`state`: The current state of the player, including position, velocity, direction, health, and jump status.
`isSwing`: Indicates if the player is currently swinging the mechanical arm.
`mechanicalArm`: The mechanical arm used by the player, including its position, speed, angle, state, length, anchor, and swing mode.
`pendingCollisions`: List of pending collision directions to be resolved.
`playercamera`: The camera for the player
`tiles`: List of tiles in the player's current map.
`currentShield`: The current shield state of the player
Example:
{ id = 1
, ty = "Player"
, state = { position = ( 100, 700 ), vx = 0, vy = 0, direction = 1, hp = 100, alive = True, a\_pressed = False, d\_pressed = False, s\_pressed = False, canjump = 1, weaponDir = 1, keyNum = 0 }
, isSwing = False
, mechanicalArm = { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) }
, pendingCollisions = []
, playercamera = { x = 100, y = 500, zoom = 1, rotation = 0 }
, tiles = []
, currentShield = { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 }
}
-}
type alias Data =
    { id : Int
    , ty : String
    , state : State
    , isSwing : Bool
    , mechanicalArm : MechanicalArm
    , pendingCollisions : List CollisionDirection
    , playercamera : Camera
    , tiles : List ( Int, Int, Tile )
    , currentShield : Shield
    , keyAnimation : Bool
    , rightbound : Float
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        PlayerInitMsg data ->
            let
                cam =
                    { x = data.state.position |> Tuple.first
                    , y = (data.state.position |> Tuple.second) - 200
                    , zoom = 1
                    , rotation = 0
                    }
            in
            ( { state = data.state, id = data.id, ty = data.ty, isSwing = data.isSwing, mechanicalArm = data.mechanicalArm, pendingCollisions = [], playercamera = cam, tiles = data.tiles, currentShield = data.currentShield, keyAnimation = False, rightbound = data.rightbound }, initBaseData )

        _ ->
            ( { state = { position = ( 100, 700 ), vx = 0, vy = 0, direction = 1, hp = 100, alive = True, a_pressed = False, d_pressed = False, s_pressed = False, canjump = 1, weaponDir = 1, keyNum = 0 }, id = 1, ty = "Player", isSwing = False, mechanicalArm = { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) }, pendingCollisions = [], playercamera = env.globalData.camera, tiles = [], currentShield = { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 }, keyAnimation = False, rightbound = 0 }, initBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    if basedata.isPaused then
        ( ( data, basedata ), [], ( env, False ) )

    else if data.state.hp <= 0 then
        ( ( data, basedata ), [ Other ( "Interface", PlayerDeadMsg ) ], ( env, False ) )

    else
        let
            ( sta, olduserdata ) =
                ( data.state, env.globalData.userData )

            ( w, h ) =
                ( 30, 60 )

            ( ( ( vx, vy ), dir, ( x, y ) ), ( gdata, oldcamera, currentArm ) ) =
                ( ( ( sta.vx, sta.vy ), sta.direction, sta.position ), ( env.globalData, data.playercamera, data.mechanicalArm ) )
        in
        if not env.globalData.userData.dw then
            if data.isSwing then
                case evnt of
                    KeyDown 82 ->
                        getUnstuck env data basedata

                    Tick dt ->
                        case currentArm.state of
                            Stretching ->
                                let
                                    ( ( newPos, newSpeed, ( armEdge, armTilePos ) ), ( newLength, mode, judge ), anchor ) =
                                        stretching dt ( ( x, y ), ( vx, vy ) ) data.tiles currentArm.angle currentArm.position currentArm.length

                                    newState =
                                        { sta | position = newPos, vx = Tuple.first newSpeed, vy = Tuple.second newSpeed }
                                in
                                help_update_2 judge data ( oldcamera, olduserdata ) gdata currentArm ( newPos, newSpeed ) ( newLength, mode, anchor ) env basedata newState ( ( x, y ), ( w, h ) )

                            Swing ->
                                let
                                    ( ( newPos, newSpeed ), ( initSpringTime, initSpringPos, judgeSpring ), judge ) =
                                        swing env currentArm.swingMode currentArm.initSpringTime currentArm.initSpringPos currentArm.angle dt ( ( x, y ), ( data.state.vx, data.state.vy ) )

                                    ( ( newLength, newAngle ), newState ) =
                                        ( swingArmChange currentArm.anchor newPos, { sta | position = newPos, vx = Tuple.first newSpeed, vy = Tuple.second newSpeed } )

                                    newJudge =
                                        swingJudge data.mechanicalArm.swingMode newLength judge
                                in
                                help_update_4 newJudge env data basedata currentArm ( oldcamera, olduserdata ) gdata ( newLength, newAngle ) ( newPos, newSpeed ) newState ( initSpringTime, initSpringPos, judgeSpring ) ( ( x, y ), ( w, h ) )

                            Shortening ->
                                let
                                    ( ( newPos, newSpeed ), newLength, judge ) =
                                        shortening dt ( ( x, y ), ( data.state.vx, data.state.vy ) ) data.mechanicalArm.length

                                    newState =
                                        { sta | position = newPos, vx = Tuple.first newSpeed, vy = Tuple.second newSpeed }
                                in
                                help_update_3 judge env data ( oldcamera, olduserdata ) gdata currentArm newLength newState newSpeed basedata newPos ( ( x, y ), ( w, h ) )

                            Closed ->
                                ( ( { data | isSwing = False, state = { sta | vx = 0 } }, basedata ), msg3 data currentArm, ( env, False ) )

                    _ ->
                        ( ( data, basedata ), [], ( env, False ) )

            else
                handleEvent evnt env data basedata

        else
            case evnt of
                KeyDown 81 ->
                    if data.keyAnimation then
                        ( ( data, basedata ), [], ( env, False ) )

                    else
                        ( ( data, basedata ), [ Other ( "DW", InitPlayerStateMsg data.state ) ], ( env, False ) )

                Tick dt ->
                    let
                        ( x1, y1 ) =
                            ( x + vx * dt / 1000 * dir, y + vy * dt / 1000 )
                    in
                    ( ( data, basedata )
                    , [ Other ( "DW", PlayerStateMsg data.state )
                      , Other ( "Map", CheckCollisionMsg { x = x, y = y, x1 = x1, y1 = y1, w = w, h = h } )
                      , Other ( "Enemy", PlayerStateMsg data.state )
                      ]
                    , ( env, False )
                    )

                _ ->
                    ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    help_updaterec env msg data basedata


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        mechanicalArmAngle =
            if data.mechanicalArm.angle >= 0 then
                data.mechanicalArm.angle

            else
                data.mechanicalArm.angle + pi

        hpNum =
            round data.state.hp

        render =
            [ P.rectCentered ( Tuple.first data.state.position + (data.mechanicalArm.length / 2) * cos mechanicalArmAngle, Tuple.second data.state.position - (data.mechanicalArm.length / 2) * sin mechanicalArmAngle ) ( data.mechanicalArm.length, 10 ) mechanicalArmAngle (Color.rgba 0.2 0.2 0.2 1)
            , P.centeredTexture ( Tuple.first data.state.position + data.mechanicalArm.length * cos mechanicalArmAngle, Tuple.second data.state.position - data.mechanicalArm.length * sin mechanicalArmAngle ) ( 40, 40 ) (mechanicalArmAngle + pi / 4) "marm"

            -- , P.textbox (screentocanvas env.globalData.camera ( 100, 955 )) 25 (String.fromInt hpNum ++ "/100") "consolas" Color.yellow
            -- , P.textbox (screentocanvas env.globalData.camera ( 50, 200 )) 40 ("Key Number:" ++ String.fromFloat data.state.keyNum) "consolas" Color.white
            -- , P.textbox env.globalData.userData.canvas_mouse_pos 40 (String.fromFloat (Tuple.first env.globalData.userData.canvas_mouse_pos) ++ " " ++ String.fromFloat (Tuple.second env.globalData.userData.canvas_mouse_pos)) "consolas" Color.white
            -- , P.textbox (screentocanvas env.globalData.camera ( 50, 200 )) 40 ("Key Number:" ++ String.fromFloat data.state.keyNum) "consolas" Color.white
            -- , P.rect (screentocanvas env.globalData.camera ( 50, 950 )) ( data.state.hp / 100 * 120, 40 ) Color.red
            -- , P.textbox (screentocanvas env.globalData.camera ( 60, 955 )) 40 (String.fromInt (round data.state.hp) ++ "/100") "consolas" Color.white
            -- , P.textbox env.globalData.userData.canvas_mouse_pos 40 (String.fromFloat (Tuple.first env.globalData.userData.canvas_mouse_pos) ++ " " ++ String.fromFloat (Tuple.second env.globalData.userData.canvas_mouse_pos)) "consolas" Color.white
            ]
                ++ shieldRender env data
                ++ hpBarRender env data
    in
    if shieldRender env data /= [ P.empty ] && data.currentShield.shieldState /= Ground then
        ( group [] render, 8 )

    else if data.state.vy /= 0 then
        jump_run_stay Jump env data.ty data.state render

    else if data.state.vx == 0 then
        jump_run_stay Stay env data.ty data.state render

    else
        jump_run_stay Run env data.ty data.state render


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


{-| The player component, which includes the player's state, mechanical arm, camera, and other properties.
-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
