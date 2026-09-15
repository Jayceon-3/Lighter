module SceneProtos.Game.Components.Survcamera.Init exposing
    ( CameraBullet, CameraState(..), Survcamera
    , InitData
    )

{-|


# Init module

@docs CameraBullet, CameraState, Survcamera
@docs InitData

-}

import SceneProtos.Game.Components.Map.Init exposing (Tile)


{-| The structure of camera bullet
`position`: center coordinates of the bullet.
`direction`: travel direction in radians.
`attack`: damage value when hitting the player.
Example:

    { position = ( 120, 300 )
    , direction = 1.57
    , attack = 10.0
    }

-}
type alias CameraBullet =
    { position : ( Float, Float )
    , direction : Float
    , attack : Float
    }


{-| The state of cameras
`Default`: camera is idle.
`Attack`: camera is in active attack mode.
-}
type CameraState
    = Default
    | Attack


{-| The structure of survcamera
`position`: current camera center position.
`defaultpoint`: original spawn position of the camera.
`direction`: movement direction in radians.
`angle`: current rotation angle in radians.
`hp`: health points of the camera.
`bounds`: axis-aligned bounding box as ((minX, minY), (maxX, maxY)).
`drawpoints`: polygon vertices defining the field of view.
`isAlive`: whether the camera is active.
`time`: internal timer for animations or state transitions.
`camerastate`: current state of the camera.
`tiles`: list of solid tile centers for collision.
`tilebound`: list of tile boundary points.
`target`: current target point the camera tracks.
`height`: number of brick rows in view.
Example:

    { position = ( 400, 200 )
    , defaultpoint = ( 400, 200 )
    , direction = 0.0
    , angle = 0.0
    , hp = 100.0
    , bounds = ( ( 0, 0 ), ( 800, 600 ) )
    , drawpoints = [ ( 100, 100 ), ( 700, 100 ), ( 700, 500 ), ( 100, 500 ) ]
    , isAlive = True
    , time = 0.0
    , camerastate = Default
    , tiles = [ ( 5, 5, tile1 ), ( 6, 5, tile2 ) ]
    , tilebound = [ ( 300, 300 ), ( 360, 300 ), ( 360, 360 ), ( 300, 360 ) ]
    , target = ( 450, 350 )
    , height = 10.0
    }

-}
type alias Survcamera =
    { position : ( Float, Float )
    , defaultpoint : ( Float, Float )
    , direction : Float -- moving direction
    , angle : Float -- rotating angle
    , hp : Float
    , bounds : ( ( Float, Float ), ( Float, Float ) )
    , drawpoints : List ( Float, Float )
    , isAlive : Bool
    , time : Float
    , camerastate : CameraState
    , tiles : List ( Int, Int, Tile ) -- to make it faster, I think only the solid ones can be stored.
    , tilebound : List ( Float, Float )
    , target : ( Float, Float )
    , height : Float -- number of bricks
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , survcameras : List Survcamera
    , camerabullets : List CameraBullet
    , tiles : List ( Int, Int, Tile )
    , dt : Float
    }
