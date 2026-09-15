module Scenes.Level1.MakeMap exposing (intToTileKind, rowFromInts, generatearow, testTileMap)

{-|


# MakeMap

Functions to generate a map for the game level.

@docs intToTileKind, rowFromInts, generatearow, testTileMap

-}

import Array exposing (Array)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..), tile)


{-| Convert an integer to a corresponding TileKind.
-}
intToTileKind : Int -> TileKind
intToTileKind n =
    case n of
        1 ->
            SolidTop

        10 ->
            SolidMiddle

        11 ->
            Frame

        2 ->
            KeyBlock

        3 ->
            DamageBlock

        4 ->
            RecoverBlock

        5 ->
            FakeBlock

        0 ->
            Empty

        6 ->
            DWbrick

        _ ->
            Empty


{-| Convert a TileKind to a Tile.
-}
toTile : TileKind -> Tile
toTile kind =
    tile kind


{-| Convert a list of integers to an Array of Tiles.
-}
rowFromInts : List Int -> Array Tile
rowFromInts ints =
    ints
        |> List.map (\n -> toTile (intToTileKind n))
        |> Array.fromList


{-| Generate a row of tiles based on various parameters.
-}
generatearow : List Int -> List Int -> List Int -> List Int -> List Int -> List Int -> List Int -> List Int -> List Int
generatearow frame solidtop solidmiddle key damage recover fake dw =
    List.map
        (\i ->
            if List.member i solidtop then
                1

            else if List.member i solidmiddle then
                10

            else if List.member i frame then
                11

            else if List.member i key then
                2

            else if List.member i damage then
                3

            else if List.member i recover then
                4

            else if List.member i fake then
                5

            else if List.member i dw then
                6

            else
                0
        )
        (List.range 0 79)


{-| Create a tile map for the game level.
-}
rows1 : List (Array Tile)



-- frame, top, middle, key, damage, recover, fake


rows1 =
    [ generatearow (List.range 0 79) [] [] [] [] [] [] [] |> rowFromInts --top
    , generatearow [ 0, 79 ] [] [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [] [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [] [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 56 59 ++ List.range 77 78) [] [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 52 55 ++ List.range 74 76) (List.range 56 58 ++ List.range 77 78) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 65 66 ++ List.range 69 73) (List.range 74 78) [ 10 ] [] [] [ 67, 68 ] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 43 49) (List.range 70 78) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 3, 42 ] (List.range 43 48 ++ List.range 76 78) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 4 7 ++ List.range 12 13 ++ List.range 40 41) ([ 3 ] ++ List.range 42 47 ++ List.range 76 78) [] (List.range 8 11) [] [] [] |> rowFromInts
    ]


{-| Create a tile map for the game level.
-}
rows2 : List (Array Tile)



-- frame, top, middle, key, damage, recover, fake


rows2 =
    [ generatearow [ 0, 79 ] (List.range 14 15 ++ [ 39, 74, 75 ]) (List.range 5 13 ++ List.range 40 46 ++ List.range 76 78) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 1, 22 ] ++ List.range 16 17 ++ List.range 37 38 ++ List.range 70 73) (List.range 14 15 ++ List.range 39 40 ++ List.range 44 46 ++ List.range 74 78) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 2, 3, 57 ] ++ List.range 35 36 ++ List.range 64 69) ([ 1, 16, 17, 22 ] ++ List.range 36 39 ++ List.range 44 45 ++ List.range 70 74) [] [] (List.range 18 21) [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 23, 34, 58, 63 ] ++ List.range 49 53) (List.range 17 22 ++ List.range 35 37 ++ List.range 44 45 ++ [ 57 ] ++ List.range 64 70) [] [] (List.range 59 62) [ 54 ] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 24 ] ([ 23 ] ++ List.range 44 45 ++ List.range 50 51 ++ List.range 58 64) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 4 10 ++ List.range 12 13) [ 24, 44, 45, 50 ] [] [] [] [ 11 ] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 3 ] (List.range 4 8 ++ List.range 44 45) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 2 ] (List.range 3 4 ++ List.range 44 45) [ 69 ] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] ([ 1, 46 ] ++ List.range 18 25) (List.range 2 4 ++ List.range 44 45) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 5 17 ++ List.range 47 48 ++ [ 59 ] ++ List.range 62 64 ++ List.range 75 76) (List.range 1 4 ++ List.range 18 25 ++ List.range 44 46) [] [] [] [ 60, 61 ] [] |> rowFromInts
    ]


{-| Create a tile map for the game level.
-}
rows3 : List (Array Tile)
rows3 =
    [ generatearow [ 0, 79 ] (List.range 26 30 ++ List.range 65 67 ++ List.range 72 74) (List.range 1 25 ++ List.range 44 48 ++ List.range 62 64 ++ List.range 75 76) [] (List.range 49 56 ++ List.range 68 71) [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 31 32) (List.range 1 2 ++ List.range 6 8 ++ List.range 20 21 ++ List.range 25 30 ++ List.range 44 45 ++ List.range 48 52 ++ List.range 64 74) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [] ([ 1 ] ++ List.range 6 8 ++ List.range 20 21 ++ List.range 30 32 ++ List.range 44 45) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 33 35 ++ List.range 76 78) ([ 20 ] ++ List.range 6 7 ++ List.range 31 32 ++ List.range 44 45) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 36 38 ++ [ 75 ]) (List.range 6 7 ++ [ 20 ] ++ List.range 32 35 ++ List.range 44 45 ++ List.range 76 78) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 39 41 ++ List.range 73 74) (List.range 6 7 ++ List.range 35 38 ++ List.range 44 45 ++ List.range 75 76) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 57 72) (List.range 37 40 ++ List.range 44 45 ++ [ 7 ] ++ List.range 73 75) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 55 56) (List.range 44 45 ++ List.range 57 74) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 43 ] (List.range 44 45) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 42 ] (List.range 43 45) [] [] [] [] [] |> rowFromInts
    ]


{-| Create a tile map for the game level.
-}
rows4 : List (Array Tile)
rows4 =
    [ generatearow [ 0, 79 ] (List.range 14 25 ++ List.range 36 41) (List.range 42 44) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 11 13) (List.range 14 23 ++ List.range 38 43) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [] (List.range 19 21 ++ List.range 40 43) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 1 8) (List.range 19 20 ++ List.range 41 42) [] (List.range 48 55) (List.range 67 74) [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [] (List.range 1 4 ++ List.range 19 20 ++ List.range 41 42 ++ List.range 49 54 ++ List.range 68 73) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 13 18) (List.range 1 2 ++ List.range 19 20 ++ List.range 41 42 ++ List.range 50 53 ++ List.range 69 72) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [] (List.range 17 20 ++ List.range 41 42 ++ List.range 51 52 ++ List.range 70 71) [ 60 ] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] (List.range 10 11) (List.range 19 20 ++ List.range 41 42 ++ List.range 51 52 ++ List.range 70 71) [] [] [] [] [] |> rowFromInts
    , generatearow [ 0, 79 ] [ 9, 21, 40, 50, 53, 69, 72 ] (List.range 10 11 ++ List.range 19 20 ++ List.range 41 42 ++ List.range 51 52 ++ List.range 70 71) [] [] [] [] [] |> rowFromInts
    , generatearow (List.range 0 79) [] [] [] [] (List.range 59 63) [] [] |> rowFromInts
    ]


{-| Generate the test tile map.
-}
testTileMap : Array (Array Tile)
testTileMap =
    Array.fromList (rows1 ++ rows2 ++ rows3 ++ rows4)
