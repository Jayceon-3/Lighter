module SceneProtos.Game.Components.Boss.Bosslaser exposing (subaddlaser1, subaddlaser2, subaddlaser3, subaddlaser4, subaddlaser5, subaddlaserl)

{-|


# Bosslaser

The functions for boss laser for the game.

@docs subaddlaser1, subaddlaser2, subaddlaser3, subaddlaser4, subaddlaser5, subaddlaserl

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Boss.Bosslogic exposing (..)
import SceneProtos.Game.Components.Boss.Init exposing (..)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance, move)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)



-- graph1 (0,600) (1920,480) (0,5) (0,5) (0,0) (1920,-120)
-- graph1 (0,720) (1920,600) (0,5) (0,5) (0,0) (1920,-120)
-- graph2 (0,480) (1920,600) (0,-5) (0,-5) (0,1080) (1920,1200)
-- graph2 (0,600) (1920,720) (0,-5) (0,-5) (0,1080) (1920,1200)
-- graph3 (960,0) (960,1080) (-8,0) (-8,0) (0,0) (0,1080)
-- graph3 (960,0) (960,1080) (8,0) (8,0) (1920,0) (1920,1080)
-- graph8 (0,0) (0,1080) (8,0) (8,0) (960,0) (960,1080)
-- graph8 (0,0) (0,1080) (6,0) (6,0) (960,0) (960,1080)
-- graph8 (1920,0) (1920,1080) (-8,0) (-8,0) (960,0) (960,1080)
-- graph8 (1920,0) (1920,1080) (-6,0) (-6,0) (960,0) (960,1080)
-- graph9 (0,0) (1920,0) (0,7) (0,7) (0,1100) (1920,1100)
-- graph13 (-800,600) (800,-600) (8,4.5) (8,4.5) (1120,1680) (2720,480)
-- graph13 (1120,1680) (2720,480) (-8,-4.5) (-8,-4.5) (-800,600) (800,-600)
-- graph13 (-800,480) (800,1680) (8,-4.5) (8,-4.5) (1120,-600) (2720,600)
-- graph13 (1120,-600) (2720,600) (8,-4.5) (8,-4.5) (-800,480) (800,1680)
-- graph14 (0,1080) (1920,1380) (0,-4) (0,-4) (0,-300) (1920,0)
-- graph14 (0,1680) (1920,1380) (0,-4) (0,-4) (0,0) (1920,-300)
-- graph14 (0,1680) (1920,1980) (0,-4) (0,-4) (0,-300) (1920,0)
-- graph14 (0,2280) (1920,1980) (0,-4) (0,-4) (0,0) (1920,-300)


{-| Generates a laser line with specified parameters.
-}
linegenerate1 : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> Elaser
linegenerate1 sp1 sp2 newv1 newv2 p1 p2 =
    let
        line =
            { points = ( sp1, sp2 )
            , v1 = newv1
            , v2 = newv2
            , acceleration1 = ( 0, 0 )
            , acceleration2 = ( 0, 0 )
            , whetherrotate = False
            , rotatepoint = ( 0, 0 )
            , rotate = 0
            , accelerationr = 0
            , endposition = ( p1, p2 )
            , turned = 0
            , targetangle = 0
            , attack = 10
            , atoms = []
            }
    in
    line



-- 2130 for the first least length
-- 2210 for the second least length
-- 1200 for the half second length
-- graph4 (-210,900) (1920, 900) (1920,900) 2 0 (1920,-1230) (1920, 900)
-- graph4 (0,900) (2130, 900) (0,900) -2 0 (0,900) (0, -1230)
-- graph5 (0,0) (2130,0) (0,0) 3 0 (0,0) (0,-2130)
-- graph5 (0,0) (2130,0) (0,0) 2 0 (0,0) (0,-2130)
-- graph5 (1920,0) (-210,0) (1920,0) -3 0 (1920,0) (1920,2130)
-- graph5 (1920,0) (-210,0) (1920,0) -2 0 (1920,0) (1920,2130)
-- graph6 (0,0) (1326,1768) (0,0) 3 0 (0,0) (0,-2210)
-- graph6 (0,0) (1326,1768) (0,0) -3 0 (0,0) (2210,0)
-- graph6 (1920,0) (594,1768) (1920,0) 3 0 (1920,0) (-290,0)
-- graph6 (1920,0) (594,1768) (1920,0) -3 0 (1920,0) (1920,2210)
-- graph7 (960,0) (960,-1450) (960,0) 3 0 (960,0) (-490,0)
-- graph7 (960,0) (960,-1450) (960,0) 2 0 (960,0) (-490,0)
-- graph7 (960,0) (960,-1450) (960,0) -3 0 (960,0) (2410,0)
-- graph7 (960,0) (960,-1450) (960,0) -2 0 (960,0) (2410,0)
-- graph10 (-145,540) (2065,540) (960,540) -1 -0.1 (2065,540) (-145,540)
-- graph11 (960,540) (2160,540) (960,540) 8 0 (960,540) (960 + 1200 * cos 352,540 + 1200 * sin 352)
-- graph11 (960,540) (2160,540) (960,540) -8 0 (960,540) (960 + 1200 * cos 352,540 + 1200 * sin 352)
-- keep generating
-- graph12 (-540,400) (2460,400) (960,300) 8 0 (2460,200) (-540,200)
-- graph12 (2460,400) (-540,400) (960,300) 8 0 (-540,200) (2460,200)
-- both at the same time


