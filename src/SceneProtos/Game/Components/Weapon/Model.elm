module SceneProtos.Game.Components.Weapon.Model exposing (component)

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
import SceneProtos.Game.Components.Bullet.Init exposing (SingleBullet)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import SceneProtos.Game.Components.Weapon.Init exposing (State)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


type alias Data =
    { id : Int
    , ty : String
    , state : State
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        WeaponInitMsg data ->
            ( { state = data.state, id = data.id, ty = data.ty }, () )

        _ ->
            ( { state = { position = ( 150, 700 ), direction = 1, angle = 0, weaponType = 1, energy = 100 }, id = 2, ty = "Weapon" }, () )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    let
        ( x, y ) =
            env.globalData.mousePos

        angle =
            decideAngle env.globalData.mousePos data.state.position data.state.direction

        state =
            data.state

        direction =
            if Tuple.first env.globalData.mousePos - Tuple.first data.state.position >= 0 then
                1

            else
                -1
    in
    case evnt of
        Tick dt ->
            ( ( { data | state = { position = state.position, direction = direction, angle = angle, weaponType = state.weaponType, energy = state.energy } }, basedata ), [ Other ( "Player", WeaponDir data.state.direction ) ], ( env, False ) )

        MouseDown 0 ( x0, y0 ) ->
            let
                deltaX =
                    x0 - Tuple.first data.state.position

                x1 =
                    Tuple.first data.state.position + 30 * cos data.state.angle * data.state.direction

                y1 =
                    Tuple.second data.state.position - 30 * sin data.state.angle * data.state.direction

                bullet =
                    { position = ( x1, y1 ), direction = data.state.direction, angle = data.state.angle, bulletType = 1, attack = 5 }
            in
            ( ( data, basedata ), [ Other ( "Bullet", FireMsg bullet ) ], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        PlayerStateMsg sta ->
            let
                currentState =
                    data.state
            in
            ( ( { data | state = { position = ( Tuple.first sta.position + currentState.direction * 50, Tuple.second sta.position ), direction = data.state.direction, angle = currentState.angle, weaponType = currentState.weaponType, energy = currentState.energy } }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( group [] [ P.rectCentered data.state.position ( 50, 20 ) data.state.angle Color.red ], 0 )


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


decideAngle : ( Float, Float ) -> ( Float, Float ) -> Float -> Float
decideAngle mousePos weaponpos direction =
    let
        slope =
            (Tuple.second weaponpos - Tuple.second mousePos) / (Tuple.first mousePos - Tuple.first weaponpos)

        angle =
            atan slope
    in
    angle
