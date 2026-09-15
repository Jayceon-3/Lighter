module SceneProtos.Game.Components.Ceo.Ceorender exposing (cameraupdate, ceoToViews)

{-|


# Ceorender

Render the ceo.

@docs cameraupdate, ceoToViews

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import REGL.Common exposing (Camera)
import SceneProtos.Game.Components.Ceo.Init exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| render ceo image
-}
ceoToViews : Float -> InitData -> String
ceoToViews time data =
    if data.bomb.ifon then
        bombview (time - data.bomb.time)

    else if data.bullet.ifon then
        bulletview (time - data.bullet.activatetime)

    else if data.defend.ifon then
        defendview (time - data.defend.activatetime)

    else if data.punch.ifon then
        punchorhit (time - data.punch.time) "3"

    else if data.hit.ifon then
        if time > 6 then
            punchorhit (time - data.hit.activatetime) "4"

        else
            punchorhit time "4"

    else
        String.fromInt (modBy 5 (round (time / 5))) ++ "0"


makeView :
    { prefix : String
    , time : Float
    , range : ( Float, Float )
    , calc1 : Float -> Int
    , calc2 : Float -> Int
    , defaultVal : String
    }
    -> String
makeView config =
    let
        ( low, high ) =
            config.range
    in
    if config.time < low then
        config.prefix ++ String.fromInt (config.calc1 config.time)

    else if config.time > high then
        config.prefix ++ String.fromInt (config.calc2 config.time)

    else
        config.defaultVal



-- need the env time minus the activated time
-- can be used for both bomb and bullet, bomb input "0", bullet input ""


bombview : Float -> String
bombview time =
    makeView
        { range = ( 0.5, 4.5 )
        , calc2 = \t -> floor ((5 - t) / 0.1)
        , calc1 = \t -> floor (t / 0.1)
        , defaultVal = "04"
        , time = time
        , prefix = "0"
        }


bulletview : Float -> String
bulletview time =
    makeView
        { prefix = "1"
        , time = time
        , range = ( 0.5, 4.5 )
        , calc1 = \t -> modBy 5 (floor ((t + 0.1) / 0.1))
        , calc2 = \t -> modBy 5 (floor ((4.9 - t) / 0.1))
        , defaultVal = "13"
        }


defendview : Float -> String
defendview time =
    makeView
        { calc1 = \t -> modBy 5 (floor ((t + 0.2) / 0.1))
        , calc2 = \t -> modBy 5 (floor ((3 - t + 0.2) / 0.1))
        , defaultVal = "21"
        , prefix = "2"
        , time = time
        , range = ( 0.4, 2.6 )
        }



-- the following two will wll be done in 2 seconds
-- 3 for punch and 4 for hit


punchorhit : Float -> String -> String
punchorhit time string =
    let
        remain =
            time - toFloat (floor (time / 2))
    in
    if remain < 1 then
        let
            resolv =
                modBy 5 (floor (time / 0.2))
        in
        string ++ String.fromInt resolv

    else if remain > 1 then
        let
            return =
                modBy 5 (floor ((2 - time) / 0.2))
        in
        string ++ String.fromInt return

    else
        string ++ "4"


{-| the vibration effect
-}
cameraupdate : Camera -> Env SceneCommonData UserData -> Float -> Camera
cameraupdate camera env dt =
    let
        oldx =
            camera.x

        oldy =
            camera.y

        oldrotation =
            camera.rotation

        temptime =
            env.globalData.sceneStartTime / 1000

        time =
            temptime - temptime / 20 * 20 - 10

        movex =
            time / 10 * dt / 100

        movey =
            if time > 0 then
                4 * dt

            else
                -4 * dt

        newx =
            960 + movex

        newy =
            600 + movey

        rotate =
            oldrotation + 0.1 * dt / 1000

        newcamera =
            { camera | x = newx, y = newy }
    in
    newcamera
