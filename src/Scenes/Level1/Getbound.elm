module Scenes.Level1.Getbound exposing (gettilespoints, initdic, boundpoints, getboundpoints, temptiles, tiles, tilebounds)

{-|


# Getbound

Functions to retrieve boundary points and tiles from the game map.

@docs gettilespoints, initdic, boundpoints, getboundpoints, temptiles, tiles, tilebounds

-}

import Dict exposing (Dict, toList, update)
import SceneProtos.Game.Components.Map.CollisionLogic exposing (getmapinformation)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..))
import Scenes.Level1.MakeMap exposing (..)


{-| Convert a list of tiles into a list of points based on their positions and types.
-}
gettilespoints : List ( Int, Int, Tile ) -> List ( Float, Float )
gettilespoints intiles =
    List.map
        (\t ->
            let
                ( tempx, tempy, tile ) =
                    t

                x =
                    toFloat tempx

                y =
                    toFloat tempy

                newpoints =
                    if tile.kind == SolidTop || tile.kind == SolidMiddle || tile.kind == FakeBlock || tile.kind == KeyBlock || tile.kind == Frame then
                        [ ( x - 30, y - 30 ), ( x + 30, y - 30 ), ( x + 30, y + 30 ), ( x - 30, y + 30 ) ]

                    else
                        []
            in
            newpoints
        )
        intiles
        |> List.concat


{-| Initialize an empty dictionary to store points and their counts.
-}
initdic : Dict ( Float, Float ) Int
initdic =
    Dict.empty


{-| Count the occurrences of each point in the list and filter based on specific conditions.
-}
boundpoints : List ( Float, Float ) -> List ( Float, Float )
boundpoints points =
    points
        |> List.foldl
            (\pt dict ->
                Dict.update pt (\mc -> Just (Maybe.withDefault 0 mc + 1)) dict
            )
            initdic
        |> Dict.toList
        |> List.filter (\( pt, count ) -> count == 1 || count == 3)
        |> List.map Tuple.first


{-| Get the boundary points from a list of tiles by extracting their positions.
-}
getboundpoints : List ( Int, Int, Tile ) -> List ( Float, Float )
getboundpoints tile =
    boundpoints (gettilespoints tile)



-- all tiles


{-| Retrieve all tile information from the map.
-}
temptiles : List ( Int, Int, Tile )
temptiles =
    getmapinformation testTileMap



-- only solid tiles


{-| Filter the tiles to include only those that are solid.
-}
tiles : List ( Int, Int, Tile )
tiles =
    List.filter
        (\t ->
            let
                ( _, _, tile ) =
                    t

                judge =
                    tile.solid || tile.kind == FakeBlock || tile.kind == KeyBlock
            in
            judge
        )
        temptiles


{-| Get the boundary points of solid tiles.
-}
tilebounds : List ( Float, Float )
tilebounds =
    getboundpoints tiles
