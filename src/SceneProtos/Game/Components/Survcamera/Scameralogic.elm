module SceneProtos.Game.Components.Survcamera.Scameralogic exposing (addpoints, moveone)

{-|


# Scameralogic

Handles core logic for surveillance camera movement and point calculations.

@docs addpoints, moveone

-}

import Dict exposing (Dict)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (move)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..), tile)
import SceneProtos.Game.Components.Survcamera.Init exposing (..)
import SceneProtos.Game.Components.Survcamera.Scamattack exposing (..)


{-| Add relevant wall points between two camera bounds

`bounds`: Tuple of two boundary points ((x1,y1), (x2,y2))
`tiles`: List of all wall points in the scene

Returns filtered list of wall points that fall within the camera's view bounds

-}
addpoints : ( ( Float, Float ), ( Float, Float ) ) -> List ( Float, Float ) -> List ( Float, Float )
addpoints ( ( x1, y1 ), ( x2, y2 ) ) tiles =
    let
        xmin =
            min x1 x2

        xmax =
            max x1 x2

        ymin =
            min y1 y2

        ymax =
            max y1 y2

        newpoints =
            List.filter
                (\( x, y ) ->
                    x >= xmin && x <= xmax && y >= ymin && y <= ymax
                )
                tiles
    in
    newpoints


{-| Move a camera boundary point with wall collision detection

`point`: Current point position (x,y)
`tiles`: List of all tiles in the scene
`direction`: Movement direction (positive for right, negative for left)
`dt`: Delta time since last update

Returns new position after movement, accounting for wall collisions

-}
moveone : ( Float, Float ) -> List ( Int, Int, Tile ) -> Float -> Float -> ( Float, Float )
moveone ( m, n ) tiles direction dt =
    let
        uptiles =
            if direction > 0 then
                getuptiles ( m, n ) True tiles

            else
                getuptiles ( m, n ) False tiles

        downtiles =
            if direction > 0 then
                getdowntiles ( m, n ) True tiles

            else
                getdowntiles ( m, n ) False tiles

        tempuptarget =
            List.head uptiles

        tempdowntarget =
            List.head downtiles

        temp1vx =
            getvx ( m, n ) tempuptarget -1 direction

        temp2vx =
            getvx ( m, n ) tempdowntarget 1 direction

        vxcorrect =
            if tempuptarget == Nothing && tempdowntarget == Nothing then
                0.05 * direction

            else
                0

        vx =
            temp1vx + temp2vx + vxcorrect

        temp1vy =
            getvy ( m, n ) tempuptarget -1 direction

        temp2vy =
            getvy ( m, n ) tempdowntarget 1 direction

        vy =
            temp1vy + temp2vy

        newbound =
            move ( m, n ) ( vx * dt, vy * dt )
    in
    newbound



-- Internal helper functions (not documented as per requirements)


tilesDict : List ( Int, Int, Tile ) -> Dict ( Int, Int ) ( Int, Int, Tile )
tilesDict tiles =
    tiles
        |> List.map
            (\( x, y, t ) ->
                let
                    col =
                        round ((toFloat x - 30) / 60)

                    row =
                        round ((toFloat y - 30) / 60)
                in
                ( ( col, row ), ( x, y, t ) )
            )
        |> Dict.fromList


neighbordict : Dict ( Int, Int ) ( Int, Int, Tile ) -> ( Int, Int ) -> Maybe ( Int, Int, Tile )
neighbordict dict ( x, y ) =
    Dict.get ( x, y ) dict


getneighbor : List ( Int, Int, Tile ) -> ( Int, Int ) -> Maybe ( Int, Int, Tile )
getneighbor tiles ( x, y ) =
    let
        dict =
            tilesDict tiles
    in
    neighbordict dict ( x, y )


getwalltiles : ( Float, Float ) -> Bool -> List ( Int, Int, Tile ) -> Int -> List ( Int, Int, Tile )
getwalltiles ( m, n ) isright tiles index =
    List.filter
        (\t ->
            let
                ( x, y, tile ) =
                    changetofloat t

                neighbor =
                    getneighbor tiles ( round ((x - 30) / 60) + indexchange isright * index, round ((y - 30) / 60) )

                tempjudge =
                    structurejudge neighbor tile
            in
            tempjudge
        )
        tiles


getuptiles : ( Float, Float ) -> Bool -> List ( Int, Int, Tile ) -> List ( Int, Int, Tile )
getuptiles ( m, n ) isright tiles =
    let
        midtarget =
            getwalltiles ( m, n ) isright tiles -1

        right =
            if isright then
                1

            else
                -1

        target =
            List.filter
                (\t ->
                    let
                        ( x, y, tile ) =
                            t

                        judge =
                            (tile.kind == SolidTop || tile.kind == SolidMiddle || tile.kind == Frame || tile.kind == FakeBlock) && n < toFloat y + 30 && n >= toFloat y - 30 && m <= toFloat x - right * 30 && toFloat x - right * 30 < m + right * 10
                    in
                    judge
                )
                midtarget
    in
    target


changetofloat : ( Int, Int, Tile ) -> ( Float, Float, Tile )
changetofloat tiles =
    let
        ( tempx, tempy, tile ) =
            tiles

        y =
            toFloat tempy

        x =
            toFloat tempx
    in
    ( x, y, tile )


indexchange : Bool -> Int
indexchange isright =
    if isright then
        1

    else
        -1


structurejudge : Maybe ( Int, Int, Tile ) -> Tile -> Bool
structurejudge neighbor tile =
    case neighbor of
        Nothing ->
            False

        Just ( _, _, targettile ) ->
            (targettile.kind /= SolidTop && targettile.kind /= SolidMiddle && targettile.kind /= Frame && targettile.kind /= FakeBlock) && (tile.kind == SolidTop || tile.kind == SolidMiddle || tile.kind == Frame || tile.kind == FakeBlock)


getdowntiles : ( Float, Float ) -> Bool -> List ( Int, Int, Tile ) -> List ( Int, Int, Tile )
getdowntiles ( m, n ) isright tiles =
    let
        midtarget =
            getwalltiles ( m, n ) isright tiles 1

        target =
            List.filter
                (\t ->
                    let
                        ( x, y, tile ) =
                            changetofloat t

                        judge =
                            if isright then
                                n - y <= 30 && n > y - 30 && m <= x + 30 && x + 30 < m + 0.05

                            else
                                n - y <= 30 && n > y - 30 && m >= x - 30 && x - 30 > m - 0.05
                    in
                    judge
                )
                midtarget
    in
    target


getvx : ( Float, Float ) -> Maybe ( Int, Int, Tile ) -> Float -> Float -> Float
getvx ( m, n ) target state isright =
    case target of
        Nothing ->
            0

        Just ( x, y, tile ) ->
            if toFloat x + 30 * state * isright == m then
                if n == toFloat y + 30 * state then
                    0.05 * isright

                else
                    0

            else
                toFloat x + 30 * state * isright - m


getvy : ( Float, Float ) -> Maybe ( Int, Int, Tile ) -> Float -> Float -> Float
getvy ( m, n ) target state isright =
    case target of
        Just ( x, y, tile ) ->
            if toFloat x + 30 * state * isright /= m then
                0

            else if state == -1 && n - 0.06 < toFloat y - 30 then
                (toFloat y - 30) - n

            else if state == 1 && n + 0.06 > toFloat y + 30 then
                (toFloat y + 30) - n

            else
                0.06 * state

        Nothing ->
            0
