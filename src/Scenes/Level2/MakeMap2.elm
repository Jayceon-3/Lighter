module Scenes.Level2.MakeMap2 exposing (map2, temptiles2)

{-|


# MakeMap2

Functions to generate a map for Level 2 of the game.

@docs map2, temptiles2

-}

import Array exposing (Array)
import SceneProtos.Game.Components.Map.CollisionLogic exposing (getmapinformation)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..), tile)
import Scenes.Level1.MakeMap exposing (generatearow, intToTileKind, rowFromInts)



-- frame, top, middle, key, damage, recover, fake


{-| Create a tile map for the game level.
-}
rows1 : List (Array Tile)
rows1 =
    [ generatearow (List.range 0 79) [] [] [] [] [] [] [] |> rowFromInts --top
    , generatearow [ 0, 79 ] (List.range 41 42 ++ List.range 64 68) [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 63, 69 ] (List.range 41 42 ++ [ 64, 68 ]) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 62, 70 ] (List.range 41 42 ++ [ 63, 69 ]) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [] [ 41, 42, 62, 70 ] [ 35 ] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 5, 14 ] [ 41, 42 ] [ 66 ] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 6, 13, 40 ] ++ List.range 43 47) [ 5, 14, 41, 42 ] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 7 8 ++ List.range 11 12 ++ [ 39, 63, 69 ] ++ List.range 48 51) (List.range 40 47 ++ [ 6, 13 ]) [] [] [] [ 62, 70 ] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 38, 52, 53, 64, 68, 72, 73 ] (List.range 40 51 ++ [ 63, 69, 8, 11, 39 ]) [] [] [] [ 9, 10 ] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 36, 37, 57, 58, 74, 75 ] [ 38, 39, 64, 68, 73 ] [] (List.range 65 67) [] [] [] |> rowFromInts
    ]


{-| Create a tile map for the game level.
-}
rows2 : List (Array Tile)
rows2 =
    [ generatearow [ 0, 79 ] ([ 34, 35, 55, 56 ] ++ List.range 76 78) [ 36, 37, 38, 57, 58, 74, 75 ] [] [] [] [] [] |> rowFromInts --top
    , generatearow [ 0, 79 ] [ 1, 33, 59, 60 ] (List.range 34 36 ++ [ 58, 77, 78 ]) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 2, 18, 32, 63 ] [ 1, 33, 60, 78 ] [] (List.range 21 29) [ 19, 20, 30, 31 ] [ 61, 62 ] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 3, 4 ] (List.range 1 2 ++ List.range 18 33) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 5, 6 ] ++ List.range 65 71) (List.range 1 4 ++ List.range 31 33) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 7, 34 ] ++ List.range 14 16 ++ List.range 53 64 ++ List.range 72 78) (List.range 1 6 ++ [ 33 ] ++ List.range 65 71) [] (List.range 8 13) [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 17, 18, 35, 52 ] (List.range 1 16 ++ [ 34 ] ++ List.range 53 78) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 19, 36 ] ++ List.range 50 51) (List.range 1 2 ++ List.range 16 18 ++ [ 35 ] ++ List.range 52 53) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 48, 49 ] (List.range 1 2 ++ [ 36 ] ++ List.range 50 52) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 37, 47 ] ([ 36 ] ++ List.range 48 50) [] [] [] [] [] |> rowFromInts
    ]


{-| Create a tile map for the game level.
-}
rows3 : List (Array Tile)
rows3 =
    [ generatearow [ 0, 79 ] (List.range 20 23 ++ List.range 34 35 ++ List.range 43 46) (List.range 36 37 ++ List.range 47 49) [] [] [] [] [] |> rowFromInts --top
    , generatearow [ 0, 79 ] (List.range 32 33 ++ List.range 75 78 ++ [ 72 ]) (List.range 20 21 ++ List.range 34 37 ++ List.range 43 47) [] [] [] [ 42, 73, 74 ] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 15 19 ++ [ 38, 57, 64 ]) ([ 20, 21 ] ++ List.range 35 37 ++ List.range 75 78) [] (List.range 58 59 ++ List.range 62 63) [ 60, 61 ] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 12, 13, 28, 29, 39, 65 ] ++ List.range 54 56) (List.range 15 20 ++ List.range 36 38 ++ List.range 57 64) [] [] [] [ 14 ] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 27, 66 ] ++ List.range 40 41 ++ List.range 51 53) ([ 19, 20, 28 ] ++ List.range 36 39 ++ List.range 54 57 ++ List.range 63 65) [] (List.range 42 44 ++ List.range 48 50) (List.range 45 47) [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 1 5 ++ [ 35 ] ++ List.range 67 71) (List.range 19 20 ++ List.range 27 28 ++ List.range 36 55 ++ List.range 64 66) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 6, 72 ] (List.range 1 5 ++ List.range 27 28 ++ List.range 35 37 ++ List.range 65 71) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 7, 8, 73 ] (List.range 1 6 ++ List.range 27 28 ++ List.range 35 36 ++ [ 72 ]) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 9, 29, 74 ] (List.range 1 8 ++ [ 28, 35, 73 ]) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 51 54) [ 28, 29, 35 ] [] [] [] [] [] |> rowFromInts
    ]


{-| Create a tile map for the game level.
-}
rows4 : List (Array Tile)
rows4 =
    [ generatearow [ 0, 79 ] ([ 34, 36 ] ++ List.range 47 49 ++ List.range 65 66 ++ List.range 70 71) (List.range 28 29 ++ [ 35 ] ++ List.range 51 52) [] [] [ 67, 68, 69 ] [ 50 ] [] |> rowFromInts --top
    , generatearow [ 0, 79 ] ([ 27, 46 ] ++ List.range 62 64 ++ List.range 72 75) (List.range 28 29 ++ List.range 47 49 ++ List.range 65 71) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 13 17 ++ List.range 23 26 ++ List.range 42 45) ([ 27, 28 ] ++ List.range 46 47 ++ List.range 62 75) [] (List.range 18 22) [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 12, 78 ] ++ List.range 39 41) (List.range 13 26 ++ List.range 42 46) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 11 ] ([ 78 ] ++ List.range 12 14 ++ List.range 39 42) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 30 32 ++ [ 10 ] ++ List.range 73 77) (List.range 11 13 ++ List.range 40 42 ++ [ 78 ]) [ 53 ] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 9 ] ++ List.range 27 29 ++ List.range 69 72) (List.range 10 12 ++ List.range 30 32 ++ List.range 41 42 ++ List.range 73 78) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 8, 26, 33, 43 ] ++ List.range 65 68) (List.range 9 12 ++ List.range 27 32 ++ List.range 41 43 ++ List.range 69 78) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 7, 13, 25, 34, 40, 44, 45 ] (List.range 8 12 ++ List.range 26 33 ++ List.range 41 43 ++ List.range 65 78) [] (List.range 46 54 ++ List.range 57 64) [ 55, 56 ] [] [] |> rowFromInts
    , generatearow (List.range 0 79) [] [] [] [] [] [] [] |> rowFromInts
    ]


{-| Generate the test tile map.
-}
map2 : Array (Array Tile)
map2 =
    Array.fromList (rows1 ++ rows2 ++ rows3 ++ rows4)


{-| Get map information from map2.
-}
temptiles2 : List ( Int, Int, Tile )
temptiles2 =
    getmapinformation map2
