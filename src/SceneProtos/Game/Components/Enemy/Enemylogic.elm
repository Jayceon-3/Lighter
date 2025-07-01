module SceneProtos.Game.Components.Enemy.Enemylogic exposing (..)

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Bullet.Init exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (..)
import SceneProtos.Game.Components.Enemy.Init exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)
import Temperature exposing (Temperature)


distance : ( Float, Float ) -> ( Float, Float ) -> Float
distance ( a, b ) ( c, d ) =
    sqrt ((a - c) * (a - c) + (b - d) * (b - d))


move : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
move ( a, b ) ( c, d ) =
    ( a + c, b + d )



-- these are move changes
-- dead not written
-- Buffer state don't move, therefore not included here
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


advancedmove : Enemy -> Env SceneCommonData UserData -> Enemy
advancedmove enemy env =
    if enemy.time <= env.globalData.sceneStartTime - 1000 then
        { enemy | time = env.globalData.sceneStartTime }

    else
        enemy



{-
   deadmove : Enemy -> State -> Enemy
   deadmove enemy=
       let
           target =
               move state.position (-25 * state.direction , 0 )
           vector =
               move state.position (-Tuple.first enemy.position,-Tuple.second enemy.position)
           movedir =
               atan2 (Tuple.second vector) (Tuple.first vector)
           newenemy =

-}
-- refresh the bullets, including new bullets and moving
-- all enemies will enter this function


refreshbullet : List Enemy -> List EnemyBullet -> Env SceneCommonData UserData -> List EnemyBullet
refreshbullet enemy bullets env =
    let
        temp =
            List.filter (\e -> e.enemytype == Advanced && e.enemystate == Attack && e.time <= env.globalData.sceneStartTime - 1000) enemy

        newbullets =
            List.map (\e -> { position = e.position, direction = e.direction, angle = -pi / 2 + pi * e.direction, attack = 5 }) temp
    in
    bullets ++ newbullets


movebullet : List EnemyBullet -> State -> List EnemyBullet
movebullet bullets state =
    let
        temp =
            List.map (\b -> { b | position = move ( 2 * cos b.direction, 2 * sin b.direction ) }) bullets

        newbullets =
            List.filter (\b -> distance state.position b.position > 5) temp
    in
    newbullets



--这里还要判定一下state change


judgeactivate : Enemy -> State -> Bool
judgeactivate enemy state =
    abs (Tuple.first enemy.position - Tuple.first state.position) < 75 && abs (Tuple.second enemy.position - Tuple.second state.position) < 20



-- the range of effective attack is 40*40
-- the hp bounds are 0, 50, 150


judgestate : Enemy -> Enemy
judgestate enemy =
    if enemy.hp > 0 && enemy.hp <= 50 then
        { enemy | enemytype = Normal }

    else if enemy.hp <= 0 then
        { enemy | enemytype = Dead }

    else
        enemy


statechange : List Enemy -> State -> List Enemy
statechange enemy state =
    List.map (\e -> judgestate (judgeactivate e state)) enemy



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
    List.map (\e -> decreaseblood e bullets) enemys
