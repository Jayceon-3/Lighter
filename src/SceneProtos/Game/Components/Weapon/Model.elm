module SceneProtos.Game.Components.Weapon.Model exposing (component)

{-| Component model

@docs component

-}

import Color exposing (Color)
import Duration
import Json.Decode exposing (bool)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Audio.Base exposing (AudioCommonOption, AudioOption(..), AudioTarget(..))
import Messenger.Base exposing (..)
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import REGL.Effects exposing (alphamult)
import SceneProtos.Game.Components.Bullet.Init exposing (BulletType(..), SingleBullet)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..))
import SceneProtos.Game.Components.Map.Init as MapInit exposing (Tile)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.Components.Player.Playerlogic exposing (..)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, MechanicalArmState(..), Scatter, Shield, ShieldState(..), State, SwingMode(..))
import SceneProtos.Game.Components.Weapon.Receive exposing (handle_dropmsg, scatterBullet)
import SceneProtos.Game.Components.Weapon.RenderHelper exposing (renderAll)
import SceneProtos.Game.Components.Weapon.WeaponHelp exposing (handle_mouse_left, tickUpdate)
import SceneProtos.Game.Components.Weapon.WeaponUpdate exposing (decideAngle, decideWeaponDirection, initBulletAndLaser)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data model for the weapon component.
`id`: Unique identifier for the weapon component.
`ty`: Type of the component, typically "Weapon".
`state`: Current state of the weapon.
`shield`: Shield of the weapon system.
`mechanical arm`: Mechanical arm of the weapon system.
`initPressedTime`: The start time of left click.
`deltaPosition`: The position change between two ticks.
`isLineOn`: To check whether the predict line is on or not.
`isMousePressed`: Check if the left mouse is pressed now.
`tiles`: The tile information.
`scatter`: The scatter bullet information.

Example:
{ id = 5
, ty = "Weapon"
, state = { position = ( 150, 700 ), direction = 1, angle = 0, weaponType = 1, energy = 100 }
, shield = { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 }
, mechnicalArm = { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) }
, initPressedTime = 0
, deltaPosition = 0
, isLineOn = False
, isMousePressed = False
, tiles = []
, scatter = { startTime = 0, ability = False }
}