{-| Generates a laser line with specified parameters.
-}
linegenerate2 : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> Float -> Float -> ( Float, Float ) -> ( Float, Float ) -> Float -> Elaser
linegenerate2 p0 p1 p2 r ar ep1 ep2 angle =
    let
        line =
            { attack = 10
            , targetangle = angle
            , turned = 0
            , endposition = ( ep1, ep2 )
            , accelerationr = ar
            , rotate = r
            , rotatepoint = p2
            , whetherrotate = True
            , acceleration2 = ( 0, 0 )
            , acceleration1 = ( 0, 0 )
            , v2 = ( 0, 0 )
            , v1 = ( 0, 0 )
            , points = ( p0, p1 )
            , atoms = []
            }
    in
    line


{-| Adds a laser line based on the time and delta.
-}
subaddlaser1 : Float -> Float -> List Elaser
subaddlaser1 time delta =
    if judgetime time 0 delta || judgetime time 4 delta then
        [ linegenerate1 ( 0, 600 ) ( 1920, 480 ) ( 0, 5 ) ( 0, 5 ) ( 0, 0 ) ( 1920, -120 ), linegenerate1 ( 0, 720 ) ( 1920, 600 ) ( 0, 5 ) ( 0, 5 ) ( 0, 0 ) ( 1920, -120 ) ]

    else if judgetime time 2 delta || judgetime time 6 delta then
        [ linegenerate1 ( 0, 480 ) ( 1920, 600 ) ( 0, -5 ) ( 0, -5 ) ( 0, 1080 ) ( 1920, 1200 ), linegenerate1 ( 0, 600 ) ( 1920, 720 ) ( 0, -5 ) ( 0, -5 ) ( 0, 1080 ) ( 1920, 1200 ) ]

    else
        []


{-| Adds a laser line based on the time and delta.
-}
subaddlaser2 : Float -> Float -> List Elaser
subaddlaser2 time delta =
    if judgetime time 14 delta then
        [ linegenerate1 ( 960, 0 ) ( 960, 1080 ) ( -8, 0 ) ( -8, 0 ) ( 0, 0 ) ( 0, 1080 ), linegenerate1 ( 960, 0 ) ( 960, 1080 ) ( 8, 0 ) ( 8, 0 ) ( 1920, 0 ) ( 1920, 1080 ), linegenerate2 ( -210, 900 ) ( 1920, 900 ) ( 1920, 900 ) 0.01 0 ( 1920, -1230 ) ( 1920, 900 ) (pi / 2) ]

    else if judgetime time 10 delta || judgetime time 11 delta || judgetime time 12 delta || judgetime time 13 delta then
        [ linegenerate2 ( -210, 900 ) ( 1920, 900 ) ( 1920, 900 ) 0.01 0 ( 1920, -1230 ) ( 1920, 900 ) (pi / 2) ]

    else
        []


