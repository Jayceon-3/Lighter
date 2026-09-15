module SceneProtos.Game.Components.Player.LevelCamera exposing (updatecamera)

{-|


# LevelCamera

This module handles the camera logic for the player in different levels.

@docs updatecamera

-}

-- import SceneProtos.Game.Components.Player.Playerlogic exposing (a, g, resolveCollisions)
-- import SceneProtos.Game.Components.Player.Recoil exposing (recoil, upperLimit)
-- import SceneProtos.Game.Components.Bullet.Init exposing (SingleBullet)

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.Common exposing (Camera)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection, Tile)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.Components.Player.Doublejump exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, MechanicalArmState(..), Shield, ShieldState(..), SwingMode(..))
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Data model for the player. Copied from model to avoid import loop.
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


judgelevel : Env SceneCommonData UserData -> Bool
judgelevel env =
    let
        level =
            env.globalData.userData.currentlevel
    in
    if level == 3 || level == 4 then
        True

    else
        False


{-| Updates the camera based on the player's position and the current level.
-}
updatecamera : Env SceneCommonData UserData -> Data -> Camera
updatecamera env data =
    let
        playercamera =
            data.playercamera

        defaultcamera =
            env.globalData.camera

        newCamera =
            if judgelevel env then
                defaultcamera

            else
                playercamera
    in
    newCamera
