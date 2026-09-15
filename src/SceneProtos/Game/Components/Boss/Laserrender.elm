module SceneProtos.Game.Components.Boss.Laserrender exposing (laserupdate)

{-|


# Laserrender

Update and render boss laser.

@docs laserupdate

-}

import Color
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import Random
import SceneProtos.Game.Components.Boss.Init exposing (..)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance)


{-| Update boss laser.
-}
laserupdate : List Elaser -> Float -> Float -> List Elaser
laserupdate laser time dt =
    let
        newlaser =
            List.map
                (\l ->
                    let
                        temp1laser =
                            clearatoms l time

                        temp2laser =
                            moveatoms temp1laser dt

                        newl =
                            onelaseratom temp2laser time
                    in
                    newl
                )
                laser
    in
    newlaser


moveatoms : Elaser -> Float -> Elaser
moveatoms laser dt =
    let
        oldatoms =
            laser.atoms

        newatom =
            List.map
                (\a ->
                    let
                        ( x, y ) =
                            a.position

                        ( m, n ) =
                            a.v

                        newposition =
                            ( x + m * dt, y + n * dt )

                        newa =
                            { a | position = newposition }
                    in
                    newa
                )
                oldatoms

        newlaser =
            { laser | atoms = newatom }
    in
    newlaser


clearatoms : Elaser -> Float -> Elaser
clearatoms laser time =
    let
        oldatoms =
            laser.atoms

        nowatoms =
            List.filter
                (\a ->
                    time - a.releasetime <= a.targettime
                )
                oldatoms

        newlaser =
            { laser | atoms = nowatoms }
    in
    newlaser


onelaseratom : Elaser -> Float -> Elaser
onelaseratom laser time =
    let
        seed =
            newseed time

        ( newatom, _ ) =
            Random.step (newatoms laser 50 time) seed

        newlaser =
            { laser | atoms = laser.atoms ++ newatom }
    in
    newlaser


newseed : Float -> Random.Seed
newseed time =
    let
        stamp =
            floor (time * 1000)

        nowseed =
            Random.initialSeed stamp
    in
    nowseed


newatoms : Elaser -> Int -> Float -> Random.Generator (List Atom)
newatoms laser target time =
    Random.list target (oneatom laser time)


oneatom : Elaser -> Float -> Random.Generator Atom
oneatom laser time =
    Random.map4 (\x y z k -> { position = x, v = y, color = z, releasetime = time, targettime = k })
        (atompos laser.points)
        (if laser.accelerationr == 0 then
            atomvmove laser.v1

         else
            atomvrotate laser.points laser.rotatepoint
        )
        atomcolor
        atomtime


screenWidth : Float
screenWidth =
    1920


screenHeight : Float
screenHeight =
    1080


clampSegmentT :
    Float
    -> Float
    -> Float
    -> Float
    -> ( Float, Float )
clampSegmentT o d low high =
    if d == 0 then
        if o >= low && o <= high then
            ( 0, 1 )

        else
            ( 1, 0 )

    else
        let
            t1 =
                (low - o) / d

            t2 =
                (high - o) / d
        in
        ( min t1 t2, max t1 t2 )


atompos :
    ( ( Float, Float ), ( Float, Float ) )
    -> Random.Generator ( Float, Float )
atompos ( ( x1, y1 ), ( x2, y2 ) ) =
    let
        dx =
            x2 - x1

        dy =
            y2 - y1

        ( txMin, txMax ) =
            clampSegmentT x1 dx 0 screenWidth

        ( tyMin, tyMax ) =
            clampSegmentT y1 dy 0 screenHeight

        tMin =
            max 0 (max txMin tyMin)

        tMax =
            min 1 (min txMax tyMax)

        ( finalMin, finalMax ) =
            if tMax >= tMin then
                ( tMin, tMax )

            else
                ( 0, 0 )

        pos =
            Random.map
                (\t ->
                    ( x1 + t * dx
                    , y1 + t * dy
                    )
                )
                (Random.float finalMin finalMax)
    in
    pos


atomvmove : ( Float, Float ) -> Random.Generator ( Float, Float )
atomvmove ( vx, vy ) =
    let
        baseAngle : Float
        baseAngle =
            atan2 vy vx

        dis =
            sqrt (vy * vy + vx * vx)

        magGen : Random.Generator Float
        magGen =
            Random.float 0.5 1

        angleGen : Random.Generator Float
        angleGen =
            Random.float (baseAngle - pi / 2) (baseAngle + pi / 2)
    in
    Random.map2
        (\angle mag -> ( cos angle * -mag * dis, sin angle * -mag * dis ))
        angleGen
        magGen


atomvrotate : ( ( Float, Float ), ( Float, Float ) ) -> ( Float, Float ) -> Random.Generator ( Float, Float )
atomvrotate points rotate =
    let
        ( ( x1, y1 ), ( x2, y2 ) ) =
            points

        ( x, y ) =
            rotate

        ( p, q ) =
            ( (x1 + x2) / 2, (y1 + y2) / 2 )

        length =
            distance ( p, q ) rotate

        ( vx, vy ) =
            ( (x - p) / length, (y - q) / length )

        speed =
            Random.map (\k -> ( vx * k, vy * k ))
                (Random.float -2 -1)
    in
    speed


atomcolor : Random.Generator Int
atomcolor =
    let
        color =
            Random.int 1 2
    in
    color


atomtime : Random.Generator Float
atomtime =
    Random.float 0.2 0.4