{-| Adds a laser line based on the time and delta.
-}
subaddlaser3 : Float -> Float -> List Elaser
subaddlaser3 time delta =
    if judgetime time 18 delta || judgetime time 19 delta || judgetime time 20 delta || judgetime time 21 delta || judgetime time 22 delta then
        [ linegenerate2 ( 0, 900 ) ( 2130, 900 ) ( 0, 900 ) -0.01 0 ( 0, 900 ) ( 0, -1230 ) (pi / 2) ]

    else if judgetime time 34 delta then
        [ linegenerate2 ( 0, 0 ) ( 1326, 1768 ) ( 0, 0 ) 0.01 0 ( 0, 0 ) ( 0, -2210 ) (pi / 2), linegenerate2 ( 0, 0 ) ( 1326, 1768 ) ( 0, 0 ) -0.01 0 ( 0, 0 ) ( 2210, 0 ) (pi / 2), linegenerate2 ( 1920, 0 ) ( 594, 1768 ) ( 1920, 0 ) 0.01 0 ( 1920, 0 ) ( -290, 0 ) (pi / 2), linegenerate2 ( 1920, 0 ) ( 594, 1768 ) ( 1920, 0 ) -0.01 0 ( 1920, 0 ) ( 1920, 2210 ) (pi / 2) ]

    else
        []


{-| Adds a laser line based on the time and delta.
-}
subaddlaser4 : Float -> Float -> List Elaser
subaddlaser4 time delta =
    if judgetime time 37 delta then
        [ linegenerate2 ( 960, 0 ) ( 960, 1450 ) ( 960, 0 ) 0.01 0 ( 960, 0 ) ( -490, 0 ) (pi / 2), linegenerate2 ( 960, 0 ) ( 960, 1450 ) ( 960, 0 ) 0.005 0 ( 960, 0 ) ( -490, 0 ) (pi / 2), linegenerate2 ( 960, 0 ) ( 960, 1450 ) ( 960, 0 ) -0.01 0 ( 960, 0 ) ( 2410, 0 ) (pi / 2), linegenerate2 ( 960, 0 ) ( 960, 1450 ) ( 960, 0 ) -0.005 0 ( 960, 0 ) ( 2410, 0 ) (pi / 2) ]

    else if judgetime time 18 delta then
        [ linegenerate1 ( 0, 0 ) ( 0, 1080 ) ( 8, 0 ) ( 8, 0 ) ( 960, 0 ) ( 960, 1080 ), linegenerate1 ( 0, 0 ) ( 0, 1080 ) ( 6, 0 ) ( 6, 0 ) ( 960, 0 ) ( 960, 1080 ), linegenerate1 ( 1920, 0 ) ( 1920, 1080 ) ( -8, 0 ) ( -8, 0 ) ( 960, 0 ) ( 960, 1080 ), linegenerate1 ( 1920, 0 ) ( 1920, 1080 ) ( -6, 0 ) ( -6, 0 ) ( 960, 0 ) ( 960, 1080 ) ]

    else
        []


{-| Adds a laser line based on the time and delta.
-}
subaddlaser5 : Float -> Float -> List Elaser
subaddlaser5 time delta =
    if judgetime time 26 delta || judgetime time 27 delta || judgetime time 28 delta || judgetime time 29 delta || judgetime time 30 delta then
        if not (judgetime time 26 delta) then
            [ linegenerate1 ( 0, 0 ) ( 1920, 0 ) ( 0, 7 ) ( 0, 7 ) ( 0, 1100 ) ( 1920, 1100 ) ]

        else
            [ linegenerate2 ( -145, 540 ) ( 2065, 540 ) ( 960, 540 ) -0.01 0 ( 2065, 540 ) ( -145, 540 ) (2 * pi), linegenerate1 ( 0, 0 ) ( 1920, 0 ) ( 0, 7 ) ( 0, 7 ) ( 0, 1100 ) ( 1920, 1100 ) ]

    else
        []


{-| Adds all the sub laser lines based on the environment and delta.
-}
subaddlaserl : Env SceneCommonData UserData -> Float -> List Elaser
subaddlaserl env delta =
    let
        time =
            env.globalData.sceneStartTime / 1000

        newlaser1 =
            sublaserl1 time delta

        newlaser2 =
            sublaserl2 time delta

        newlaser3 =
            sublaserl3 time delta

        newlaser =
            newlaser1 ++ newlaser2 ++ newlaser3
    in
    newlaser


