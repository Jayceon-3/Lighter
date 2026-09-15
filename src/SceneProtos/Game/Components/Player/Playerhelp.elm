module SceneProtos.Game.Components.Player.Playerhelp exposing (help_update_1, help_update_2, help_update_3, help_update_4, help_help_update_4, swingJudge, playerTileJudgeOne, playerTileJudge, fireUpdate)

{-|


# Playerhelp

Functions to assist with player-related operations.

@docs help_update_1, help_update_2, help_update_3, help_update_4, help_help_update_4, swingJudge, playerTileJudgeOne, playerTileJudge, fireUpdate

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.Common exposing (Camera)
import SceneProtos.Game.Components.Bullet.Init exposing (SingleBullet)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection, Tile)
import SceneProtos.Game.Components.Player.Bosscorrect exposing (..)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.Components.Player.Doublejump exposing (..)
import SceneProtos.Game.Components.Player.Helper exposing (Data, help_stat, help_y_camera, msg2)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.Components.Player.LevelCamera exposing (updatecamera)
import SceneProtos.Game.Components.Player.Playerlogic exposing (a, g, resolveCollisions)
import SceneProtos.Game.Components.Player.Recoil exposing (recoil, upperLimit)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, MechanicalArmState(..), Shield, ShieldState(..), SwingMode(..))
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Helper function to update the player state and camera position based on the player's state and position.
-}
help_update_1 : Env SceneCommonData UserData -> Data -> BaseData -> State -> Camera -> GlobalData UserData -> State -> ( Float, Float, Float ) -> UserData -> ( ( Float, Float ), ( Float, Float ) ) -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
help_update_1 env data basedata statFixed oldcamera gdata stat ( dt, x1, y1 ) olduserdata ( ( x, y ), ( w, h ) ) =
    let
        tempdata =
            { data
                | state = statFixed
                , pendingCollisions = []
                , playercamera =
                    { oldcamera
                        | x = max 965 (min x1 3835)
                        , y = help_y_camera stat data dt y1
                    }
            }

        newdata =
            poscorrect tempdata env
    in
    ( ( newdata
      , basedata
      )
    , [ Other ( "Weapon", PlayerStateMsg statFixed )
      , Other ( "Enemy", PlayerStateMsg statFixed )
      , Other ( "Survcamera", PlayerStateMsg statFixed )
      , Other ( "Ceo", PlayerStateMsg statFixed )
      , Other ( "Boss", PlayerStateMsg statFixed )
      , Other ( "Map", CheckCollisionMsg { x = x, y = y, x1 = x1, y1 = y1, w = w, h = h } )
      , Other ( "Particle", PlayerStateMsg statFixed )
      , Other ( "Drop", PlayerStateMsg statFixed )
      , Parent <| SOMMsg SOMSaveGlobalData
      ]
    , ( { env | globalData = { gdata | camera = updatecamera env data, userData = { olduserdata | canvas_mouse_pos = screentocanvas env.globalData.camera env.globalData.mousePos } } }, False )
    )


{-| Helper function to update the player state and camera position based on the player's state and position.
-}
help_update_2 : Bool -> Data -> ( Camera, UserData ) -> GlobalData UserData -> MechanicalArm -> ( ( Float, Float ), ( Float, Float ) ) -> ( Float, ( SwingMode, Float ), ( Float, Float ) ) -> Env SceneCommonData UserData -> BaseData -> State -> ( ( Float, Float ), ( Float, Float ) ) -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
help_update_2 judge data ( oldcamera, olduserdata ) gdata currentArm ( newPos, newSpeed ) ( newLength, mode, anchor ) env basedata newState ( ( x, y ), ( w, h ) ) =
    let
        ( vx, vy ) =
            newSpeed

        tempdata =
            { data | state = newState }

        newdata =
            poscorrect tempdata env

        otherdata =
            poscorrect data env
    in
    if judge then
        ( ( { newdata | mechanicalArm = { currentArm | length = newLength, swingMode = mode, anchor = anchor, position = newPos, speed = newSpeed }, playercamera = { oldcamera | x = max 965 (min (Tuple.first newPos) 3835), y = min 1855 (max 550 (Tuple.second newPos)) } }, basedata ), msg2 newState x y newPos w h, ( { env | globalData = { gdata | camera = updatecamera env data, userData = { olduserdata | canvas_mouse_pos = screentocanvas env.globalData.camera env.globalData.mousePos } } }, False ) )

    else if newLength == 1500 then
        ( ( { otherdata | mechanicalArm = { currentArm | state = Shortening, swingMode = mode }, playercamera = { oldcamera | x = max 965 (min 3835 (Tuple.first newPos)), y = min 1855 (max 550 (Tuple.second newPos)) } }, basedata ), msg2 newState x y newPos w h, ( { env | globalData = { gdata | camera = updatecamera env data, userData = { olduserdata | canvas_mouse_pos = screentocanvas env.globalData.camera env.globalData.mousePos } } }, False ) )

    else
        let
            alpha =
                data.mechanicalArm.length / 1000 + 0.3

            ( vx2, vy2 ) =
                if vx == 0 && currentArm.angle > 0 then
                    ( 800, -1000 * alpha )

                else if vx == 0 && currentArm.angle < 0 then
                    ( -800, -1000 * alpha )

                else
                    ( vx * alpha * 2, -1000 * alpha )

            heretempdata =
                { data | mechanicalArm = { currentArm | state = Swing, speed = ( vx2, vy2 ), anchor = anchor, swingMode = mode }, state = { newState | vx = vx2, vy = vy2, position = ( x, y - 1 ) } }

            herenewdata =
                poscorrect heretempdata env
        in
        ( ( herenewdata, basedata ), msg2 newState x y newPos w h, ( env, False ) )


