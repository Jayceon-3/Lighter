module SceneProtos.Game.Components.Map.Collisionhelp exposing (Data, Context, DirectionSpec)

{-|


# Collisionhelp

Helper Types for collision detection in a tile-based map.

@docs Data, Context, DirectionSpec

-}

import Array exposing (Array)
import Messenger.GeneralModel exposing (Msg(..))
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection(..), Tile, TileKind(..))


{-| The data structure for the map. Copied from the Model to avoid import loop.
-}
type alias Data =
    { id : Int
    , ty : String
    , tiles : Array (Array Tile)
    , tileWidth : Int
    , tileHeight : Int
    }


{-| The context for collision detection, containing the position, dimensions, and map data.
`x`, `y`: The position of the object in the map.
`x1`, `y1`: The position of the object in the map after applying a transformation.
`w`, `h`: The width and height of the object.
`tileHf`, `tileWf`: Half the height and width of a tile, used for collision calculations.
`sampleCount`: The number of samples to take for collision detection.
`mapData`: The map data containing the tiles and their properties.

Example:

    { x = 100
    , y = 200
    , x1 = 150
    , y1 = 250
    , w = 50
    , h = 50
    , tileHf = 16
    , tileWf = 16
    , sampleCount = 5
    , mapData = mapData
    }

-}
type alias Context =
    { x : Float
    , y : Float
    , x1 : Float
    , y1 : Float
    , w : Float
    , h : Float
    , tileHf : Float
    , tileWf : Float
    , sampleCount : Int
    , mapData : Data
    }


{-| Defines the specifications for collision detection in different directions.
`dir`: The direction of the collision.
`tileIndex`: A function to get the index of the tile in the specified direction.
`boundary`: A function to get the boundary value for the specified direction.
`cross`: A function to check if the collision crosses the boundary in the specified direction.
`sampleStart`: A function to get the starting point for sampling in the specified direction.
`sampleSpan`: A function to get the span for sampling in the specified direction.
`samplePoint`: A function to get the sample point in the specified direction based on a given
distance.
-}
type alias DirectionSpec =
    { dir : CollisionDirection
    , tileIndex : Context -> Int
    , boundary : Context -> Int -> Float
    , cross : Context -> Float -> Bool
    , sampleStart : Context -> ( Float, Float )
    , sampleSpan : Context -> Float
    , samplePoint : Context -> Float -> ( Float, Float )
    }