{-| Adds the sub laser lines based on the time and delta.
-}
sublaserl1 : Float -> Float -> List Elaser
sublaserl1 time delta =
    if judgetime (time - toFloat (40 * floor (time / 40))) 0 delta || judgetime (time - toFloat (40 * floor (time / 40))) 30 delta then
        [ linegenerate1 ( -800, 600 ) ( 800, -600 ) ( 8, 4.5 ) ( 8, 4.5 ) ( 1120, 1680 ) ( 2720, 480 ), linegenerate1 ( 1120, 1680 ) ( 2720, 480 ) ( -8, -4.5 ) ( -8, -4.5 ) ( -800, 600 ) ( 800, -600 ), linegenerate1 ( -800, 480 ) ( 800, 1680 ) ( 8, -4.5 ) ( 8, -4.5 ) ( 1120, -600 ) ( 2720, 600 ), linegenerate1 ( 1120, -600 ) ( 2720, 600 ) ( -8, 4.5 ) ( -8, 4.5 ) ( -800, 480 ) ( 800, 1680 ) ]

    else if judgetime (time - toFloat (40 * floor (time / 40))) 18 delta || judgetime (time - toFloat (40 * floor (time / 40))) 36 delta then
        [ linegenerate1 ( 0, 1080 ) ( 1920, 1380 ) ( 0, -4 ) ( 0, -4 ) ( 0, -300 ) ( 1920, 0 ), linegenerate1 ( 0, 1680 ) ( 1920, 1380 ) ( 0, -4 ) ( 0, -4 ) ( 0, 0 ) ( 1920, -300 ), linegenerate1 ( 0, 1680 ) ( 1920, 1980 ) ( 0, -4 ) ( 0, -4 ) ( 0, -300 ) ( 1920, 0 ), linegenerate1 ( 0, 2280 ) ( 1920, 1980 ) ( 0, -4 ) ( 0, -4 ) ( 0, 0 ) ( 1920, -300 ) ]

    else
        []


{-| Adds the sub laser lines based on the time and delta.
-}
sublaserl2 : Float -> Float -> List Elaser
sublaserl2 time delta =
    if judgetime (time - toFloat (40 * floor (time / 40))) 22 delta || judgetime (time - toFloat (40 * floor (time / 40))) 23 delta || judgetime (time - toFloat (40 * floor (time / 40))) 24 delta || judgetime (time - toFloat (40 * floor (time / 40))) 25 delta then
        [ linegenerate2 ( -540, 400 ) ( 2460, 400 ) ( 960, 300 ) 0.01 0 ( 2460, 200 ) ( -540, 200 ) (2 * pi) ]

    else if judgetime (time - toFloat (40 * floor (time / 40))) 6 delta || judgetime (time - toFloat (40 * floor (time / 40))) 7 delta || judgetime (time - toFloat (40 * floor (time / 40))) 8 delta then
        [ linegenerate2 ( 960, 540 ) ( 2160, 540 ) ( 960, 540 ) 0.015 0 ( 960, 540 ) ( 960 + 1200 * cos 352, 540 + 1200 * sin 352 ) (2 * pi) ]

    else
        []


{-| Adds the sub laser lines based on the time and delta.
-}
sublaserl3 : Float -> Float -> List Elaser
sublaserl3 time delta =
    if judgetime (time - toFloat (40 * floor (time / 40))) 12 delta || judgetime (time - toFloat (40 * floor (time / 40))) 13 delta || judgetime (time - toFloat (40 * floor (time / 40))) 14 delta then
        [ linegenerate2 ( 960, 540 ) ( 2160, 540 ) ( 960, 540 ) -0.015 0 ( 960, 540 ) ( 960 + 1200 * cos 352, 540 + 1200 * sin 352 ) (2 * pi) ]

    else if judgetime (time - toFloat (40 * floor (time / 40))) 26 delta then
        [ linegenerate2 ( 0, 0 ) ( 2130, 0 ) ( 0, 0 ) 0.01 0 ( 0, 0 ) ( 0, -2130 ) (pi / 2), linegenerate2 ( 0, 0 ) ( 2130, 0 ) ( 0, 0 ) 0.005 0 ( 0, 0 ) ( 0, -2130 ) (pi / 2), linegenerate2 ( 1920, 0 ) ( -210, 0 ) ( 1920, 0 ) -0.01 0 ( 1920, 0 ) ( 1920, 2130 ) (pi / 2), linegenerate2 ( 1920, 0 ) ( -210, 0 ) ( 1920, 0 ) -0.005 0 ( 1920, 0 ) ( 1920, 2130 ) (pi / 2) ]

    else
        []


{-| Checks if the time is within a certain range based on the target and delta.
-}
judgetime : Float -> Float -> Float -> Bool
judgetime time target delta =
    time >= target && time - target < delta
