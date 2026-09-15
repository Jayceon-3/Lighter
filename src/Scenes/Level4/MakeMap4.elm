module Scenes.Level4.MakeMap4 exposing (map4)

{-|


# MakeMap4

Functions to generate a map for the game level.

@docs map4

-}

import Array exposing (Array)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..))
import Scenes.Level1.MakeMap exposing (generatearow, rowFromInts)


rows1 : List (Array Tile)
rows1 =
    [ generatearow [] [] [] [] [] [] [] (List.range 0 31) |> rowFromInts --top
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    ]


rows2 : List (Array Tile)
rows2 =
    [ generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31 ] |> rowFromInts --top
    , generatearow [] [] [] [] [] [] [] ([ 0, 31 ] ++ List.range 5 8 ++ List.range 23 26) |> rowFromInts
    , generatearow [] [] [] [] [] [] [] [ 0, 31, 1, 8, 9, 30, 22, 23 ] |> rowFromInts
    , generatearow [] [] [] [] [] [] [] (List.range 0 2 ++ List.range 8 10 ++ List.range 21 23 ++ List.range 29 31) |> rowFromInts
    , generatearow [] [] [] [] [] [] [] (List.range 0 31) |> rowFromInts
    ]


{-| Generate the tile map for the game level.
-}
map4 : Array (Array Tile)
map4 =
    Array.fromList (rows1 ++ rows2)
