module SceneProtos.Game.Components.Player.HpbarRender exposing (hpBarRender)

{-|


# hpbarrender

Functions for render player hp bars.

@docs hpBarRender

-}

import Color
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Camera, Renderable, group)
import REGL.Effects exposing (alphamult)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection(..), Tile)
import SceneProtos.Game.Components.Player.Coordtransform exposing (screentocanvas)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, Shield)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


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


{-| render hp bars
-}
hpBarRender : Env SceneCommonData UserData -> Data -> List Renderable
hpBarRender env data =
    let
        time =
            env.globalData.sceneStartTime / 1000

        hpNum =
            round data.state.hp

        isLowHp =
            data.state.hp < 30

        isMediumHp =
            data.state.hp < 50

        flashAlpha =
            if isLowHp then
                abs (sin (time * 10))

            else if isMediumHp then
                abs (sin (time * 5))

            else
                1

        vibrationOffset =
            if isLowHp then
                ( sin (time * 15 * 4) * 5
                , cos (time * 12 * 4) * 3
                )

            else if isMediumHp then
                ( sin (time * 10 * 4) * 2
                , cos (time * 8 * 4) * 1
                )

            else
                ( 0, 0 )

        ( dx, dy ) =
            vibrationOffset

        baseHpBarPos =
            screentocanvas env.globalData.camera ( 50, 950 )

        hpBarPos =
            ( Tuple.first baseHpBarPos + dx
            , Tuple.second baseHpBarPos + dy
            )

        hpBarColor =
            if isLowHp then
                Color.rgba 1 0 0 flashAlpha

            else
                Color.red

        hpBar =
            [ P.rect hpBarPos ( data.state.hp / 100 * 200, 30 ) hpBarColor ]
    in
    hpBar
