module SceneProtos.Game.Components.Boss.Bosslogic exposing (newbullets, removebullets, movebullets, movelaser, refreshlaser, divisibleBy)

{-|


# Bosslogic

The functions for logic of the boss component in the game.

@docs newbullets, removebullets, movebullets, movelaser, refreshlaser, divisibleBy

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Boss.Init exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance, move)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| add new bullets for boss drones
-}
newbullets : List BossBullet -> List Drone -> Env SceneCommonData UserData -> ( List Drone, List BossBullet )
newbullets bullet drone env =
    let
        time =
            env.globalData.sceneStartTime / 100

        newbullet =
            List.map
                (\d ->
                    { position = d.position
                    , direction = d.angle + pi / 16
                    , attack = 10
                    , atoms = []
                    }
                )
                (List.filter (\d -> time - d.lasttime >= 1) drone)

        newdrone =
            List.map
                (\d ->
                    let
                        newd =
                            if time - d.lasttime >= 1 then
                                { d | lasttime = time, angle = d.angle + pi / 8 }

                            else
                                d
                    in
                    newd
                )
                drone
    in
    ( newdrone, bullet ++ newbullet )


{-| Removes bullets that are out of bounds.
-}
removebullets : List BossBullet -> List BossBullet
removebullets bullet =
    List.filter
        (\b ->
            let
                ( x, y ) =
                    b.position

                judge =
                    x >= 0 && x <= 1920 && y >= 0 && y <= 1080
            in
            judge
        )
        bullet


{-| Moves the bullets in the boss component.
-}
movebullets : List BossBullet -> Float -> List BossBullet
movebullets bullet dt =
    List.map
        (\b ->
            { b | position = move b.position ( 0.5 * cos b.direction * dt, 0.5 * sin b.direction * dt ) }
        )
        bullet


{-| Moves a single laser line based on its velocity and rotation.
-}
pointmove : ( Float, Float ) -> ( Float, Float ) -> Float -> ( Float, Float )
pointmove origin accel dt =
    let
        ( x, y ) =
            origin

        ( m, n ) =
            accel

        newpoint =
            ( x + m * dt, y + n * dt )
    in
    newpoint


moveonelaser : Elaser -> Float -> Elaser
moveonelaser l dt =
    let
        ( ( p1x, p1y ), ( p2x, p2y ) ) =
            l.points

        ( x, y ) =
            l.rotatepoint

        -- no acceleration now
        newv1 =
            pointmove l.v1 l.acceleration1 (dt * 500)

        newv2 =
            pointmove l.v2 l.acceleration2 (dt * 500)

        angle1 =
            atan2 (p1y - y) (p1x - x)

        angle2 =
            atan2 (p2y - y) (p2x - x)

        d1 =
            distance ( p1x, p1y ) ( x, y )

        d2 =
            distance ( p2x, p2y ) ( x, y )

        ( tp1, tp2 ) =
            if l.whetherrotate then
                ( move ( x, y ) ( d1 * cos (angle1 + l.rotate * (dt / 20)), d1 * sin (angle1 + l.rotate * (dt / 20)) ), move ( x, y ) ( d2 * cos (angle2 + l.rotate * (dt / 20)), d2 * sin (angle2 + l.rotate * (dt / 20)) ) )

            else
                l.points

        newpoints =
            ( pointmove tp1 l.v1 (dt / 20), pointmove tp2 l.v2 (dt / 20) )

        temp =
            { l | points = newpoints, v1 = newv1, v2 = newv2 }

        result =
            if temp.whetherrotate then
                { temp | turned = temp.turned + l.rotate * (dt / 20) }

            else
                temp
    in
    result


{-| Moves the laser lines in the boss component.
-}
movelaser : List Elaser -> Float -> List Elaser
movelaser laser dt =
    List.map
        (\l ->
            moveonelaser l dt
        )
        laser


{-| Refreshes the laser lines in the boss component.
-}
refreshlaser : List Elaser -> List Elaser
refreshlaser lasers =
    List.filter
        (\l ->
            if l.whetherrotate then
                not (judgerotatelines l)

            else
                not (judgeposition l.points l.endposition)
        )
        lasers


{-| Checks if the number is divisible by a given divisor within a certain delta.
-}
divisibleBy : Float -> Float -> Float -> Bool
divisibleBy x d delta =
    let
        temp1 =
            x / d

        temp2 =
            floor temp1

        result =
            toFloat temp2 * d

        error =
            delta / 2
    in
    abs (x - result) < error


{-| Checks if two positions are close enough based on their coordinates.
-}
judgeposition : ( ( Float, Float ), ( Float, Float ) ) -> ( ( Float, Float ), ( Float, Float ) ) -> Bool
judgeposition p1 p2 =
    let
        ( ( x1, y1 ), ( x2, y2 ) ) =
            p1

        ( ( x3, y3 ), ( x4, y4 ) ) =
            p2

        judge1 =
            distance (move ( x1, y1 ) ( -x3, -y3 )) ( 0, 0 ) < 2

        judge2 =
            distance (move ( x2, y2 ) ( -x4, -y4 )) ( 0, 0 ) < 2

        judge =
            judge1 && judge2
    in
    judge


{-| Checks if the laser lines have reached their target angle based on their rotation.
-}
judgerotatelines : Elaser -> Bool
judgerotatelines laser =
    let
        currentangle =
            laser.turned

        dir =
            if laser.rotate > 0 then
                1

            else
                -1

        target =
            laser.targetangle

        judge =
            currentangle * dir >= target
    in
    judge
