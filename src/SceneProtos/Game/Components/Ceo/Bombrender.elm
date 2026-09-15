module SceneProtos.Game.Components.Ceo.Bombrender exposing (bombupdate, renderbombs)

{-|


# Bombrender

Render the bomb.

@docs bombupdate, renderbombs

-}

import Color
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import Random
import SceneProtos.Game.Components.Ceo.Init exposing (..)



-- time should be real time


{-| update all the atoms
-}
bombupdate : List Bomb -> Float -> Float -> List Bomb
bombupdate bombs time dt =
    let
        newbomb =
            List.map
                (\b ->
                    let
                        temp1bomb =
                            clearatoms b time dt

                        temp2bomb =
                            moveatoms temp1bomb dt

                        bomb =
                            onebombatom temp2bomb time
                    in
                    bomb
                )
                bombs
    in
    newbomb


{-| render all the atoms
-}
renderbombs : List Bomb -> Renderable
renderbombs bombs =
    group
        []
        (List.map
            (\b ->
                renderabomb b
            )
            bombs
        )


renderabomb : Bomb -> Renderable
renderabomb bomb =
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
                                a.color

                            result =
                                P.rect ( x - 5, y - 5 ) ( 10, 10 ) (Color.rgb m n k)
                        in
                        result
                    )
                    bomb.atoms
                )
    in
    render


moveatoms : Bomb -> Float -> Bomb
moveatoms bomb dt =
    let
        oldatoms =
            bomb.atoms

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

        newbomb =
            { bomb | atoms = newatom }
    in
    newbomb


clearatoms : Bomb -> Float -> Float -> Bomb
clearatoms bomb time dt =
    let
        oldatoms =
            bomb.atoms

        nowatoms =
            List.filter
                (\a ->
                    time - a.releasetime <= a.targettime
                )
                oldatoms

        newbomb =
            { bomb | atoms = nowatoms }
    in
    newbomb


onebombatom : Bomb -> Float -> Bomb
onebombatom bomb time =
    let
        seed =
            newseed time

        ( x, y ) =
            bomb.position

        ( newatom, _ ) =
            Random.step (newatoms ( x, y ) (bomb.radius * 60) 3 (floor (60 * bomb.radius * 10)) time) seed

        newbomb =
            { bomb | atoms = bomb.atoms ++ newatom }
    in
    newbomb


newseed : Float -> Random.Seed
newseed time =
    let
        stamp =
            floor time

        nowseed =
            Random.initialSeed stamp
    in
    nowseed


newatoms : ( Float, Float ) -> Float -> Int -> Int -> Float -> Random.Generator (List Atom)
newatoms position radius color target time =
    Random.list target (oneatom position radius color time)


oneatom : ( Float, Float ) -> Float -> Int -> Float -> Random.Generator Atom
oneatom position radius color time =
    Random.map4 (\x y z k -> { position = x, v = y, color = z, releasetime = time, targettime = k })
        (atomposition position radius)
        atomv
        (atomcolor color)
        atomtime


atomposition : ( Float, Float ) -> Float -> Random.Generator ( Float, Float )
atomposition position radius =
    let
        ( x, y ) =
            position

        result =
            Random.map2 (\a b -> ( x + cos a * b, y + sin a * b ))
                (Random.float -pi pi)
                (Random.float 0 radius)
    in
    result


atomv : Random.Generator ( Float, Float )
atomv =
    Random.map2 (\a b -> ( a, b ))
        (Random.float -20 20)
        (Random.float -20 20)


atomcolor : Int -> Random.Generator ( Float, Float, Float )
atomcolor color =
    let
        ( ( base1, base2, base3 ), ( rang1, rang2, rang3 ) ) =
            case color of
                1 ->
                    ( ( 0.95, 0.4, 0.1 )
                    , ( 0.05, 0.1, 0.1 )
                    )

                2 ->
                    ( ( 0.3, 0.9, 0.95 )
                    , ( 0.1, 0.1, 0.05 )
                    )

                3 ->
                    ( ( 0.6, 0.1, 0.05 )
                    , ( 0.4, 0.1, 0.05 )
                    )

                4 ->
                    ( ( 1.0, 0.1, 0.55 )
                    , ( 0.0, 0.1, 0.15 )
                    )

                _ ->
                    ( ( 0.0, 0.0, 0.0 )
                    , ( 0.0, 0.0, 0.0 )
                    )

        result =
            Random.map3 (\a b c -> ( a, b, c ))
                (Random.float (base1 - rang1) (base1 + rang1))
                (Random.float (base2 - rang2) (base2 + rang2))
                (Random.float (base3 - rang3) (base3 + rang3))
    in
    result


atomtime : Random.Generator Float
atomtime =
    Random.float 0.05 0.1
