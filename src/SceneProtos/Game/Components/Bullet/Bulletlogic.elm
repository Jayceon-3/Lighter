module SceneProtos.Game.Components.Bullet.Bulletlogic exposing (bulletMove, trueCollisionPos, clearCollisionBullet, judgebullettile, cleanbullet)

{-|


# Bulletlogic

This module contains functions for the logic for bullet movement and collision handling in the game.

@docs bulletMove, trueCollisionPos, clearCollisionBullet, judgebullettile, cleanbullet

-}

import SceneProtos.Game.Components.Boss.Bosslogic exposing (newbullets)
import SceneProtos.Game.Components.Bullet.Init as BulletInit exposing (..)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (..)
import SceneProtos.Game.Components.Enemy.Init as EnemyInit exposing (..)
import SceneProtos.Game.Components.Map.Init exposing (Tile)


{-| Moves the bullets based on dt.
-}
bulletMove : Float -> List SingleBullet -> List SingleBullet
bulletMove dt bullets =
    let
        speed =
            1000

        delta_t =
            dt / 1000

        speed2 =
            100

        newBullets =
            List.map
                (\bullet ->
                    { bullet | position = ( Tuple.first bullet.position + speed * (cos bullet.angle * bullet.direction) * delta_t, Tuple.second bullet.position - speed * (sin bullet.angle * bullet.direction) * delta_t ) }
                )
                bullets
    in
    newBullets


{-| Filters the list of collision positions to only include those that are true collisions.
-}
trueCollisionPos : List ( ( Float, Float ), Bool ) -> List ( Float, Float )
trueCollisionPos list =
    let
        collisionList =
            list
                |> List.filter Tuple.second
                |> List.map Tuple.first
    in
    collisionList


{-| Clears the bullets that are close to a given position (x, y).
-}
clearCollisionBullet : List SingleBullet -> ( Float, Float ) -> List SingleBullet
clearCollisionBullet bullets ( x, y ) =
    let
        judge ( x0, y0 ) =
            (abs (x0 - x) <= 0.1) && (abs (y0 - y) <= 0.1)

        newBullets =
            List.filter (\b -> not (judge b.position)) bullets
    in
    newBullets


{-| Checks if a bullet collides with a tile based on its position and the tile's properties.
-}
judgebullettile : SingleBullet -> ( Int, Int, Tile ) -> Bool
judgebullettile bullet tileinfo =
    let
        ( x, y, tile ) =
            tileinfo

        ( m, n ) =
            bullet.position

        judge =
            tile.solid && abs (m - toFloat x) < 30 && abs (n - toFloat y) < 30
    in
    judge


{-| Cleans the bullets by removing those that are close to any tile in the provided tile information.
-}
cleanbullet : List SingleBullet -> List ( Int, Int, Tile ) -> List SingleBullet
cleanbullet bullets tileinfo =
    List.filter
        (\b ->
            let
                judge =
                    not (List.any (\t -> judgebullettile b t) tileinfo)
            in
            judge
        )
        bullets



-- I think this function won't be used as it conflict with other messages and won't have the effect I want.
-- note that this name is very similar with updatebullet but they are different
{-
   updateBullets : List SingleBullet -> List Enemy -> List SingleBullet
   updateBullets bullets enemies =
       List.filter
           (\b ->
               not
                   (List.any
                       (\e ->
                           let
                               ( x, y ) =
                                   b.position

                               ( m, n ) =
                                   e.position
                           in
                           x >= m && x <= m + 30 && y >= n && y <= n + 60
                       )
                       enemies
                   )
           )
           bullets

-}
