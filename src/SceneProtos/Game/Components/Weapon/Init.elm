module SceneProtos.Game.Components.Weapon.Init exposing (InitData, MechanicalArm, MechanicalArmState(..), Scatter, Shield, ShieldState(..), State, SwingMode(..))

{-|


# Init module

@docs InitData, MechanicalArm, MechanicalArmState, Scatter, Shield, ShieldState, State, SwingMode

-}

import SceneProtos.Game.Components.Map.Init as MapInit exposing (Tile)


{-| Definition of the weapon state.
`position`: the current position of the weapon.
`direction`: the direction the wepaon is facing.
`angle`: the angle of the weapon.
`weapontype`: the type of weapon.
`energy`: the current left energy of the wepaon.

Example:
{ position = ( 600, 810 )
, direction = 0
, angle = pi / 4
, weaponType = 0
, energy = 100
}

-}
type alias State =
    { position : ( Float, Float )
    , direction : Float
    , angle : Float
    , weaponType : Int
    , energy : Float
    }


{-| The type of state of shield.
`Hand` means the shield is held by player.
`Ground` means the shield is put on the ground as a cover.
`Unused` means the shield is not used by player.
-}
type ShieldState
    = Unused
    | Hand
    | Ground


{-| Definition of a shield.
`position`: the current position of the shield.
`direction`: the direction of the shield.
`angle`: the angle of the shield.
`shieldState`: the current state of the bullet.
`initTime`: the initial time of the shield on the Ground.
`initHandTime`: the initial time of the shield held by player.

Example:
{ position = ( 600, 810 )
, direction = 1
, angle = pi / 4
, shieldState = Unused
, initTime = 0
, initHandTime = 0
}

-}
type alias Shield =
    { position : ( Float, Float )
    , direction : Float
    , angle : Float
    , shieldState : ShieldState
    , initTime : Float
    , initHandTime : Float
    }


{-| The type of state of mechanical arm.
`Closed` means the mechanical arm is not used.
`Streching` means the mechanical arm is now streching (length increase).
`Swing` means the mechnical arm is in swing mode now (angle change).
`Shortening` means the mechanical arm is shortening now (length decrease).
-}
type MechanicalArmState
    = Closed
    | Stretching
    | Swing
    | Shortening


{-| The type of mode of swing.
`Short` means the swing mode of mechnical arm is the imitation of a short spring pendulum.
`Medium` means the swing mode of mechnical arm is the imitation of a short spring pendulum.
`Long` means the swing mode of mechnical arm is the imitation of a short spring pendulum.
`Dash` means the swing mode of mechnical arm is only sideway movements.
-}
type SwingMode
    = Short
    | Medium
    | Long
    | Dash


{-| Definition of a mechanical arm.
`position`: the current position of the mechanical arm.
`speed`: the speed of the mechanical arm.
`angle`: the angle of the mechanical arm.
`state`: the current state of the mechanical arm.
`length`: the current length of the mechanical arm.
`initSpringTime`: the initial time of the mechanical arm in swing mode.
`initSpringPos`: the initial position of the mechanical arm in swing mode.
`swingMode`: the swing mode and direction of swing of the mechanical arm.

Example:
{ position = ( 600, 810 )
, speed = 10
, angle = pi / 4
, state = Swing
, initSpringTime = 0
, initSpringPos = ( 1600, 900 )
, swingMode = ( Long, 1 )
}

Here, the second element of swingMode stands for the swing direction.
`swingMode = ( Long, 1 )` means player is swing towards right in `Long` mode.
`swingMode = ( Long, -1 )` means player is swing towards left in `Long` mode.

-}
type alias MechanicalArm =
    { position : ( Float, Float )
    , speed : ( Float, Float )
    , angle : Float
    , state : MechanicalArmState
    , length : Float
    , anchor : ( Float, Float )
    , initSpringTime : Float
    , initSpringPos : ( Float, Float )
    , swingMode : ( SwingMode, Float )
    }


{-| Definition of scatter skill of bullet.
`position`: the start time of scatter skill.
`ability`: the skill is activated or not.

Example:
{ startTime = 0
, ability = False
}

-}
type alias Scatter =
    { starttime : Float
    , ability : Bool
    }


{-| The data used to initialize the scene
-}
type alias InitData =
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
