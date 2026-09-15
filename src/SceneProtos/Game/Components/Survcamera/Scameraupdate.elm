module SceneProtos.Game.Components.Survcamera.Scameraupdate exposing (updatebullet, updatecamera)

{-|


# Survcameraupdate

Handles the update logic for surveillance cameras and their bullets.

@docs updatebullet, updatecamera

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env)
import SceneProtos.Game.Components.Bullet.Init exposing (BulletType(..))
import SceneProtos.Game.Components.DW.DWhelp exposing (Data)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (move)
import SceneProtos.Game.Components.Map.Init exposing (Tile)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.Components.Survcamera.Cbullet exposing (..)
import SceneProtos.Game.Components.Survcamera.Cchangemode exposing (judgeactivate)
import SceneProtos.Game.Components.Survcamera.Init exposing (..)
import SceneProtos.Game.Components.Survcamera.Scamattack exposing (..)
import SceneProtos.Game.Components.Survcamera.Scameralogic exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Update camera bullets - moves existing bullets and cleans up collisions

`data`: Current game data containing cameras and bullets
`env`: Game environment with timing data
`dt`: Delta time since last update

Returns updated game data with:

1.  New bullets spawned from attacking cameras
2.  Existing bullets moved forward
3.  Bullets that hit walls removed

Example:
updatebullet gameData env 0.016
-- Returns updated game state with moved/cleaned bullets

-}
updatebullet : InitData -> Env SceneCommonData UserData -> Float -> InitData
updatebullet data env dt =
    let
        tempdata =
            refreshbullet data env

        bullets =
            tempdata.camerabullets

        tempbullets =
            movebullet bullets dt

        newbullets =
            cleanbullet tempbullets tempdata.tiles

        newdata =
            { tempdata | camerabullets = newbullets }
    in
    newdata


{-| Update camera states and targeting based on player position

`data`: Current game data containing cameras
`player`: Current player state

Returns updated game data where cameras:

1.  Change modes (Default/Attack) based on player detection
2.  Adjust their view angles and bounds to track player
3.  Update their targeting positions

Example:
updatecamera gameData playerState
-- Returns game data with updated camera states

-}
updatecamera : InitData -> State -> InitData
updatecamera data player =
    let
        oldcamera =
            data.survcameras

        tempcamera =
            List.map
                (\c ->
                    let
                        result =
                            if c.isAlive == True then
                                changeonemode c player

                            else
                                c
                    in
                    result
                )
                oldcamera

        newcamera =
            List.map
                (\c ->
                    if c.isAlive == False then
                        c

                    else if c.camerastate == Attack then
                        attackrefresh c player

                    else
                        defaultrefresh c data.dt
                )
                tempcamera

        newdata =
            { data | survcameras = newcamera }
    in
    newdata



-- Internal helper functions (not documented as per requirements)


changedirection : Survcamera -> Survcamera
changedirection camera =
    let
        ( dx, _ ) =
            camera.defaultpoint

        ( ( x1, y1 ), ( x2, y2 ) ) =
            camera.bounds

        angle =
            getangle camera.position (move camera.position ( 1, 0 )) ( x2, y2 )

        newdir =
            if (angle <= pi / 6 || x2 - dx > 179) && camera.direction == 1 then
                -1

            else if (angle >= pi / 2 || dx - x1 > 179) && camera.direction == -1 then
                1

            else
                camera.direction

        angle1 =
            getangle camera.position (move camera.position ( 1, 0 )) ( x1, y1 )

        angle2 =
            getangle camera.position (move camera.position ( 1, 0 )) ( x2, y2 )

        newangle =
            (angle1 + angle2) / 2

        newcamera =
            { camera | direction = newdir, angle = newangle }
    in
    newcamera


defaultrefresh : Survcamera -> Float -> Survcamera
defaultrefresh camera dt =
    let
        ( _, p2 ) =
            camera.bounds

        ( newbound1, tempbound2 ) =
            let
                bound2 =
                    moveone p2 camera.tiles camera.direction dt

                bound1 =
                    getonebound camera.position bound2 (pi / 3) camera.tiles
            in
            ( bound1, bound2 )

        newbound2 =
            let
                bound2 =
                    boundpoint camera.position tempbound2 camera.tiles
            in
            bound2

        temppoints =
            addpoints ( newbound1, newbound2 ) camera.tilebound

        newbounds =
            [ newbound2, camera.position, newbound1 ] ++ temppoints

        tempcamera =
            { camera | bounds = ( newbound1, newbound2 ), drawpoints = newbounds }

        newcamera =
            changedirection tempcamera
    in
    newcamera


attackrefresh : Survcamera -> State -> Survcamera
attackrefresh camera player =
    let
        ( newdirection, newangle, ( newbound1, newbound2 ) ) =
            playerbounds camera.position camera.bounds camera.defaultpoint player camera.tiles

        tempcamera =
            { camera | direction = newdirection, angle = newangle, bounds = ( newbound1, newbound2 ) }

        newpoints =
            addpoints tempcamera.bounds camera.tilebound

        newcamera =
            { tempcamera | drawpoints = [ newbound2, camera.position, newbound1 ] ++ newpoints, target = player.position }
    in
    newcamera


changeonemode : Survcamera -> State -> Survcamera
changeonemode camera player =
    let
        judge =
            judgeactivate player.position camera.drawpoints (Tuple.first camera.position) camera.height

        ( newstate, newtarget ) =
            if judge then
                ( Attack, player.position )

            else
                ( Default, player.position )

        newcamera =
            { camera | camerastate = newstate, target = newtarget }
    in
    newcamera


refreshbullet : InitData -> Env SceneCommonData UserData -> InitData
refreshbullet data env =
    let
        ctime =
            env.globalData.sceneStartTime / 1000

        newcamera =
            List.map
                (\c ->
                    if c.isAlive == False then
                        c

                    else if c.camerastate == Attack && ctime - c.time >= 0.8 then
                        { c | time = ctime }

                    else
                        c
                )
                data.survcameras

        newbullets =
            data.survcameras
                |> List.filter (\c -> c.camerastate == Attack && c.isAlive)
                |> List.map (\c -> newcbullet c env)
                |> List.concat

        newdata =
            { data | survcameras = newcamera, camerabullets = data.camerabullets ++ newbullets }
    in
    newdata
