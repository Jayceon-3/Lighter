module SceneProtos.Game.Components.Player.Helper exposing (DirectionSpec, tileH, tileW, Data, help_stat, help_y_camera, msg2, msg3)

{-|


# Helper

This module contains helper functions and constants used in the player logic.

@docs DirectionSpec, tileH, tileW, Data, help_stat, help_y_camera, msg2, msg3

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.Common exposing (Camera)
import SceneProtos.Game.Components.Bullet.Init exposing (SingleBullet)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (..)
import SceneProtos.Game.Components.Enemy.Init exposing (Enemystate(..), Enemytype(..))
import SceneProtos.Game.Components.Map.Init exposing (..)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.Components.Player.Doublejump exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (..)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, MechanicalArmState(..), Shield, ShieldState(..), SwingMode(..))



--check movement with multiple collision


{-| A type alias for direction specifications used in collision detection and resolution.
`dir`: The direction of the collision.
`condition`: A function that checks a condition based on the player's state.
`tileIndex`: A function that returns the index of the tile based on the player's state.
`correctedPos`: A function that calculates the corrected position based on the player's state and tile index.
`stopVy`: A boolean indicating whether to stop vertical velocity.
`stopVx`: A boolean indicating whether to stop horizontal velocity.
`setJump`: A boolean indicating whether to set the jump state.

Example:

    { dir = Left
    , condition = \state -> state.onGround
    , tileIndex = \state -> state.tileIndex
    , correctedPos = \state index -> ( state.position.x, state.position.y - tileH )
    , stopVy = True
    , stopVx = False
    , setJump = True
    }

-}
type alias DirectionSpec =
    { dir : CollisionDirection
    , condition : State -> Bool
    , tileIndex : State -> Int
    , correctedPos : State -> Int -> ( Float, Float )
    , stopVy : Bool
    , stopVx : Bool
    , setJump : Bool
    }


{-| The width of a tile in the game.
-}
tileW : Float
tileW =
    60


{-| The height of a tile in the game.
-}
tileH : Float
tileH =
    60



-- may by changed so they are listed independently


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


{-| Helper function to calculate the y-coordinate of the camera based on the player's state and position.
-}
help_y_camera : State -> Data -> Float -> Float -> Float
help_y_camera stat data dt y1 =
    if stat.s_pressed then
        min 1855 (max 550 (min (data.playercamera.y + 1500 * dt / 1000) (y1 - 200 + 300)))

    else
        min 1855 (max 550 (max (data.playercamera.y - 1500 * dt / 1000) (y1 - 200)))


{-| Helper function to update the player's state based on input parameters.
-}
help_stat : State -> Float -> Float -> Float -> Float -> Float -> State
help_stat sta x1 y1 vx1 vy1 vx2 =
    if sta.a_pressed && sta.d_pressed then
        { sta | position = ( x1, y1 ), vx = vx2, vy = vy1 }

    else if sta.a_pressed && not sta.d_pressed then
        { sta | position = ( x1, y1 ), vx = vx2, vy = vy1, direction = -1 }

    else if not sta.a_pressed && sta.d_pressed then
        { sta | position = ( x1, y1 ), vx = vx2, vy = vy1, direction = 1 }

    else
        { sta | position = ( x1, y1 ), vx = vx1, vy = vy1 }


{-| Generates a list of messages.
-}
msg1 : Data -> List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata))
msg1 data =
    [ Other ( "Weapon", PlayerStateMsg data.state )
    , Other ( "Enemy", PlayerStateMsg data.state )
    , Other ( "Survcamera", PlayerStateMsg data.state )
    , Other ( "Ceo", PlayerStateMsg data.state )
    , Other ( "Boss", PlayerStateMsg data.state )
    , Other ( "Particle", PlayerStateMsg data.state )
    , Other ( "Drop", PlayerStateMsg data.state )
    , Parent <| SOMMsg <| SOMSaveGlobalData
    ]


{-| Generates a list of messages.
-}
msg2 : State -> Float -> Float -> ( Float, Float ) -> Float -> Float -> List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata))
msg2 newState x y newPos w h =
    [ Other ( "Weapon", PlayerStateMsg newState )
    , Other ( "Enemy", PlayerStateMsg newState )
    , Other ( "Survcamera", PlayerStateMsg newState )
    , Other ( "Ceo", PlayerStateMsg newState )
    , Other ( "Boss", PlayerStateMsg newState )
    , Other ( "Map", CheckCollisionMsg { x = x, y = y, x1 = Tuple.first newPos, y1 = Tuple.second newPos, w = w, h = h } )
    , Other ( "Particle", PlayerStateMsg newState )
    , Other ( "Drop", PlayerStateMsg newState )
    , Parent <| SOMMsg <| SOMSaveGlobalData
    ]


{-| Generates a list of messages.
-}
msg3 : Data -> MechanicalArm -> List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata))
msg3 data currentArm =
    msg1 data ++ [ Other ( "Weapon", MechanicalArmMsg currentArm ) ]
