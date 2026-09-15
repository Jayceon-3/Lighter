module SceneProtos.Game.Components.Player.Init exposing
    ( InitData
    , State
    , Spritetype(..)
    )

{-|


# Init module

@docs InitData
@docs State
@docs Spritetype

-}

import Json.Decode exposing (bool)
import SceneProtos.Game.Components.Map.Init exposing (..)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, Shield)


{-| Definition of the player state.
`position`: the current position of the player
`direction`: the direction the player is facing
`hp`: the health points of the player
`alive`: whether the player is alive
`vx`: the speed in the x direction
`vy`: the speed in the y direction
`a_pressed`: whether the 'A' key is pressed
`d_pressed`: whether the 'D' key is pressed
`s_pressed`: whether the 'S' key is pressed
`canjump`: the number of jumps available (0 for no jump, 1 for single jump, 2 for double jump)
`weaponDir`: the direction of the weapon
`keyNum`: the number of keys pressed (used for weapon selection)

Example:
{ position = ( 600, 810 )
, direction = 0
, hp = 100
, alive = True
, vx = 0
, vy = 0
, a\_pressed = False
, d\_pressed = False
, s\_pressed = False
, canjump = 2
, weaponDir = 0
, keyNum = 0
}

-}
type alias State =
    { position : ( Float, Float )
    , direction : Float
    , hp : Float
    , alive : Bool
    , vx : Float
    , vy : Float
    , a_pressed : Bool
    , d_pressed : Bool
    , s_pressed : Bool
    , canjump : Int
    , weaponDir : Float
    , keyNum : Float
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , state : State
    , isSwing : Bool
    , mechanicalArm : MechanicalArm
    , pendingCollisions : List CollisionDirection
    , tiles : List ( Int, Int, Tile )
    , currentShield : Shield
    , keyAnimation : Bool
    , rightbound : Float
    }


{-| The type of sprite used for the player.
`Run`: The player is running.
`Stay`: The player is standing still.
`Jump`: The player is jumping.
-}
type Spritetype
    = Run
    | Stay
    | Jump
