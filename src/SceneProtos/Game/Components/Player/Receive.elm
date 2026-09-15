module SceneProtos.Game.Components.Player.Receive exposing (Data, help_updaterec)

{-|


# Receive

Functions for handling player state updates and interactions.

@docs Data, help_updaterec

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.Common exposing (Camera)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.DW.BlockLogic exposing (UpdateKind(..), specialBlockEffect)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..))
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection, Tile)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.Components.Player.Doublejump exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.Components.Player.Playerhelp exposing (..)
import SceneProtos.Game.Components.Player.Playerlogic exposing (a, cbullet, g, resolveCollisions, validenemy)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, MechanicalArmState(..), Shield, ShieldState(..), SwingMode(..))
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The player component data structure. Copied from the Model to avoid import loop.
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


{-| Handles the collision result message by updating the player's state based on the tile type.
-}
handle_collisionresultmsg : Env SceneCommonData UserData -> Data -> BaseData -> State -> Maybe Tile -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), Env SceneCommonData UserData )
handle_collisionresultmsg env data basedata oldstate tile =
    let
        ( value, updateKind ) =
            specialBlockEffect tile data.state.keyNum data.state.hp
    in
    if updateKind == HP then
        ( ( { data | state = { oldstate | hp = value } }, basedata ), [], env )

    else
        ( ( data, basedata ), [], env )


{-| Handles the drop message by updating the player's state based on the dropped item type.
-}
handle_dropmsg : State -> Droptype -> Data -> BaseData -> Env SceneCommonData UserData -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), Env SceneCommonData UserData )
handle_dropmsg oldstate droptype data basedata env =
    let
        newstate =
            case droptype of
                Life ->
                    { oldstate | hp = min 100 (oldstate.hp + 30) }

                _ ->
                    oldstate
    in
    ( ( { data | state = newstate }, basedata ), [], env )


{-| Updates the player state based on the received message.
-}
help_updaterec : Env SceneCommonData UserData -> ComponentMsg -> Data -> BaseData -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), Env SceneCommonData UserData )
help_updaterec env msg data basedata =
    let
        oldstate =
            data.state
    in
    case msg of
        Hurt decrease ->
            ( ( { data | state = { oldstate | hp = oldstate.hp - decrease } }, basedata ), [], env )

        NewPlayerPos newpos ->
            ( ( { data | state = { oldstate | position = newpos } }, basedata ), [], env )

        Rightbound bound ->
            ( ( { data | rightbound = bound }, basedata ), [], env )

        CollisionResultDirMsg dir ->
            let
                fixedState =
                    if env.globalData.userData.dw then
                        data.state

                    else
                        resolveCollisions data.state dir
            in
            ( ( { data | state = fixedState, pendingCollisions = [] }, basedata ), [], env )

        CollisionResultMsg tile ->
            handle_collisionresultmsg env data basedata oldstate tile

        WeaponDir direction ->
            ( ( { data | state = { oldstate | weaponDir = direction } }, basedata ), [], env )

        ShieldState state ->
            if state == Hand then
                ( ( { data | state = { oldstate | vx = oldstate.vx / 8 * 7, vy = oldstate.vy / 8 * 7 } }, basedata ), [], env )

            else
                ( ( data, basedata ), [], env )

        EnemyStateMsg enemy ->
            ( ( { data | state = validenemy enemy data.state }, basedata ), [], env )

        MechanicalArmMsg arm ->
            ( ( { data | isSwing = True, mechanicalArm = arm }, basedata ), [], env )

        MapInfo newtile ->
            let
                currentArm =
                    data.mechanicalArm

                newJudge =
                    playerTileJudge data.state.position newtile
            in
            if newJudge then
                ( ( { data | tiles = newtile, mechanicalArm = { currentArm | state = Shortening } }, basedata ), [], env )

            else
                ( ( { data | tiles = newtile }, basedata ), [], env )

        ChangePause ->
            if basedata.isPaused then
                ( ( data, { basedata | isPaused = False } ), [], env )

            else
                ( ( data, { basedata | isPaused = True } ), [], env )

        ShieldMsg shield ->
            ( ( { data | currentShield = shield }, basedata ), [], env )

        FireMsg bullet ->
            let
                ( vx1, vy1 ) =
                    fireUpdate data.state bullet
            in
            ( ( { data | state = { oldstate | vx = vx1, vy = vy1 } }, basedata ), [], env )

        SurCameraBullets bullets ->
            let
                ( newstate, newbullets ) =
                    cbullet oldstate bullets
            in
            ( ( { data | state = newstate }, basedata ), [ Other ( "Survcamera", NewCameraBullet newbullets ) ], env )

        DropMsg Life ->
            handle_dropmsg oldstate Life data basedata env

        KeyAnimationMsg judge ->
            ( ( { data | keyAnimation = judge }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )
