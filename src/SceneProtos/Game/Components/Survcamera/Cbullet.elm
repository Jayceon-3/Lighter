module SceneProtos.Game.Components.Survcamera.Cbullet exposing (cleanbullet, judgeLaser, movebullet, newcbullet, updateblood)

{-|


# Cbullet

Functions for arranging survcamera bullets

@docs cleanbullet, judgeLaser, movebullet, newcbullet, updateblood

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env)
import SceneProtos.Game.Components.Bullet.Init exposing (SingleBullet)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance, move)
import SceneProtos.Game.Components.Map.Init exposing (Tile)
import SceneProtos.Game.Components.Survcamera.Init exposing (..)
import SceneProtos.Game.Components.Survcamera.Scamattack exposing (getangle)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)



--only the Attack mode cameras will enter this function


{-| add new survcamera bullets
-}
newcbullet : Survcamera -> Env SceneCommonData UserData -> List CameraBullet
newcbullet camera env =
    let
        time =
            env.globalData.sceneStartTime / 1000

        newdir =
            getangle camera.position (move camera.position ( 1, 0 )) camera.target
    in
    if time - camera.time >= 0.8 then
        let
            newbullet =
                { position = camera.position
                , direction = newdir
                , attack = 10
                }
        in
        [ newbullet ]

    else
        []


{-| move the survcamera bullets
-}
movebullet : List CameraBullet -> Float -> List CameraBullet
movebullet bullets dt =
    List.map
        (\b ->
            let
                newposition =
                    move b.position ( 0.5 * cos b.direction * dt, 0.5 * sin b.direction * dt )

                newbullet =
                    { b | position = newposition }
            in
            newbullet
        )
        bullets


judgebullettile : CameraBullet -> ( Int, Int, Tile ) -> Bool
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


{-| clean the survcamera bullets
-}
cleanbullet : List CameraBullet -> List ( Int, Int, Tile ) -> List CameraBullet
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


{-| decrease player bullet attack to survcameras
-}
decreaseblood : Survcamera -> List SingleBullet -> Survcamera
decreaseblood camera bullets =
    let
        ( m, n ) =
            camera.position

        valid =
            List.filter
                (\b ->
                    let
                        ( x, y ) =
                            b.position

                        judge =
                            abs (x - m) <= 5 && abs (y - n) <= 10
                    in
                    judge
                )
                bullets

        damage =
            List.foldl (\b acc -> b.attack + acc) 0 valid

        tempcamera =
            { camera | hp = camera.hp - damage }

        newcamera =
            if tempcamera.hp <= 0 then
                { tempcamera | isAlive = False, camerastate = Default }

            else
                tempcamera
    in
    newcamera


{-| update all the camera blood
-}
updateblood : List Survcamera -> List SingleBullet -> ( List Survcamera, List SingleBullet )
updateblood camera bullets =
    let
        newbullet =
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

                                    judge =
                                        abs (x - m) <= 5 && abs (y - n) <= 10
                                in
                                judge
                            )
                            camera
                        )
                )
                bullets

        newcamera =
            List.map (\e -> decreaseblood e bullets) camera
    in
    ( newcamera, newbullet )


laserDecreaseBlood : Survcamera -> Survcamera
laserDecreaseBlood camera =
    let
        damage =
            1
    in
    { camera | hp = camera.hp - damage }


pointInRect : ( Float, Float ) -> SingleBullet -> Bool
pointInRect ( px, py ) bullet =
    let
        ( cx, cy ) =
            bullet.position

        dx =
            px - cx

        dy =
            py - cy

        a =
            bullet.angle

        cosA =
            cos a

        sinA =
            sin a

        localX =
            dx * cosA + dy * sinA

        localY =
            -dx * sinA + dy * cosA

        ( w, h ) =
            bullet.shape

        halfW =
            w / 2

        halfH =
            h / 2
    in
    abs localX <= halfW && abs localY <= halfH


{-| judge laser attack to survcameras
-}
judgeLaser : ( SingleBullet, Bool ) -> List Survcamera -> List Survcamera
judgeLaser laserMsg camera =
    let
        laser =
            Tuple.first laserMsg

        isHit c =
            let
                ( a, b ) =
                    c.position
            in
            pointInRect ( a, b ) laser

        hitCamera =
            camera
                |> List.filter isHit
                |> List.map (\c -> laserDecreaseBlood c)

        nonHitCamera =
            camera
                |> List.filter (not << isHit)

        tempcamera =
            hitCamera ++ nonHitCamera

        newcamera =
            if Tuple.second laserMsg then
                List.map
                    (\c ->
                        if c.hp <= 0 then
                            { c | isAlive = False }

                        else
                            c
                    )
                    tempcamera

            else
                camera
    in
    newcamera