{-| Helper function to update the player state and camera position based on the player's state and position.
-}
help_update_3 : Bool -> Env SceneCommonData UserData -> Data -> ( Camera, UserData ) -> GlobalData UserData -> MechanicalArm -> Float -> State -> ( Float, Float ) -> BaseData -> ( Float, Float ) -> ( ( Float, Float ), ( Float, Float ) ) -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
help_update_3 judge env data ( oldcamera, olduserdata ) gdata currentArm newLength newState newSpeed basedata newPos ( ( x, y ), ( w, h ) ) =
    if judge then
        let
            tempdata =
                { data | mechanicalArm = { currentArm | length = newLength, position = newPos, speed = newSpeed }, state = newState, playercamera = { oldcamera | x = max 965 (min 3835 (Tuple.first newPos)), y = min 1855 (max 550 (Tuple.second newPos)) } }

            newdata =
                poscorrect tempdata env
        in
        ( ( newdata, basedata ), msg2 newState x y newPos w h, ( { env | globalData = { gdata | camera = updatecamera env data, userData = { olduserdata | canvas_mouse_pos = screentocanvas env.globalData.camera env.globalData.mousePos } } }, False ) )

    else
        ( ( { data | mechanicalArm = { currentArm | length = newLength, state = Closed }, playercamera = { oldcamera | x = max 965 (min 3835 (Tuple.first newPos)), y = min 1855 (max 550 (Tuple.second newPos)) } }, basedata ), msg2 newState x y newPos w h, ( { env | globalData = { gdata | camera = updatecamera env data, userData = { olduserdata | canvas_mouse_pos = screentocanvas env.globalData.camera env.globalData.mousePos } } }, False ) )


{-| Helper function to update the player state and camera position based on the player's state and position.
-}
help_update_4 : Bool -> Env SceneCommonData UserData -> Data -> BaseData -> MechanicalArm -> ( Camera, UserData ) -> GlobalData UserData -> ( Float, Float ) -> ( ( Float, Float ), ( Float, Float ) ) -> State -> ( Float, ( Float, Float ), Bool ) -> ( ( Float, Float ), ( Float, Float ) ) -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
help_update_4 judge env data basedata currentArm ( oldcamera, olduserdata ) gdata ( newLength, newAngle ) ( newPos, newSpeed ) newState ( initSpringTime, initSpringPos, judgeSpring ) ( ( x, y ), ( w, h ) ) =
    if judge then
        if judgeSpring then
            help_help_update_4 judge env data basedata currentArm ( oldcamera, olduserdata ) gdata ( newLength, newAngle ) ( newPos, newSpeed ) newState ( initSpringTime, initSpringPos, judgeSpring ) ( ( x, y ), ( w, h ) )

        else
            let
                tempdata =
                    { data | mechanicalArm = { currentArm | length = newLength, angle = newAngle, position = newPos, speed = newSpeed }, state = newState, playercamera = { oldcamera | x = max 965 (min 3835 (Tuple.first newPos)), y = min 1855 (max 550 (Tuple.second newPos)) } }

                newdata =
                    poscorrect tempdata env
            in
            ( ( newdata, basedata ), [ Other ( "Weapon", PlayerStateMsg newState ), Other ( "Enemy", PlayerStateMsg newState ), Other ( "Survcamera", PlayerStateMsg newState ), Other ( "Ceo", PlayerStateMsg newState ), Other ( "Boss", PlayerStateMsg newState ), Other ( "Map", CheckCollisionMsg { x = x, y = y, x1 = Tuple.first newPos, y1 = Tuple.second newPos, w = w, h = h } ), Other ( "Particle", PlayerStateMsg newState ), Other ( "Drop", PlayerStateMsg newState ), Parent <| SOMMsg <| SOMSaveGlobalData ], ( { env | globalData = { gdata | camera = updatecamera env data, userData = { olduserdata | canvas_mouse_pos = screentocanvas env.globalData.camera env.globalData.mousePos } } }, False ) )

    else
        ( ( { data | mechanicalArm = { currentArm | state = Shortening }, playercamera = { oldcamera | x = max 965 (min 3835 (Tuple.first newPos)), y = min 1855 (max 550 (Tuple.second newPos)) } }, basedata ), [ Other ( "Weapon", PlayerStateMsg newState ), Other ( "Enemy", PlayerStateMsg newState ), Other ( "Survcamera", PlayerStateMsg newState ), Other ( "Ceo", PlayerStateMsg newState ), Other ( "Boss", PlayerStateMsg newState ), Other ( "Map", CheckCollisionMsg { x = x, y = y, x1 = Tuple.first newPos, y1 = Tuple.second newPos, w = w, h = h } ), Other ( "Particle", PlayerStateMsg newState ), Other ( "Drop", PlayerStateMsg newState ), Parent <| SOMMsg <| SOMSaveGlobalData ], ( { env | globalData = { gdata | camera = updatecamera env data } }, False ) )


