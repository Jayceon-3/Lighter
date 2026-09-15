module SceneProtos.Game.Components.Boss.Bossupdate exposing (updatelaser, updatedrone, updatebullet)

{-|


# Bossupdate

Functions to update the boss component in the game.

@docs updatelaser, updatedrone, updatebullet

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Boss.Bosslaser exposing (..)
import SceneProtos.Game.Components.Boss.Bosslogic exposing (..)
import SceneProtos.Game.Components.Boss.Droneupdate exposing (..)
import SceneProtos.Game.Components.Boss.Init exposing (..)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance, move)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Adds new laser lines to the boss component based on the current time and delta.
-}
addlaser : Env SceneCommonData UserData -> List Elaser -> Float -> List Elaser
addlaser env laser delta =
    --here the input delta is already divided by 1000 in the update function
    let
        time =
            env.globalData.sceneStartTime / 1000 + 30

        newlaser1 =
            subaddlaser1 time delta

        newlaser2 =
            subaddlaser2 time delta

        newlaser3 =
            subaddlaser3 time delta

        newlaser4 =
            subaddlaser4 time delta

        newlaser5 =
            subaddlaser5 time delta

        newlaser6 =
            if time >= 40 then
                subaddlaserl env delta

            else
                []

        newlaser =
            newlaser1 ++ newlaser2 ++ newlaser3 ++ newlaser4 ++ newlaser5 ++ newlaser6
    in
    laser ++ newlaser


{-| Updates the laser lines in the boss component based on the current environment and delta time.
-}
updatelaser : List Elaser -> Env SceneCommonData UserData -> Float -> Float -> List Elaser
updatelaser laser env delta dt =
    let
        temp1 =
            movelaser laser dt

        temp2 =
            refreshlaser temp1

        newlaser =
            addlaser env temp2 delta
    in
    newlaser


{-| Updates the drones in the boss component by refreshing and moving them.
-}
updatedrone : InitData -> Float -> InitData
updatedrone data dt =
    let
        temp =
            refreshdrones data

        result =
            { temp | drone = movedrones temp.drone dt }
    in
    result


{-| Updates the bullets in the boss component by refreshing and moving them.
-}
updatebullet : InitData -> Env SceneCommonData UserData -> Float -> InitData
updatebullet data env dt =
    let
        ( newdrone, newbullet ) =
            newbullets data.bossbullet data.drone env

        temp =
            { data | bossbullet = newbullet, drone = newdrone }

        result =
            { temp | bossbullet = movebullets (removebullets temp.bossbullet) dt }
    in
    result


{-| Checks if the time is within a certain range based on the target and delta.
-}
judgetime : Float -> Float -> Float -> Bool
judgetime time target delta =
    time <= target && target - time < delta


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



-- TODO: add player attacked by bullets or laser
