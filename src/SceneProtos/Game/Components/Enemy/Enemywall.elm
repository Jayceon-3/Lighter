module SceneProtos.Game.Components.Enemy.Enemywall exposing (correctallspeed)

{-|


# Enemywall

Handles enemy collision detection and movement correction with walls and shields.

@docs correctallspeed

-}

import Json.Decode exposing (list)
import SceneProtos.Game.Components.Enemy.EnemyWallHelp exposing (judgeemptytiles)
import SceneProtos.Game.Components.Enemy.Init exposing (..)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..), tile)
import Scenes.Level1.Getbound exposing (tiles)


onewalloneenemy : Enemy -> ( Int, Int, Tile ) -> Float -> ( Float, Float )
onewalloneenemy enemy tileinfo dt =
    let
        ( x, y ) =
            enemy.position

        ( tempm, tempn, _ ) =
            tileinfo

        m =
            toFloat tempm

        n =
            toFloat tempn

        ( newx, newy ) =
            if abs (n - (y + enemy.vy * dt)) < 60 && abs (m - x) < 45 then
                ( enemy.vx, 0 )

            else if abs (n - y) < 60 && abs (m - (x + enemy.vx * enemy.direction * dt)) < 45 then
                let
                    tempvx =
                        if enemy.enemytype == Advanced && enemy.enemystate == Attack then
                            (abs (abs (m - x) - 45) * -1) / dt

                        else
                            abs (abs (m - x) - 45) / dt
                in
                ( tempvx, enemy.vy )

            else
                let
                    distancex =
                        abs (30 - abs (x + enemy.vx))

                    distancey =
                        abs (30 - abs (y + enemy.vy))
                in
                if distancey / distancex - abs (enemy.vy / enemy.vx) > 0 then
                    ( 0, enemy.vy )

                else
                    ( enemy.vx, 0 )
    in
    ( newx, newy )


correctenemy : Enemy -> List ( Int, Int, Tile ) -> Float -> Enemy
correctenemy enemy tileinfo dt =
    if List.isEmpty tileinfo then
        enemy

    else
        let
            ( x, y ) =
                enemy.position

            vlist =
                List.map
                    (\t ->
                        onewalloneenemy enemy t dt
                    )
                    tileinfo

            ( vxlist, vylist ) =
                List.unzip vlist

            newvx =
                Maybe.withDefault 0 (List.minimum vxlist)

            newvy =
                Maybe.withDefault 0 (List.minimum vylist)

            newenemy =
                { enemy | vx = newvx, vy = newvy }
        in
        newenemy


getemptytarget : List ( Int, Int, Tile ) -> Enemy -> Float -> List ( Int, Int, Tile )
getemptytarget tiles enemy dt =
    let
        ( x, y ) =
            enemy.position

        temptiles =
            List.filter
                (\t ->
                    let
                        ( m, n, tiletype ) =
                            t

                        judge =
                            (tiletype.kind /= SolidTop && tiletype.kind /= SolidMiddle && tiletype.kind /= Frame) && abs (toFloat m - (x + enemy.vx * enemy.direction * dt)) <= 45 && toFloat n > y - 30 && toFloat n < y + 90
                    in
                    judge
                )
                tiles

        empty =
            List.filter
                (\t ->
                    judgeemptytiles t temptiles
                )
                temptiles
    in
    empty


getvalidtarget : Enemy -> List ( Int, Int, Tile ) -> List ( Int, Int, Tile )
getvalidtarget enemy tiles =
    let
        ( x, y ) =
            enemy.position

        valid =
            List.filter
                (\t ->
                    let
                        ( tempm, tempn, _ ) =
                            t

                        m =
                            toFloat tempm

                        n =
                            toFloat tempn

                        judge =
                            n >= y - 30 && n <= y + 90 && abs (m - x) <= 600
                    in
                    judge
                )
                tiles
    in
    valid


judgement : TileKind -> Bool
judgement kind =
    kind == SolidTop || kind == SolidMiddle || kind == Frame


onewallspeed : Enemy -> List ( Int, Int, Tile ) -> Float -> Enemy
onewallspeed enemy tiles dt =
    let
        remain =
            getvalidtarget enemy tiles

        ( m, n ) =
            enemy.position

        targettiles1 =
            List.filter
                (\t ->
                    let
                        ( x, y, tiletype ) =
                            t

                        judge =
                            judgement tiletype.kind && abs (toFloat x - (m + enemy.vx * enemy.direction * dt)) < 45 && abs (toFloat y - (n + enemy.vy * dt)) < 60
                    in
                    judge
                )
                remain

        targettiles2 =
            getemptytarget remain enemy dt

        tempenemy =
            correctenemy enemy (targettiles1 ++ targettiles2) dt
    in
    tempenemy


{-| Correct speeds for all enemies based on walls and shields

`enemy`: List of all enemies.
`dt`: Delta time since last update.
`player`: Player position (x,y) for distance check.

Returns list of enemies with corrected velocities.

-}
correctallspeed : List Enemy -> Float -> ( Float, Float ) -> List Enemy
correctallspeed enemy dt player =
    let
        ( m, n ) =
            player

        newenemy =
            List.map
                (\e ->
                    let
                        ( x, y ) =
                            e.position

                        newe =
                            if abs (m - x) > 1100 || abs (n - y) >= 700 then
                                e

                            else
                                onewallspeed e e.tiles dt
                    in
                    newe
                )
                enemy
    in
    newenemy


oneenemyshield : Enemy -> ( Float, Float ) -> Enemy
oneenemyshield enemy shield =
    let
        ( m, n ) =
            shield

        ( x, y ) =
            enemy.position

        newdir =
            if abs (y - n) > 20 then
                enemy.direction

            else if (enemy.direction < 0 && x < m + 30) || (enemy.direction > 0 && x > m - 30) then
                -enemy.direction

            else
                enemy.direction

        newenemy =
            { enemy | direction = newdir }
    in
    newenemy


correctshield : ( Float, Float ) -> List Enemy -> List Enemy
correctshield shield enemy =
    let
        ( x, y ) =
            shield

        newenemy =
            List.map
                (\e ->
                    let
                        ( m, n ) =
                            e.position

                        judge =
                            abs (y - n) <= 20 && abs (x - m) < 70

                        newe =
                            if judge then
                                oneenemyshield e shield

                            else
                                e
                    in
                    newe
                )
                enemy
    in
    newenemy
