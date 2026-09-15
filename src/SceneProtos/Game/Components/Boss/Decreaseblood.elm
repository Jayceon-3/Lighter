module SceneProtos.Game.Components.Boss.Decreaseblood exposing (attackplayer, correctplayer, judgeLaser, judgelasers, playerbullet)

{-|


# Decreaseblood

Logic of decreasing blood of the boss.

@docs attackplayer, correctplayer, judgeLaser, judgelasers, playerbullet

-}

import Lib.Resourcehelp exposing (bullets)
import SceneProtos.Game.Components.Boss.Init exposing (..)
import SceneProtos.Game.Components.Bullet.Init exposing (SingleBullet)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance)
import SceneProtos.Game.Components.Player.Init exposing (State)


{-| Handle player bullet collisions with the boss.

Calculates damage based on bullets that hit the boss (within 200px range) and returns:

  - Updated boss data with reduced HP
  - List of bullets that didn't hit the boss

-}
playerbullet : InitData -> List SingleBullet -> ( InitData, List SingleBullet )
playerbullet data bullets =
    let
        ( m, n ) =
            data.position

        remain =
            List.filter
                (\b ->
                    let
                        ( x, y ) =
                            b.position

                        judge =
                            abs (x - m) <= 200 && abs (y - n) <= 200
                    in
                    not judge
                )
                bullets

        olddamage =
            List.foldl (\b acc -> b.attack + acc) 0 bullets

        remaindamage =
            List.foldl (\b acc -> b.attack + acc) 0 remain

        damage =
            olddamage - remaindamage

        newhp =
            data.hp - damage
    in
    ( { data | hp = newhp }, remain )


laserDecreaseBlood : InitData -> InitData
laserDecreaseBlood data =
    let
        damage =
            1
    in
    { data | hp = data.hp - damage }


judgeattack : ( Float, Float ) -> SingleBullet -> Bool
judgeattack ( px, py ) bullet =
    let
        ( m, n ) =
            bullet.position

        angle =
            atan2 (py - n) (px - m)

        dis =
            distance ( px, py ) ( m, n )

        -- is it still the rotate angle? I'm not sure. If it is, it will work.
        judge =
            abs (angle - bullet.angle) <= 1 && dis <= 640
    in
    judge


{-| Update the boss's state after hit by laser.
-}
judgeLaser : ( SingleBullet, Bool ) -> InitData -> InitData
judgeLaser laserMsg data =
    let
        laser =
            Tuple.first laserMsg

        ifon =
            Tuple.second laserMsg

        position =
            data.position

        judge =
            judgeattack position laser

        newdata =
            if judge && ifon then
                laserDecreaseBlood data

            else
                data
    in
    newdata


{-| Corrects player position to stay within game boundaries.
-}
correctplayer : State -> ( Float, Float )
correctplayer state =
    let
        ( x, y ) =
            state.position

        correctx =
            if x <= 0 then
                30

            else if x >= 1920 then
                1890

            else
                x

        correcty =
            if y >= 930 then
                930

            else
                y

        newposition =
            ( correctx, correcty )
    in
    newposition


{-| Handles boss bullet collisions with player.
-}
attackplayer : State -> List BossBullet -> ( List BossBullet, Float )
attackplayer state bullets =
    let
        ( x, y ) =
            state.position

        remain =
            List.filter
                (\b ->
                    let
                        ( m, n ) =
                            b.position

                        judge =
                            abs (x - m) <= 15 && abs (y - n) <= 30
                    in
                    not judge
                )
                bullets

        oldlength =
            List.length bullets

        newlength =
            List.length remain

        attack =
            2 * toFloat (oldlength - newlength)
    in
    ( remain, attack )


onelaserdir : Elaser -> ( Float, Float ) -> Float
onelaserdir laser point =
    let
        ( p1, p2 ) =
            laser.points

        ( x0, y0 ) =
            point

        ( x1, y1 ) =
            p1

        ( x2, y2 ) =
            p2

        b =
            (y2 - y1) / (x2 - x1)

        k =
            y1 - b * x1

        dis1 =
            sqrt (b * b + 1)

        dis2 =
            b * x0 - y0 + k

        dir =
            dis2 / dis1
    in
    dir


judgeonelaser : Elaser -> State -> Bool
judgeonelaser laser state =
    let
        -- the four angles
        cornerOffsets : List ( Float, Float )
        cornerOffsets =
            [ ( -15, -30 ), ( 15, -30 ), ( -15, 30 ), ( 15, 30 ) ]

        -- distance
        values : List Float
        values =
            let
                ( x0, y0 ) =
                    state.position
            in
            cornerOffsets
                |> List.map (\( dx, dy ) -> onelaserdir laser ( x0 + dx, y0 + dy ))

        -- one laser side
        anyPos =
            List.any (\v -> v >= 0) values

        anyNeg =
            List.any (\v -> v <= 0) values

        judge =
            anyPos && anyNeg
    in
    judge


{-| Calculates total laser damage to player from all active lasers.
-}
judgelasers : List Elaser -> State -> Float
judgelasers lasers state =
    let
        attacklist =
            List.map
                (\l ->
                    let
                        judge =
                            judgeonelaser l state

                        value =
                            if judge then
                                0.1

                            else
                                0
                    in
                    value
                )
                lasers

        attack =
            List.sum attacklist
    in
    attack
