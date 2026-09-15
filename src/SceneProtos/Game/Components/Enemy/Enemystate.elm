module SceneProtos.Game.Components.Enemy.Enemystate exposing (refreshenemystate)

{-|


# Enemystate

Handles enemy state transitions and updates based on game conditions.

@docs refreshenemystate

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Bullet.Init exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Enemy.Enemywall exposing (..)
import SceneProtos.Game.Components.Enemy.Init exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


judgeactivate : Enemy -> ( Float, Float ) -> Env SceneCommonData UserData -> Enemy
judgeactivate enemy position env =
    let
        newangle =
            if Tuple.first position >= Tuple.first enemy.position then
                0

            else
                pi

        newdir =
            if Tuple.first position >= Tuple.first enemy.position then
                1

            else
                -1

        judge =
            abs (Tuple.first enemy.position - Tuple.first position) < 500 && abs (Tuple.second enemy.position - Tuple.second position) < 50

        newenemy =
            if enemy.enemytype == Dead then
                enemy

            else if enemy.enemystate == Default && judge then
                { enemy | enemystate = Buffer, time = env.globalData.sceneStartTime, angle = newangle, direction = newdir, vx = 0, vy = 0 }

            else if enemy.enemystate /= Default && not judge then
                { enemy | enemystate = Default }

            else if enemy.enemystate == Buffer && (env.globalData.sceneStartTime - enemy.time >= 500) then
                { enemy | enemystate = Attack, time = env.globalData.sceneStartTime }

            else
                enemy
    in
    newenemy


judgestate : Enemy -> Enemy
judgestate enemy =
    if enemy.hp > 0 && enemy.hp <= 100 then
        { enemy | enemytype = Normal }

    else if enemy.hp <= 0 then
        { enemy | enemytype = Dead }

    else
        enemy


{-| Refresh the state of all enemies based on their conditions and proximity to player

This function will:

1.  Skip enemies that are too far from the player (distance > 1100x700)
2.  Update enemy type based on HP (Normal when HP <= 100, Dead when HP <= 0)
3.  Transition enemy states between Default/Buffer/Attack based on:
      - Distance to target
      - Time spent in current state
      - Direction facing

`enemy`: List of current enemies
`env`: Game environment with timing data
`player`: Current player position (x,y)

Returns updated list of enemies with new states

Example:
refreshenemystate enemies env (playerX, playerY)
-- Returns enemies with updated states and types

-}
refreshenemystate : List Enemy -> Env SceneCommonData UserData -> ( Float, Float ) -> List Enemy
refreshenemystate enemy env player =
    let
        ( x, y ) =
            player

        newenemy =
            List.map
                (\e ->
                    let
                        ( m, n ) =
                            e.position

                        newe =
                            if abs (m - x) >= 1100 || abs (n - y) >= 700 then
                                e

                            else
                                judgeactivate (judgestate e) e.target env
                    in
                    newe
                )
                enemy
    in
    newenemy
