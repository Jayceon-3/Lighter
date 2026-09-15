module SceneProtos.Game.Components.Enemy.Init exposing
    ( InitData
    , EnemyBullet, Enemytype(..), Enemystate(..), Enemy
    )

{-|


# Init module

@docs InitData
@docs EnemyBullet, Enemytype, Enemystate, Enemy

-}

import SceneProtos.Game.Components.Map.Init exposing (Tile)
import SceneProtos.Game.Components.Player.Init exposing (..)


{-| The bullets released by enemies

`position`: x and y coordinates of the bullet center.
`direction`: travel direction of the bullet in radians.
`angle`: current rotation angle of the bullet.
`attack`: damage value of the bullet.
`appear`: appearance state or type of the bullet.

Example:

    { position = ( 100, 200 )
    , direction = 1.57
    , angle = 0.0
    , attack = 5
    , appear = 1
    }

-}
type alias EnemyBullet =
    { position : ( Float, Float )
    , direction : Float
    , angle : Float
    , attack : Float
    , appear : Int
    }


{-| The types of enemies

`Normal`: basic enemy type.
`Advanced`: stronger enemy type.
`Dead`: defeated enemy state.

-}
type Enemytype
    = Normal
    | Advanced
    | Dead


{-| The states of enemies

`Default`: idle or patrolling state.
`Buffer`: transition state between Default and Attack.
`Attack`: actively attacking state.

-}
type Enemystate
    = Default
    | Buffer
    | Attack


{-| The structure of an enemy

`position`: current x and y coordinates.
`defaultposition`: original spawn position.
`direction`: facing direction in radians.
`vx`: horizontal velocity.
`vy`: vertical velocity.
`hp`: current health points.
`enemystate`: current behavior state.
`enemytype`: classification of enemy.
`angle`: rotation angle for display.
`time`: time since spawn or state change.
`appear`: appearance state or type.
`target`: coordinates of current target.
`tiles`: list of map tiles the enemy occupies (x,y coordinates and Tile data).
`have_droped_or_not`: whether loot has been dropped.

Example:

    { position = ( 300, 400 )
    , defaultposition = ( 300, 400 )
    , direction = 0.0
    , vx = 1.0
    , vy = 0.0
    , hp = 100
    , enemystate = Default
    , enemytype = Normal
    , angle = 0.0
    , time = 0.0
    , appear = 1
    , target = ( 0, 0 )
    , tiles = []
    , have_droped_or_not = False
    }

-}
type alias Enemy =
    { position : ( Float, Float )
    , defaultposition : ( Float, Float )
    , direction : Float -- direction on the x
    , vx : Float
    , vy : Float
    , hp : Float
    , enemystate : Enemystate
    , enemytype : Enemytype
    , angle : Float
    , time : Float
    , appear : Int
    , target : ( Float, Float )
    , tiles : List ( Int, Int, Tile )
    , have_droped_or_not : Bool
    }


{-| The data used to initialize the enemy component

`id`: unique identifier for the component.
`ty`: type identifier string.
`enemy`: list of active Enemy instances.
`enemybullet`: list of active EnemyBullet instances.
`dt`: delta time since last update.
`real`: real position in the game world.

Example:

    { id = 1
    , ty = "enemy"
    , enemy = []
    , enemybullet = []
    , dt = 0.016
    , real = ( 0, 0 )
    }

-}
type alias InitData =
    { id : Int
    , ty : String
    , enemy : List Enemy
    , enemybullet : List EnemyBullet
    , dt : Float
    , real : ( Float, Float )
    }
