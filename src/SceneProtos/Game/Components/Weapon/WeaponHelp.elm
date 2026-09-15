module SceneProtos.Game.Components.Weapon.WeaponHelp exposing (handle_mouse_left, tickUpdate)

{-|


# WeaponHelp

This module contains helper functions for weapon update.

@docs handle_mouse_left, tickUpdate

-}

import Duration
import Lib.UserData exposing (UserData)
import Messenger.Audio.Base exposing (AudioCommonOption, AudioOption(..), AudioTarget(..))
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.Common exposing (Camera)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Map.Init as MapInit exposing (Tile)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, Scatter, Shield, ShieldState(..), State)
import SceneProtos.Game.Components.Weapon.Receive exposing (scatterBullet)
import SceneProtos.Game.Components.Weapon.WeaponUpdate exposing (initBulletAndLaser)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


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


{-| Tick update function for weapon.
-}
tickUpdate : Env SceneCommonData UserData -> Data -> BaseData -> State -> Shield -> Float -> Float -> Float -> Float -> Float -> Float -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
tickUpdate env data basedata newState currentShield deltaT currentDeltaPosition direction angle shieldTime _ =
    let
        oldscatter =
            data.scatter

        newscatter =
            if oldscatter.ability && (env.globalData.currentTimeStamp - oldscatter.starttime > 5000) then
                { oldscatter | ability = False }

            else
                oldscatter
    in
    if deltaT >= 0.5 && data.isMousePressed then
        ( ( { data | isLineOn = True, state = newState, deltaPosition = currentDeltaPosition, scatter = newscatter }, basedata )
        , [ Other ( "Player", WeaponDir newState.direction )
          , Other ( "Player", ShieldState currentShield.shieldState )
          , Other ( "Bullet", WeaponStateMsg newState )
          , Other ( "Enemy", ShieldMsg currentShield )
          , Other ( "Player", ShieldMsg currentShield )
          , Other ( "Particle", WeaponStateMsg newState )

          -- , Parent <| SOMMsg <| SOMTransformAudio (AudioName 0 "laser") (scaleVolume 0.5)
          ]
        , ( env, False )
        )

    else if data.shield.shieldState /= Ground then
        ( ( { data | state = newState, shield = { position = newState.position, direction = direction, angle = angle, shieldState = currentShield.shieldState, initTime = 0, initHandTime = data.shield.initHandTime }, deltaPosition = currentDeltaPosition, scatter = newscatter }, basedata )
        , [ Other ( "Player", WeaponDir newState.direction )
          , Other ( "Bullet", WeaponStateMsg newState )
          , Other ( "Enemy", ShieldMsg currentShield )
          , Other ( "Player", ShieldMsg currentShield )
          , Other ( "Player", ShieldState currentShield.shieldState )
          , Other ( "Particle", WeaponStateMsg newState )
          ]
        , ( env, False )
        )

    else if (shieldTime == 5) && (currentShield.initTime /= 0) then
        ( ( { data | state = newState, shield = { currentShield | shieldState = Unused, initTime = 0 }, deltaPosition = currentDeltaPosition, scatter = newscatter }, basedata )
        , [ Other ( "Player", WeaponDir newState.direction )
          , Other ( "Bullet", WeaponStateMsg newState )
          , Other ( "Enemy", ShieldMsg currentShield )
          , Other ( "Player", ShieldMsg currentShield )
          , Other ( "Particle", WeaponStateMsg newState )
          ]
        , ( env, False )
        )

    else
        ( ( { data | state = newState, shield = { currentShield | angle = 0 }, deltaPosition = currentDeltaPosition, scatter = newscatter }, basedata )
        , [ Other ( "Player", WeaponDir newState.direction )
          , Other ( "Bullet", WeaponStateMsg newState )
          , Other ( "Enemy", ShieldMsg currentShield )
          , Other ( "Player", ShieldMsg currentShield )
          , Other ( "Particle", WeaponStateMsg newState )
          ]
        , ( env, False )
        )


{-| Update function for left mouse event.
-}
handle_mouse_left : State -> Env SceneCommonData UserData -> Data -> BaseData -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
handle_mouse_left state env data basedata =
    let
        ( bullet, laser ) =
            initBulletAndLaser state.position state.angle state.direction

        ( b2, b3 ) =
            scatterBullet state.position state.angle state.direction

        deltaT =
            (env.globalData.currentTimeStamp - data.initPressedTime) / 1000

        newEnergy1 =
            max (state.energy - 50) 0

        newEnergy2 =
            max (state.energy - 5) 0
    in
    if state.energy == 0 then
        ( ( { data | initPressedTime = 0, isMousePressed = False, isLineOn = False }, basedata ), [], ( env, False ) )

    else if deltaT >= 1.5 && (data.initPressedTime /= 0) && (newEnergy1 /= 0) then
        ( ( { data | initPressedTime = 0, isMousePressed = False, isLineOn = False, state = { state | energy = newEnergy1 } }, basedata )
        , [ Other ( "Bullet", FireMsg laser )
          , Other ( "Player", FireMsg laser )
          , Parent <| SOMMsg <| SOMPlayAudio 0 "laser" <| AOnce Nothing
          ]
        , ( env, False )
        )

    else if (data.initPressedTime /= 0) && (newEnergy2 /= 0) then
        if data.scatter.ability then
            ( ( { data | initPressedTime = 0, isLineOn = False, isMousePressed = False, state = { state | energy = newEnergy2 } }, basedata )
            , [ Other ( "Bullet", FireMsg bullet )
              , Other ( "Bullet", FireMsg b2 )
              , Other ( "Bullet", FireMsg b3 )
              , Other ( "Player", FireMsg bullet )
              , Parent <| SOMMsg <| SOMPlayAudio 0 "bullet" <| AOnce Nothing
              ]
            , ( env, False )
            )

        else
            ( ( { data | initPressedTime = 0, isLineOn = False, isMousePressed = False, state = { state | energy = newEnergy2 } }, basedata )
            , [ Other ( "Bullet", FireMsg bullet )
              , Other ( "Player", FireMsg bullet )
              , Parent <| SOMMsg <| SOMPlayAudio 0 "bullet" <| AOnce Nothing
              ]
            , ( env, False )
            )

    else
        ( ( { data | isMousePressed = False, isLineOn = False }, basedata ), [], ( env, False ) )
