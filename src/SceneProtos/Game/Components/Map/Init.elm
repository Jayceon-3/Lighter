module SceneProtos.Game.Components.Map.Init exposing (TileKind(..), Tile, InitData, CollisionDirection(..), tile)

{-|


# Init

Initialization for the map component.

@docs TileKind, Tile, InitData, CollisionDirection, tile

-}

import Array exposing (Array)


{-| List different kinds of tiles used in judging collision and rendering.
'Empty' means the block is not solid and not rendered.
'SolidTop' means the block is solid and the top of it is exposed.
'SolidMiddle' means the block is solid and the top of it is covered.
'KeyBlock' means the block needs to be gathered to enter next level.
'DamageBlock' means the block will cause damage to the player when standing on it.
'RecoverBlock' means the block will restore player's health point when standing on it.
'FakeBlock' means the block is visible but not solid.
'Frame' means the block is placed outside the map.
'DWbrick' is used to render bricks in level4.
-}
type TileKind
    = Empty
    | SolidTop
    | SolidMiddle
    | KeyBlock
    | DamageBlock
    | RecoverBlock
    | FakeBlock
    | Frame
    | DWbrick


{-| A tile is a block in the map.
`kind`: the kind of the tile, which is one of the `TileKind`
`solid`: whether the tile is solid or not, which is used in collision detection.

Example:
{ kind = SolidTop
, solid = True
}

-}
type alias Tile =
    { kind : TileKind
    , solid : Bool
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , tiles : Array (Array Tile)
    , tileWidth : Int
    , tileHeight : Int
    }


{-| Used to denote where the player collides with the blocks.
For example, if the player falls onto a solid block, then the collision direction is 'Bottom".
-}
type CollisionDirection
    = Top
    | Bottom
    | Left
    | Right
    | None


{-| Convert a `TileKind` to a `Tile`.
-}
tile : TileKind -> Tile
tile kind =
    case kind of
        Empty ->
            { kind = Empty, solid = False }

        SolidTop ->
            { kind = SolidTop, solid = True }

        SolidMiddle ->
            { kind = SolidMiddle, solid = True }

        Frame ->
            { kind = Frame, solid = True }

        KeyBlock ->
            { kind = KeyBlock, solid = True }

        DamageBlock ->
            { kind = DamageBlock, solid = True }

        RecoverBlock ->
            { kind = RecoverBlock, solid = True }

        FakeBlock ->
            { kind = FakeBlock, solid = False }

        DWbrick ->
            { kind = DWbrick, solid = True }
