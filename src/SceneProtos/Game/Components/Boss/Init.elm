module SceneProtos.Game.Components.Boss.Init exposing (InitData, Drone, Elaser, BossBullet, Atom)

{-|


# Init module

Initialization of the boss component.

@docs InitData, Drone, Elaser, BossBullet, Atom

-}


{-| Definition of a drone.
`position`: the current position of the drone
`target`: the target position of the drone
`hp`: the health points of the drone
`direction`: the direction the drone is facing
`angle`: the angle of the drone
`lasttime`: the lasttime for a drone

example:
{ position = ( 600, 810 )
, target = ( 600, 810 )
, hp = 500
, direction = 0
, angle = pi / 2
, lasttime = 0
}

-}
type alias Drone =
    { position : ( Float, Float )
    , target : ( Float, Float )
    , hp : Float
    , direction : Float
    , angle : Float
    , lasttime : Float
    }


{-| Definition of a laser line.
`points`: the start and end points of the laser line
`v1`: the first vector of the laser line
`v2`: the second vector of the laser line
`acceleration1`: the first acceleration vector of the laser line
`acceleration2`: the second acceleration vector of the laser line
`whetherrotate`: whether the laser line should rotate
`rotatepoint`: the point around which the laser line rotates
`rotate`: the rotation angle of the laser line
`accelerationr`: the acceleration of the rotation
`endposition`: the end position of the laser line
`turned`: the angle turned by the laser line
`targetangle`: the target angle of the laser line
`attack`: the attack value of the laser line

Example:
{ points = ( ( 0, 0 ), ( 100, 100 ) )
, v1 = ( 1, 1 )
, v2 = ( 1, 1 )
, acceleration1 = ( 0, 0 )
, acceleration2 = ( 0, 0 )
, whetherrotate = True
, rotatepoint = ( 50, 50 )
, rotate = 0
, accelerationr = 0.1
, endposition = ( ( 0, 0 ), ( 100, 100 ) )
, turned = 0
, targetangle = 0
, attack = 10
}

-}
type alias Elaser =
    { points : ( ( Float, Float ), ( Float, Float ) )
    , v1 : ( Float, Float )
    , v2 : ( Float, Float )
    , acceleration1 : ( Float, Float ) -- I'll try to make it constant
    , acceleration2 : ( Float, Float ) -- I'll try to make it constant
    , whetherrotate : Bool
    , rotatepoint : ( Float, Float )
    , rotate : Float
    , accelerationr : Float -- I'll try to make it constant
    , endposition : ( ( Float, Float ), ( Float, Float ) )
    , turned : Float
    , targetangle : Float
    , attack : Float
    , atoms : List Atom
    }


{-| The atoms of visual effects

`position`: x and y coordinates of the atom.
`v`: velocity vector (vx, vy).
`color` RGB color triple, values between 0.0 and 1.0.
`releasetime`: timestamp when the atom was spawned.
`targettime`: lifespan duration of the atom.

Example:

    { position = ( 310, 410 )
    , v = ( 1.0, -1.0 )
    , color = ( 1.0, 0.0, 0.0 )
    , releasetime = 1.0
    , targettime = 0.5
    }

-}
type alias Atom =
    { position : ( Float, Float )
    , v : ( Float, Float )
    , color : Int
    , releasetime : Float
    , targettime : Float
    }


{-| Definition of a boss bullet.
`position`: the current position of the bullet
`direction`: the direction of the bullet
`attack`: the attack value of the bullet

Example:
{ position = ( 100, 200 )
, direction = 1.0
, attack = 50.0
}

-}
type alias BossBullet =
    { position : ( Float, Float )
    , direction : Float
    , attack : Float
    , atoms : List Atom
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , position : ( Float, Float )
    , hp : Float
    , drone : List Drone --drone will release flashes
    , dronenumber : Int
    , flash : List ( Float, Float ) -- seperated flash attack, maybe won't be implamented
    , elaser : List Elaser
    , bossbullet : List BossBullet
    , dt : Float
    , msg : Bool
    }
