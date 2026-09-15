module SceneProtos.Game.Components.Map.SpecialBlock exposing (getBottomTile, updateKeyBlock, listToArrayTiles)

{-|


# SpecialBlock

Functions to handle special blocks in the map, such as key blocks and their interactions.

@docs getBottomTile, updateKeyBlock, listToArrayTiles

-}

import Array exposing (Array)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..))


{-| Data structure for map component. Copied from model to avoid import loop.
-}
type alias Data =
    { id : Int
    , ty : String
    , tiles : Array (Array Tile)
    , tileWidth : Int
    , tileHeight : Int
    }


getTileAt : Float -> Float -> Data -> Tile
getTileAt x y mapData =
    let
        tileX =
            floor (x / toFloat mapData.tileWidth)

        tileY =
            floor (y / toFloat mapData.tileHeight)
    in
    case Array.get tileY mapData.tiles of
        Just row ->
            case Array.get tileX row of
                Just tile ->
                    tile

                Nothing ->
                    { kind = Empty, solid = False }

        Nothing ->
            { kind = Empty, solid = False }


{-| Get the tile at the bottom of the given position.
-}
getBottomTile : Float -> Float -> Float -> Float -> Data -> Maybe Tile
getBottomTile x y w h mapData =
    let
        bottomY =
            y + h / 2

        list =
            [ 0, 1, 2, 3, 4 ]

        samplePoints =
            List.map (\i -> x - w / 2 + w * i / 4) list
                |> List.map (\sampleX -> ( sampleX, bottomY + 1 ))

        tile =
            samplePoints
                |> List.map (\( xx, yy ) -> getTileAt xx yy mapData)
                |> List.filter (\{ kind, solid } -> kind /= Empty)
                |> List.head
    in
    tile


judgeKeyBlock : ( Int, Int, Tile ) -> ( Float, Float ) -> Bool
judgeKeyBlock tileinfo pos =
    let
        ( x, y ) =
            pos

        ( x1, y1, tile ) =
            tileinfo

        judge =
            tile.kind
                == KeyBlock
                && abs (x - toFloat x1)
                <= 50
                && abs (y - toFloat y1)
                <= 70
    in
    judge


{-| Update the key block tile in the map based on the player's position.
-}
updateKeyBlock : List ( Int, Int, Tile ) -> ( Float, Float ) -> List ( Int, Int, Tile )
updateKeyBlock tiles pos =
    let
        keyTile =
            List.filter (\t -> judgeKeyBlock t pos) tiles
                |> List.head

        newKeyTile ( x, y, _ ) =
            ( x, y, { kind = KeyBlock, solid = False } )

        updatedTiles =
            case keyTile of
                Just t ->
                    List.map
                        (\tile ->
                            if tile == t then
                                newKeyTile t

                            else
                                tile
                        )
                        tiles

                Nothing ->
                    tiles
    in
    updatedTiles


emptyTile : Tile
emptyTile =
    { kind = Empty
    , solid = False
    }


{-| Convert a list of tiles to a 2D array representation.
-}
listToArrayTiles : List ( Int, Int, Tile ) -> ( ( Int, Int ), Array (Array Tile) )
listToArrayTiles list =
    let
        -- solidTiles =
        --     List.filter (\( _, _, tile ) -> tile.solid) list
        ( maxRow, maxCol ) =
            List.foldl
                (\( x, y, _ ) ( maxR, maxC ) ->
                    ( max (y // 60) maxR, max (x // 60) maxC )
                )
                ( 0, 0 )
                list

        emptyArray =
            Array.initialize (maxRow + 1) (\_ -> Array.initialize (maxCol + 1) (\_ -> emptyTile))

        filledArray =
            List.foldl
                (\( x, y, tile ) acc ->
                    let
                        row =
                            y // 60

                        col =
                            x // 60
                    in
                    case Array.get row acc of
                        Just rowArray ->
                            let
                                newRowArray =
                                    Array.set col tile rowArray
                            in
                            Array.set row newRowArray acc

                        Nothing ->
                            acc
                )
                emptyArray
                list
    in
    ( ( maxRow, maxCol ), filledArray )
