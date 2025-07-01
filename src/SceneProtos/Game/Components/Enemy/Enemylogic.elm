module SceneProtos.Game.Components.Enemy.Enemylogic exposing (..)

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Bullet.Init exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (..)
import SceneProtos.Game.Components.Enemy.Init exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


distance : ( Float, Float ) -> ( Float, Float ) -> Float
distance ( a, b ) ( c, d ) =
    sqrt ((a - c) * (a - c) + (b - d) * (b - d))


move : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
move ( a, b ) ( c, d ) =
    ( a + c, b + d )



-- these are move changes
-- when enemy is in default mode


defaultmove : Enemy -> Enemy
defaultmove enemy =
    let
        ( newdir, newangle ) =
            if Tuple.first enemy.position <= Tuple.first enemy.defaultposition - 50 then
                ( 1, 0 )

            else if Tuple.first enemy.position >= Tuple.first enemy.defaultposition + 50 then
                ( -1, pi )

            else
                ( enemy.direction, enemy.angle )
    in
    { enemy | position = move ( enemy.vx * newdir, 0 ) enemy.position, direction = newdir, vx = 2, angle = newangle }



-- when enemy is in normal move


normalmove : Enemy -> State -> Enemy
normalmove enemy state =
    if enemy.enemytype == Normal && enemy.enemystate == Attack then
        let
            newdir =
                (Tuple.first state.position - Tuple.first enemy.position) / abs (Tuple.first state.position - Tuple.first enemy.position)

            newangle =
                if newdir < 0 then
                    pi

                else
                    0

            acceleration =
                newdir * 0.1

            newvx =
                if abs (Tuple.first state.position - Tuple.first enemy.position) < 5 then
                    -enemy.vx

                else
                    enemy.vx + acceleration
        in
        { enemy | position = move ( newvx * newdir, 0 ) enemy.position, direction = newdir, vx = newvx, angle = newangle }

    else
        enemy



-- these are state change judgements
-- refresh the bullets
-- all enemies will enter this function


refreshbullet : Enemy -> List EnemyBullet -> Env SceneCommonData UserData -> ( List Enemy, List EnemyBullet )
refreshbullet enemy bullets env =
    let
        temp =
            List.filter (\e -> e.enemytype == Advanced && e.enemystate == Attack && e.time <= env.globalData.sceneStartTime - 1000) enemy

        newbullets =
            List.map (\e -> { position = e.position, direction = e.direction, angle = -pi / 2 + pi * e.direction, attack = 5 }) temp

        newenemies =
            List.map
                (\e ->
                    if e.enemytype == Advanced && e.enemystate == Attack && e.time <= env.globalData.sceneStartTime - 1000 then
                        { e | time = env.globalData.sceneStartTime }

                    else
                        e
                )
                enemy
    in
    ( newenemies, bullets ++ newbullets )



-- need to refresh both the enemybullet and the enemies


decreaseblood : Enemy -> List Bullet -> Enemy
decreaseblood enemy bullets =
    let
        valid =
            List.filter
                (\b ->
                    distance enemy.position b.position < 10
                )
                bullets

        damage =
            List.foldl (\b acc -> b.attack + acc) 0 valid
    in
    { enemy | hp = enemy.hp - damage }


refreshblood : List Enemy -> List Bullet -> List Enemy
refreshblood enemys bullets =
    let
        tempenemy =
            List.map (\e -> decreaseblood e bullets) enemys
    in
    List.filter (\e -> e.hp > 0) tempenemy
