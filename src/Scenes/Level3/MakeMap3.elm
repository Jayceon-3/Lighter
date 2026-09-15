module Scenes.Level3.MakeMap3 exposing (map3)

{-|


# MakeMap3

Functions to generate a map for Level 3 of the game.

@docs map3

-}

import Array exposing (Array)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..))
import Scenes.Level1.MakeMap exposing (generatearow, rowFromInts)


rows1 : List (Array Tile)
rows1 =
    [ generatearow (List.range 0 31) [] [] [] [] [] [] [] |> rowFromInts --top
    , generatearow [ 0, 31 ] [] [ 9, 10 ] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [ 9, 10 ] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [ 9, 10 ] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [ 9, 10 ] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [ 9, 10 ] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [] [] [] [] [] [] |> rowFromInts
    ]


rows2 : List (Array Tile)
rows2 =
    [ generatearow [ 0, 31 ] [] [] [] [] [] [] [] |> rowFromInts --top
    , generatearow [ 0, 31 ] [] [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] (List.range 1 7) [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] (List.range 1 4) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [ 1, 2 ] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 31 ] [] [] [] [] [] [] [] |> rowFromInts
    , generatearow (List.range 0 31) [] [] [] [] [] [] [] |> rowFromInts
    ]


{-| Generate the tile map for the game level.
-}
map3 : Array (Array Tile)
map3 =
    Array.fromList (rows1 ++ rows2)
