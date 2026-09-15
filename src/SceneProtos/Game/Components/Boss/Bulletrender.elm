module SceneProtos.Game.Components.Boss.Bulletrender exposing (bulletupdate, renderbullets)

{-|


# Bulletrender

Functions to render the bullet.

@docs bulletupdate, renderbullets

-}

import Color
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import Random
import SceneProtos.Game.Components.Boss.Init exposing (..)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance)


{-| Function to render bullets
-}
renderbullets : List BossBullet -> Float -> Renderable
renderbullets bullets time =
    group
        []
        (List.map
            (\b ->
                renderabullet b time
            )
            bullets
        )


renderabullet : BossBullet -> Float -> Renderable
renderabullet laser time =
    let
        render =
            group
                []
                (List.map
                    (\a ->
                        let
                            ( x, y ) =
                                a.position

                            ( m, n, k ) =
                                colorlist time a

                            result =
                                P.rect ( x - 5, y - 5 ) ( 10, 10 ) (Color.rgb m n k)
                        in
                        result
                    )
                    laser.atoms
                )
    in
    render


colorlist : Float -> Atom -> ( Float, Float, Float )
colorlist time a =
    if time - a.releasetime <= 0.25 * a.targettime then
        ( 0.1, 0.2, 0.5 )

    else if time - a.releasetime <= 0.5 * a.targettime then
        ( 0.2, 0.5, 1.0 )

    else if time - a.releasetime <= 0.75 * a.targettime then
        ( 0.4, 0.8, 1.0 )

    else
        ( 0.7, 0.95, 1.0 )


{-| Function to update bullet.
-}
bulletupdate : List BossBullet -> Float -> Float -> List BossBullet
bulletupdate bullet time dt =
    let
        newbullets =
            List.map
                (\l ->
                    let
                        temp1bullet =
                            clearatoms l time

                        temp2bullet =
                            moveatoms temp1bullet dt

                        newl =
                            onebulletatom temp2bullet time
                    in
                    newl
                )
                bullet
    in
    newbullets


onebulletatom : BossBullet -> Float -> BossBullet
onebulletatom bullet time =
    let
        seed =
            newseed time

        ( newatom, _ ) =
            Random.step (newatoms bullet 5 time) seed

        newbullet =
            { bullet | atoms = bullet.atoms ++ newatom }
    in
    newbullet


newseed : Float -> Random.Seed
newseed time =
    let
        stamp =
            floor time

        nowseed =
            Random.initialSeed stamp
    in
    nowseed


moveatoms : BossBullet -> Float -> BossBullet
moveatoms bullet dt =
    let
        oldatoms =
            bullet.atoms

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
            { bullet | atoms = newatom }
    in
    newlaser


clearatoms : BossBullet -> Float -> BossBullet
clearatoms bullet time =
    let
        oldatoms =
            bullet.atoms

        nowatoms =
            List.filter
                (\a ->
                    time - a.releasetime <= a.targettime
                )
                oldatoms

        newbullet =
            { bullet | atoms = nowatoms }
    in
    newbullet


newatoms : BossBullet -> Int -> Float -> Random.Generator (List Atom)
newatoms bullet target time =
    Random.list target (oneatom bullet time)


oneatom : BossBullet -> Float -> Random.Generator Atom
oneatom bullet time =
    Random.map2 (\x y -> { position = bullet.position, v = x, color = 1, releasetime = time, targettime = y })
        atomv
        atomtime


atomv : Random.Generator ( Float, Float )
atomv =
    Random.map2 (\a b -> ( a, b ))
        (Random.float -20 20)
        (Random.float -20 20)


atomtime : Random.Generator Float
atomtime =
    Random.float 0.5 1