{-| Helper function to update the player state and camera position based on the player's state and position.
-}
help_help_update_4 : Bool -> Env SceneCommonData UserData -> Data -> BaseData -> MechanicalArm -> ( Camera, UserData ) -> GlobalData UserData -> ( Float, Float ) -> ( ( Float, Float ), ( Float, Float ) ) -> State -> ( Float, ( Float, Float ), Bool ) -> ( ( Float, Float ), ( Float, Float ) ) -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
help_help_update_4 _ env data basedata currentArm ( oldcamera, olduserdata ) gdata ( newLength, newAngle ) ( newPos, newSpeed ) newState ( initSpringTime, initSpringPos, judgeSpring ) ( ( x, y ), ( w, h ) ) =
    let
        tempdata =
            { data | mechanicalArm = { currentArm | length = newLength, angle = newAngle, position = newPos, speed = newSpeed, initSpringTime = initSpringTime, initSpringPos = initSpringPos }, state = newState, playercamera = { oldcamera | x = max 965 (min 3835 (Tuple.first newPos)), y = min 1855 (max 550 (Tuple.second newPos)) } }

        newdata =
            poscorrect tempdata env
    in
    ( ( newdata, basedata ), [ Other ( "Weapon", PlayerStateMsg newState ), Other ( "Enemy", PlayerStateMsg newState ), Other ( "Survcamera", PlayerStateMsg newState ), Other ( "Ceo", PlayerStateMsg newState ), Other ( "Boss", PlayerStateMsg newState ), Other ( "Map", CheckCollisionMsg { x = x, y = y, x1 = Tuple.first newPos, y1 = Tuple.second newPos, w = w, h = h } ), Other ( "Particle", PlayerStateMsg newState ), Other ( "Drop", PlayerStateMsg newState ), Parent <| SOMMsg <| SOMSaveGlobalData ], ( { env | globalData = { gdata | camera = updatecamera env data, userData = { olduserdata | canvas_mouse_pos = screentocanvas env.globalData.camera env.globalData.mousePos } } }, False ) )


{-| Judge the swing mode based on the new length and whether the player is swinging.
-}
swingJudge : ( SwingMode, Float ) -> Float -> Bool -> Bool
swingJudge swingMode newLength judge =
    let
        newJudge =
            if Tuple.first swingMode /= Dash then
                judge

            else if newLength <= 80 then
                False

            else
                True
    in
    newJudge


{-| Judge if the player is colliding with a tile based on the player's position and the tile's properties.
-}
playerTileJudgeOne : ( Float, Float ) -> ( Int, Int, Tile ) -> Bool
playerTileJudgeOne position tile =
    let
        ( x1, y1 ) =
            position

        ( x2, y2, t ) =
            tile

        judge =
            t.solid
                && abs (x1 - toFloat x2)
                <= 44
                && abs (y1 - toFloat y2)
                <= 59
    in
    judge


{-| Judge if the player is colliding with any tile based on the player's position and a list of tiles.
-}
playerTileJudge : ( Float, Float ) -> List ( Int, Int, Tile ) -> Bool
playerTileJudge position tiles =
    let
        judge =
            List.map (\t -> playerTileJudgeOne position t) tiles
                |> List.any identity
    in
    judge


{-| update the player's position according to recoil and bullet type.
-}
fireUpdate : State -> SingleBullet -> ( Float, Float )
fireUpdate state bullet =
    let
        ( vx0, vy0 ) =
            ( state.vx, state.vy )

        ( dvx, dvy ) =
            recoil bullet.bulletType state.weaponDir bullet

        dvy1 =
            dvy / abs (1 + vy0)

        dvx1 =
            if state.direction * state.weaponDir > 0 then
                -dvx

            else
                dvx

        ( vx, vy ) =
            ( vx0 + dvx1, vy0 + dvy1 )

        ( vx1, vy1 ) =
            ( upperLimit bullet.bulletType vx, upperLimit bullet.bulletType vy )
    in
    ( vx1, vy1 )
