module SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance, move, moveenemy, updateenemy)

{-|


# Enemylogic

Handles core enemy movement and position calculation logic.

@docs distance, move, moveenemy, updateenemy

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Bullet.Init exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Enemy.Enemystate exposing (..)
import SceneProtos.Game.Components.Enemy.Enemywall exposing (..)
import SceneProtos.Game.Components.Enemy.Init exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Calculate Euclidean distance between two points

`(a,b)`: First point coordinates
`(c,d)`: Second point coordinates

Returns the distance between the points

-}
distance : ( Float, Float ) -> ( Float, Float ) -> Float
distance ( a, b ) ( c, d ) =
    sqrt ((a - c) * (a - c) + (b - d) * (b - d))


{-| Move a point by a given vector

`(a,b)`: Original position
`(c,d)`: Movement vector

Returns new position after movement

Example:
move (10,20) (5,-5) -- Returns (15,15)

-}
move : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
move ( a, b ) ( c, d ) =
    ( a + c, b + d )


{-| Update enemy positions based on their current velocity

`enemy`: List of enemies
`dt`: Delta time since last update
`player`: Player position for distance check

Returns list of enemies with updated positions

-}
moveenemy : List Enemy -> Float -> ( Float, Float ) -> List Enemy
moveenemy enemy dt player =
    let
        ( m, n ) =
            player

        newenemy =
            List.map
                (\e ->
                    let
                        ( x, y ) =
                            e.position

                        newe =
                            if abs (m - x) >= 1100 || abs (n - y) >= 700 then
                                e

                            else
                                { e | position = move e.position ( e.vx * dt * e.direction, 0 ) }
                    in
                    newe
                )
                enemy
    in
    newenemy


{-| Full enemy state and position update

`enemy`: List of enemies
`env`: Game environment data
`dt`: Delta time since last update
`player`: Player position for targeting

Returns fully updated list of enemies with:

1.  Updated velocities based on state
2.  Collision-corrected speeds
3.  Moved positions
4.  Refreshed states

Example:
updateenemy enemies env 0.016 (playerX, playerY)
-- Returns fully updated enemies

-}
updateenemy : List Enemy -> Env SceneCommonData UserData -> Float -> ( Float, Float ) -> List Enemy
updateenemy enemy env dt player =
    let
        temp1enemy =
            newspeed enemy env player

        temp2enemy =
            correctallspeed temp1enemy dt player

        temp3enemy =
            moveenemy temp2enemy dt player

        newenemy =
            refreshenemystate temp3enemy env player
    in
    newenemy



-- Internal helper functions (not exposed, no docs needed)


defaultmove : Enemy -> Enemy
defaultmove enemy =
    let
        ( newdir, newangle ) =
            if Tuple.first enemy.position <= Tuple.first enemy.defaultposition - 100 then
                ( 1, 0 )

            else if Tuple.first enemy.position >= Tuple.first enemy.defaultposition + 100 then
                ( -1, pi )

            else
                ( enemy.direction, enemy.angle )
    in
    { enemy | vx = 0.2, vy = 0, direction = newdir, angle = newangle }


normalmove : Enemy -> Enemy
normalmove enemy =
    if enemy.enemytype == Normal && enemy.enemystate == Attack then
        let
            newangle =
                if newdir < 0 then
                    pi

                else
                    0

            newvx =
                if abs (Tuple.first enemy.target - Tuple.first enemy.position) > 245 then
                    3

                else
                    sqrt (3 / 280 * (210 - (abs (Tuple.first enemy.target - Tuple.first enemy.position) - 35)))

            ( m, _ ) =
                enemy.target

            ( x, _ ) =
                enemy.position

            newdir =
                if abs (m - x) <= 35 && enemy.direction * (m - x) > 0 then
                    -enemy.direction

                else if abs (m - x) >= 245 && enemy.direction * (m - x) < 0 then
                    -enemy.direction

                else
                    enemy.direction
        in
        { enemy | direction = newdir, vx = newvx, angle = newangle }

    else
        enemy


advancedmove : Enemy -> Env SceneCommonData UserData -> Enemy
advancedmove enemy env =
    let
        ( m, _ ) =
            enemy.target

        ( x, y ) =
            enemy.position

        newangle =
            if Tuple.first enemy.target >= Tuple.first enemy.position then
                0

            else
                pi

        currentdistance =
            abs (m - x)

        targetdir =
            if Tuple.first enemy.target == Tuple.first enemy.position then
                1

            else
                (Tuple.first enemy.target - Tuple.first enemy.position) / abs (Tuple.first enemy.target - Tuple.first enemy.position)

        ( tempvx, newvy ) =
            if currentdistance >= 299.5 && currentdistance < 300 then
                move ( -x, -y ) ( m - 300 * targetdir, y )

            else if currentdistance < 299.5 then
                ( -0.5 * targetdir, 0 )

            else
                ( 0, 0 )

        newvx =
            tempvx / targetdir

        newenemy =
            if enemy.time <= env.globalData.sceneStartTime - 500 then
                { enemy | vx = newvx, vy = newvy, time = env.globalData.sceneStartTime, angle = newangle, direction = targetdir }

            else
                { enemy | vx = newvx, vy = newvy, angle = newangle, direction = targetdir }
    in
    newenemy


deadmove : Enemy -> State -> Enemy
deadmove enemy state =
    let
        playerface =
            state.weaponDir / abs state.weaponDir

        target =
            move state.position ( -100 * playerface, 0 )

        ( x, y ) =
            enemy.position

        vector =
            move target ( -x, -y )

        movedir =
            atan2 (Tuple.second vector) (Tuple.first vector)

        judge =
            distance target enemy.position <= 5

        newenemy =
            if judge then
                { enemy | position = target }

            else
                { enemy | position = move enemy.position ( 5 * cos movedir, 5 * sin movedir ) }
    in
    newenemy


newspeed : List Enemy -> Env SceneCommonData UserData -> ( Float, Float ) -> List Enemy
newspeed enemy env player =
    let
        ( x, y ) =
            player

        newenemy =
            List.map
                (\e ->
                    let
                        ( m, n ) =
                            e.position
                    in
                    if (abs (x - m) >= 1100 || abs (y - n) >= 700) || e.enemytype == Dead then
                        e

                    else if e.enemystate == Default then
                        defaultmove e

                    else if e.enemystate == Buffer then
                        e

                    else if e.enemystate == Attack && e.enemytype == Advanced then
                        advancedmove e env

                    else
                        normalmove e
                )
                enemy
    in
    newenemy
