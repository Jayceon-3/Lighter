module SceneProtos.Game.Components.Enemy.Enemybulletlogic exposing (judgeLaser, remainbullet, updatebullet)

{-|


# Enemybulletlogic

Handles enemy bullet behavior including creation, movement and collision detection.

@docs judgeLaser, remainbullet, updatebullet

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Bullet.Init exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (..)
import SceneProtos.Game.Components.Enemy.Init exposing (..)
import SceneProtos.Game.Components.Map.Init exposing (Tile)
import SceneProtos.Game.Components.Player.Init exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Check laser collision with enemies and apply damage

`laserMsg`: Tuple containing laser bullet data and activation flag
`enemy`: List of current enemies

Returns updated list of enemies with health decreased for those hit by laser

Example:
judgeLaser (laserBullet, True) enemies
-- Returns enemies with damaged ones

-}
judgeLaser : ( SingleBullet, Bool ) -> List Enemy -> List Enemy
judgeLaser laserMsg enemy =
    let
        laser =
            Tuple.first laserMsg

        ( x, y ) =
            laser.position

        isHit e =
            let
                ( x0, y0 ) =
                    e.position

                ( a, b ) =
                    ( x0 + 15, y0 + 30 )
            in
            (abs (x - a) <= (15 + 300)) && (abs (y - b) <= (30 + 20))

        hitEnemy =
            enemy
                |> List.filter isHit
                |> List.map (\e -> laserDecreaseBlood e)

        nonHitEnemy =
            enemy
                |> List.filter (not << isHit)

        newenemy =
            hitEnemy ++ nonHitEnemy
    in
    if Tuple.second laserMsg then
        newenemy

    else
        enemy


{-| Filter out bullets that have hit the player

`bullets`: List of current enemy bullets
`state`: Player state containing position

Returns list of bullets that haven't hit the player

Example:
remainbullet enemyBullets playerState
-- Returns filtered bullet list

-}
remainbullet : List EnemyBullet -> State -> List EnemyBullet
remainbullet bullets state =
    let
        ( m, n ) =
            state.position

        newbullets =
            List.filter
                (\b ->
                    let
                        ( x, y ) =
                            b.position

                        judge =
                            not (abs (m - x) <= 15 && abs (n - y) <= 30)
                    in
                    judge
                )
                bullets
    in
    newbullets


{-| Full bullet state update

`bullet`: Current enemy bullets
`enemy`: List of enemies that may shoot
`env`: Game environment data
`dt`: Delta time since last update

Returns updated bullet list with:

1.  New bullets from attacking enemies
2.  Existing bullets moved forward

Example:
updatebullet bullets enemies env 0.016
-- Returns updated bullet list

-}
updatebullet : List EnemyBullet -> List Enemy -> Env SceneCommonData UserData -> Float -> List EnemyBullet
updatebullet bullet enemy env dt =
    movebullet (refreshbullet enemy bullet env) dt



-- Internal helper functions (not exposed, no docs needed)


judgebullettile : EnemyBullet -> ( Int, Int, Tile ) -> Bool
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


cleanbullet : List EnemyBullet -> List ( Int, Int, Tile ) -> List EnemyBullet
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


movebullet : List EnemyBullet -> Float -> List EnemyBullet
movebullet bullets dt =
    let
        newbullets =
            List.map (\b -> { b | position = move ( 0.5 * b.direction * dt, 0 ) b.position }) bullets
    in
    newbullets


laserDecreaseBlood : Enemy -> Enemy
laserDecreaseBlood enemy =
    let
        damage =
            5
    in
    { enemy | hp = enemy.hp - damage }


refreshbullet : List Enemy -> List EnemyBullet -> Env SceneCommonData UserData -> List EnemyBullet
refreshbullet enemy bullets env =
    let
        temp =
            List.filter (\e -> e.enemytype == Advanced && e.enemystate == Attack && e.time <= env.globalData.sceneStartTime - 500) enemy

        newbullets =
            List.map (\e -> { position = e.position, direction = e.direction, angle = -pi / 2 + pi * e.direction, attack = 10, appear = e.appear }) temp
    in
    bullets ++ newbullets
