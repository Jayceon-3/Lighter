module SceneProtos.Game.Components.Bullet.Init exposing (InitData, BulletType(..), SingleBullet)

{-|


# Init module

Initialization for bullet components in the game.

@docs InitData, BulletType, SingleBullet

-}

import SceneProtos.Game.Components.Map.Init as MapInit exposing (Tile)


{-| The type of bullet, which can be either an ordinary bullet or a laser.
-}
type BulletType
    = Ordinary
    | Laser


{-| Definition of a single bullet.
`position`: the current position of the bullet
`direction`: the direction the bullet is facing
`shape`: the shape of the bullet
`angle`: the angle of the bullet
`bulletType`: the type of the bullet (Ordinary or Laser)
`attack`: the attack value of the bullet

Example:
{ position = ( 600, 810 )
, direction = 1
, shape = ( 10, 10 )
, angle = pi / 4
, bulletType = Ordinary
, attack = 50
}

-}
type alias SingleBullet =
    { position : ( Float, Float )
    , direction : Float
    , shape : ( Float, Float )
    , angle : Float
    , bulletType : BulletType
    , attack : Float
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , bullets : List SingleBullet
    , laser : ( SingleBullet, Bool )
    , laserInitTime : Float
    , tiles : List ( Int, Int, Tile )
    }
