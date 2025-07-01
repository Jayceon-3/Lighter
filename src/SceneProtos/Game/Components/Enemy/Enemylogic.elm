module SceneProtos.Game.Components.Enemy.Enemylogic exposing (..)

import SceneProtos.Game.Components.Bullet.Init exposing (..)
import SceneProtos.Game.Components.Enemy.Init exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (..)


distance : ( Float, Float ) -> ( Float, Float ) -> Float
distance ( a, b ) ( c, d ) =
    sqrt ((a - c) * (a - c) + (b - d) * (b - d))


move : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
move ( a, b ) ( c, d ) =
    ( a + c, b + d )


defaultmove : Enemy -> Enemy
defaultmove enemy =
    let
        ( newvx, newangle ) =
            if Tuple.first enemy.position <= Tuple.first enemy.defaultposition - 50 then
                ( 10, 0 )

            else if Tuple.first enemy.position >= Tuple.first enemy.defaultposition + 50 then
                ( -10, pi )

            else
                ( enemy.vx, enemy.angle )
    in
    { enemy | position = move ( newvx, 0 ) enemy.position, vx = newvx, angle = newangle }



--normalmove : Enemy -> Enemy
--normalmove enemy =


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
