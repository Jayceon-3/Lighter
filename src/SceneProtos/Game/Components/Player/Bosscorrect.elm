module SceneProtos.Game.Components.Player.Bosscorrect exposing (poscorrect)

{-|


# Bosscorrect

Functions for correcting player position in high levels

@docs poscorrect

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import REGL.Common exposing (Camera)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection(..), Tile)
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


{-| correct playerposition
-}
poscorrect : Data -> Env SceneCommonData UserData -> Data
poscorrect data env =
    let
        judge =
            env.globalData.userData.currentlevel > 2

        ( oldx, oldy ) =
            data.state.position

        right =
            min data.rightbound 1920

        newposition =
            if judge then
                if oldx <= 0 then
                    ( 15, oldy )

                else if oldx > right then
                    ( right - 15, oldy )

                else
                    ( oldx, oldy )

            else
                ( oldx, oldy )

        oldstate =
            data.state

        newstate =
            { oldstate | position = newposition }

        newdata =
            { data | state = newstate }
    in
    newdata
