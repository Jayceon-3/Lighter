module SceneProtos.Game.Components.Enemy.EnemyWallHelp exposing (judgeemptytiles)

{-|


# EnemyWallHelp

Helper functions for enemy wall collision detection.

@docs judgeemptytiles

-}

import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..), tile)


{-| Check if there is empty space below a given tile

This function determines if a tile has empty space (non-solid tile) directly below it
by checking the tile at (x, y+60) coordinates.

`tile`: The tile to check (x, y coordinates and Tile data)
`tiles`: List of all tiles in the current map

Returns True if there is an empty tile below the given tile, False otherwise

Example:
judgeemptytiles (10, 20, tile) allTiles
-- Returns True if position (10, 80) is empty

-}
judgeemptytiles : ( Int, Int, Tile ) -> List ( Int, Int, Tile ) -> Bool
judgeemptytiles tile tiles =
    let
        ( x, y, _ ) =
            tile

        list =
            List.filter
                (\t ->
                    let
                        ( m, n, _ ) =
                            t

                        tilejudge =
                            m == x && n - y == 60
                    in
                    tilejudge
                )
                tiles

        judge =
            not (List.isEmpty list)
    in
    judge
