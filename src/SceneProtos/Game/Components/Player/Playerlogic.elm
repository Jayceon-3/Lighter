module SceneProtos.Game.Components.Player.Playerlogic exposing (a, g, validbullet, validenemy, resolveCollisions, cbullet, w, h)

{-|


# Playerlogic

Functions for handling player logic, including movement, collision resolution, and bullet validation.

@docs a, g, validbullet, validenemy, resolveCollisions, cbullet, w, h

-}

import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (..)
import SceneProtos.Game.Components.Enemy.Init exposing (Enemy, EnemyBullet, Enemystate(..), Enemytype(..))
import SceneProtos.Game.Components.Map.Init exposing (..)
import SceneProtos.Game.Components.Player.Helper exposing (DirectionSpec, tileH, tileW)
import SceneProtos.Game.Components.Player.Init exposing (..)
import SceneProtos.Game.Components.Survcamera.Init exposing (CameraBullet)


{-| The acceleration in horizontal direction in the game.
-}
a : Float
a =
    1500


{-| The gravitational acceleration in the game.
-}
g : Float
g =
    1500


{-| Validates the bullets based on their position relative to the player's position.
-}
validbullet : List EnemyBullet -> State -> List EnemyBullet
validbullet bullet state =
    let
        ( x, y ) =
            state.position

        valid =
            List.filter
                (\b ->
                    let
                        ( m, n ) =
                            b.position

                        judge =
                            abs (x - m) <= 15 && abs (y - n) <= 30
                    in
                    judge
                )
                bullet
    in
    valid


{-| Validates the enemies based on their position relative to the player.
-}
validenemy : List Enemy -> State -> State
validenemy enemy state =
    let
        valid =
            List.filter
                (\e ->
                    let
                        ( x, y ) =
                            state.position

                        ( m, n ) =
                            move ( -x, -y ) e.position

                        judge1 =
                            abs m <= 32 && abs n < 30 && e.enemytype == Normal && e.enemystate == Attack

                        judge2 =
                            distance (move e.target ( -x, -y )) ( 0, 0 ) <= 4
                    in
                    judge1 && judge2
                )
                enemy

        newstate =
            { state | hp = state.hp - toFloat (10 * List.length valid) }
    in
    newstate


{-| Resolves collisions based on the provided directions.
-}
resolveCollisions : State -> List CollisionDirection -> State
resolveCollisions state dirs =
    let
        ( yDirs, xDirs ) =
            List.partition (\dir -> dir == Bottom || dir == Top) dirs

        stateY =
            List.foldl resolveOne state yDirs

        stateXY =
            List.foldl resolveOne stateY xDirs
    in
    stateXY


{-| The width of the player character.
-}
w : Float
w =
    30


{-| The height of the player character.
-}
h : Float
h =
    60


directionSpecs : List DirectionSpec
directionSpecs =
    [ { dir = Bottom
      , condition = \s -> s.vy >= 0
      , tileIndex =
            \s ->
                let
                    ( _, y ) =
                        s.position
                in
                floor ((y + h / 2) / tileH)
      , correctedPos =
            \s tileY ->
                let
                    ( x, _ ) =
                        s.position

                    y =
                        toFloat tileY * tileH - h / 2
                in
                ( x, y )
      , stopVy = True
      , stopVx = False
      , setJump = True
      }
    , { dir = Top
      , condition = \s -> s.vy <= 0
      , tileIndex =
            \s ->
                let
                    ( _, y ) =
                        s.position
                in
                floor ((y - h / 2) / tileH)
      , correctedPos =
            \s tileY ->
                let
                    ( x, _ ) =
                        s.position

                    y =
                        toFloat (tileY + 1) * tileH + h / 2
                in
                ( x, y )
      , stopVy = True
      , stopVx = False
      , setJump = False
      }
    , { dir = Left
      , condition = \_ -> True
      , tileIndex =
            \s ->
                let
                    ( x, _ ) =
                        s.position
                in
                floor ((x - w / 2) / tileW)
      , correctedPos =
            \s tileX ->
                let
                    ( _, y ) =
                        s.position

                    x =
                        toFloat (tileX + 1) * tileW + w / 2 + 1
                in
                ( x, y )
      , stopVy = False
      , stopVx = True
      , setJump = False
      }
    , { dir = Right
      , condition = \_ -> True
      , tileIndex =
            \s ->
                let
                    ( x, _ ) =
                        s.position
                in
                floor ((x + w / 2) / tileW)
      , correctedPos =
            \s tileX ->
                let
                    ( _, y ) =
                        s.position

                    x =
                        toFloat tileX * tileW - w / 2 - 1
                in
                ( x, y )
      , stopVy = False
      , stopVx = True
      , setJump = False
      }
    ]


resolveOne : CollisionDirection -> State -> State
resolveOne dir state =
    case List.filter (\spec -> spec.dir == dir) directionSpecs |> List.head of
        Just spec ->
            if spec.condition state then
                let
                    idx =
                        spec.tileIndex state

                    ( newX, newY ) =
                        spec.correctedPos state idx
                in
                { state
                    | position = ( newX, newY )
                    , vy =
                        if spec.stopVy then
                            0

                        else
                            state.vy
                    , vx =
                        if spec.stopVx then
                            0

                        else
                            state.vx
                    , canjump =
                        if spec.setJump then
                            2

                        else
                            state.canjump
                }

            else
                state

        Nothing ->
            state


{-| Handles the camera bullet logic based on the player's state and the existing camera bullets.
-}
cbullet : State -> List CameraBullet -> ( State, List CameraBullet )
cbullet state bullets =
    let
        ( x, y ) =
            state.position

        oldattack =
            List.length bullets

        newbullets =
            List.filter
                (\b ->
                    let
                        ( m, n ) =
                            b.position

                        judge =
                            not (abs (m - x) <= 15 && abs (n - y) <= 30)
                    in
                    judge
                )
                bullets

        newstate =
            { state | hp = state.hp - toFloat (10 * (oldattack - List.length newbullets)) }
    in
    ( newstate, newbullets )