-}
type alias Data =
    { id : Int
    , ty : String
    , state : State
    , shield : Shield
    , mechanicalArm : MechanicalArm
    , initPressedTime : Float
    , deltaPosition : Float
    , isLineOn : Bool
    , isMousePressed : Bool
    , tiles : List ( Int, Int, Tile )
    , scatter : Scatter
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        WeaponInitMsg data ->
            ( { state = data.state, id = data.id, ty = data.ty, shield = data.shield, mechanicalArm = data.mechanicalArm, initPressedTime = data.initPressedTime, deltaPosition = data.deltaPosition, isLineOn = data.isLineOn, isMousePressed = data.isMousePressed, tiles = data.tiles, scatter = Scatter 0 False }, initBaseData )

        _ ->
            ( { state = { position = ( 150, 700 ), direction = 1, angle = 0, weaponType = 1, energy = 100 }, id = 2, ty = "Weapon", shield = { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 }, mechanicalArm = { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) }, initPressedTime = 0, deltaPosition = 0, isLineOn = False, isMousePressed = False, tiles = [], scatter = Scatter 0 False }, initBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    if basedata.isPaused then
        ( ( data, basedata ), [], ( env, False ) )

    else
        let
            ( x, y ) =
                env.globalData.userData.canvas_mouse_pos

            angle =
                decideAngle env.globalData.userData.canvas_mouse_pos data.state.position

            ( state, currentShield ) =
                ( data.state, data.shield )

            currentDeltaPosition =
                Tuple.first env.globalData.userData.canvas_mouse_pos - Tuple.first data.state.position

            diff =
                data.deltaPosition - currentDeltaPosition

            direction =
                decideWeaponDirection diff data.state.direction currentDeltaPosition
        in
        if not env.globalData.userData.dw then
            case evnt of
                Tick dt ->
                    let
                        newEnergy =
                            min (data.state.energy + 1 / 15) 100

                        shieldTime =
                            min ((env.globalData.currentTimeStamp - data.shield.initTime) / 1000) 5

                        newState =
                            { state | direction = direction, angle = angle, energy = newEnergy }

                        deltaT =
                            (env.globalData.currentTimeStamp - data.initPressedTime) / 1000
                    in
                    tickUpdate env data basedata newState currentShield deltaT currentDeltaPosition direction angle shieldTime dt

                KeyDown 69 ->
                    let
                        newState =
                            if data.shield.shieldState == Unused then
                                Hand

                            else
                                Unused
                    in
                    if data.mechanicalArm.state == Closed then
                        if newState == Hand then
                            ( ( { data | shield = { currentShield | shieldState = newState, initHandTime = env.globalData.currentTimeStamp } }, basedata ), [], ( env, False ) )

                        else
                            ( ( { data | shield = { currentShield | shieldState = newState, initHandTime = env.globalData.currentTimeStamp } }, basedata ), [], ( env, False ) )

                    else
                        ( ( data, basedata ), [], ( env, False ) )

                MouseDown 0 ( _, _ ) ->
                    ( ( { data | initPressedTime = env.globalData.currentTimeStamp, isMousePressed = True }, basedata ), [], ( env, False ) )

                MouseUp 0 ( _, _ ) ->
                    handle_mouse_left state env data basedata

                MouseDown 2 ( x0, y0 ) ->
                    let
                        newEnergy =
                            max (state.energy - 50) 0

                        armAngle =
                            decideAngle env.globalData.userData.canvas_mouse_pos data.state.position
                    in
                    if data.shield.shieldState == Hand then
                        ( ( { data | shield = { currentShield | shieldState = Ground, initTime = env.globalData.currentTimeStamp }, state = { state | energy = newEnergy } }, basedata ), [], ( env, False ) )

                    else if (data.mechanicalArm.state == Closed || data.mechanicalArm.state == Shortening) && Tuple.second data.state.position - Tuple.second env.globalData.userData.canvas_mouse_pos > 0 then
                        if not data.isLineOn then
                            ( ( { data | isLineOn = True }, basedata ), [], ( env, False ) )

                        else
                            ( ( data, basedata ), [], ( env, False ) )

                    else
                        ( ( data, basedata ), [], ( env, False ) )

                MouseUp 2 ( x0, y0 ) ->
                    let
                        newEnergy =
                            max (state.energy - 20) 0

                        currentArm =
                            data.mechanicalArm

                        ( weaponpos, mousePos ) =
                            ( data.state.position, env.globalData.userData.canvas_mouse_pos )

                        armAngle =
                            decideAngle mousePos weaponpos
                    in
                    if
                        data.mechanicalArm.state
                            == Closed
                            && Tuple.second weaponpos
                            - Tuple.second mousePos
                            > 0
                            && data.shield.shieldState
                            /= Ground
                            && newEnergy
                            /= 0
                    then
                        ( ( { data | isLineOn = False, mechanicalArm = { currentArm | position = data.state.position, angle = armAngle, state = Stretching }, state = { state | energy = newEnergy } }, basedata )
                        , [ Other ( "Player", MechanicalArmMsg { currentArm | position = data.state.position, angle = armAngle, state = Stretching } ) ]
                        , ( env, False )
                        )

                    else
                        ( ( data, basedata ), [], ( env, False ) )

                _ ->
                    ( ( data, basedata ), [], ( env, False ) )

        else
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    let
        currentState =
            data.state
    in
    case msg of
        PlayerStateMsg sta ->
            ( ( { data | state = { position = ( Tuple.first sta.position + currentState.direction * 50, Tuple.second sta.position - 10 ), direction = data.state.direction, angle = currentState.angle, weaponType = currentState.weaponType, energy = currentState.energy } }, basedata ), [], env )

        MechanicalArmMsg arm ->
            ( ( { data | mechanicalArm = arm }, basedata ), [], env )

        ChangePause ->
            if basedata.isPaused then
                ( ( data, { basedata | isPaused = False } ), [], env )

            else
                ( ( data, { basedata | isPaused = True } ), [], env )

        MapInfo newTile ->
            ( ( { data | tiles = newTile }, basedata ), [], env )

        DropMsg droptype ->
            handle_dropmsg currentState droptype data basedata env

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        deltaT =
            (env.globalData.currentTimeStamp - data.initPressedTime) / 1000
    in
    renderAll env data data.state.direction deltaT data.tiles


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Weapon"


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
