module SceneProtos.Game.Components.Weapon.MechanicalArm exposing (distance, judgeArmTile, stretching, swing, swingArmChange, updatePosition)

{-|


# MechanicalArm

This module contains functions for the logic for mechanical arm movements in the game.

@docs distance, judgeArmTile, stretching, swing, swingArmChange, updatePosition

-}

import Color
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import SceneProtos.Game.Components.Map.Init exposing (Tile)
import SceneProtos.Game.Components.Weapon.DashShorteningHelp exposing (dashMove)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, MechanicalArmState(..), SwingMode(..))
import SceneProtos.Game.Components.Weapon.LongSpring exposing (longSpring)
import SceneProtos.Game.Components.Weapon.SpringPendulum exposing (mediumSpring, shortSpring)
import SceneProtos.Game.Components.Weapon.WeaponUpdate exposing (decideAngle)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Calculate the distance beteween two objects.
-}
distance : ( Float, Float ) -> ( Float, Float ) -> Float
distance ( a, b ) ( c, d ) =
    sqrt ((a - c) * (a - c) + (b - d) * (b - d))


{-| Function for stretching mode update.
-}
stretching : Float -> ( ( Float, Float ), ( Float, Float ) ) -> List ( Int, Int, Tile ) -> Float -> ( Float, Float ) -> Float -> ( ( ( Float, Float ), ( Float, Float ), ( ( Float, Float ), ( Float, Float ) ) ), ( Float, ( SwingMode, Float ), Bool ), ( Float, Float ) )
stretching dt ( position, speed ) tiles angle initPos length =
    let
        ( vx0, vy0 ) =
            speed

        vx1 =
            if (angle > 0) && (angle <= pi / 2) then
                abs vx0

            else if (angle < 0) && (angle > (-pi / 2)) then
                -(abs vx0)

            else
                0

        newSpeed =
            ( vx1, vy0 )

        ( x0, y0 ) =
            initPos

        dir =
            if angle >= 0 then
                1

            else
                -1

        armTilePos =
            armTile tiles initPos angle length

        ( x1, y1 ) =
            armTilePos

        judgeDash =
            abs angle <= pi / 6

        armEdge =
            if angle >= 0 then
                ( x0 + length * cos angle, y0 - length * sin angle )

            else
                ( x0 - length * cos angle, y0 + length * sin angle )

        anchor =
            decideAnchor judgeDash armEdge ( x0, y0 ) ( x1, y1 ) angle

        ( ( x, y ), ( vx, vy ) ) =
            if judgeDash then
                updatePosition 0 0 dt ( position, newSpeed )

            else
                updatePosition 0 1200 dt ( position, newSpeed )

        ( maxLength, mode ) =
            decideMaxlength judgeDash (distance anchor initPos) dir
    in
    if armTilePos == ( 0, 0 ) then
        ( ( ( x, y ), ( vx, vy ), ( armEdge, armTilePos ) ), ( length + 36, mode, True ), anchor )

    else if length <= maxLength then
        ( ( ( x, y ), ( vx, vy ), ( armEdge, armTilePos ) ), ( length + 36, mode, True ), anchor )

    else
        ( ( ( x, y ), ( vx, vy ), ( armEdge, armTilePos ) ), ( maxLength, mode, False ), anchor )



-- Function to decide the anchor position.


decideAnchor : Bool -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> Float -> ( Float, Float )
decideAnchor judgeDash armEdge ( x0, y0 ) ( x1, y1 ) angle =
    let
        anchor =
            if judgeDash then
                if Tuple.first armEdge - x1 >= 0 then
                    ( x1 + 30, y0 - tan angle * (x1 + 30 - x0) )

                else
                    ( x1 - 30, y0 - tan angle * (x1 - 30 - x0) )

            else
                ( x0 + (y1 + 30 - y0) / -(tan angle), y1 + 30 )
    in
    anchor



-- Function to calculate the max length of mechanical arm.


decideMaxlength : Bool -> Float -> Float -> ( Float, ( SwingMode, Float ) )
decideMaxlength judgeDash d dir =
    if judgeDash then
        ( d, ( Dash, dir ) )

    else if d <= 500 then
        ( d, ( Short, dir ) )

    else if d <= 1000 then
        ( d, ( Medium, dir ) )

    else if d <= 1500 then
        ( d, ( Long, dir ) )

    else
        ( 1500, ( Long, dir ) )


{-| Function for the collision detect between tile and mechanical arm.
-}
judgeArmTile : ( Float, Float ) -> ( Float, Float ) -> ( Int, Int, Tile ) -> ( ( Float, Float ), Bool )
judgeArmTile armPos ( angle, length ) tileinfo =
    let
        ( x, y, tile ) =
            tileinfo

        ( x0, y0 ) =
            armPos

        ( x1, y1 ) =
            if angle >= 0 then
                ( x0 + length * cos angle, y0 - length * sin angle )

            else
                ( x0 - length * cos angle, y0 + length * sin angle )

        judge =
            tile.solid && x1 >= toFloat (x - 30) && x1 <= toFloat (x + 30) && y1 >= toFloat (y - 30) && y1 <= toFloat (y + 30)
    in
    ( ( toFloat x, toFloat y ), judge )


armTile : List ( Int, Int, Tile ) -> ( Float, Float ) -> Float -> Float -> ( Float, Float )
armTile tiles initPos angle length =
    let
        judgeTileList =
            List.map (\tile -> judgeArmTile initPos ( angle, length ) tile) tiles

        armTilePosList =
            judgeTileList
                |> List.filter (\( _, bool ) -> bool)
                |> List.map (\( pos, _ ) -> pos)

        armTilePos =
            case List.head armTilePosList of
                Just p ->
                    p

                _ ->
                    ( 0, 0 )
    in
    armTilePos


{-| Function for mechanical arm position update.
-}
updatePosition : Float -> Float -> Float -> ( ( Float, Float ), ( Float, Float ) ) -> ( ( Float, Float ), ( Float, Float ) )
updatePosition ax ay dt ( position, speed ) =
    let
        ( x0, y0 ) =
            position

        ( vx0, vy0 ) =
            speed

        ( vx, vy ) =
            ( vx0 + ax * dt / 1000, vy0 + ay * dt / 1000 )

        ( x, y ) =
            ( x0 + vx * dt / 1000, y0 + vy * dt / 1000 )
    in
    ( ( x, y ), ( vx, vy ) )


{-| Function for swing mode update.
-}
swing : Env SceneCommonData UserData -> ( SwingMode, Float ) -> Float -> ( Float, Float ) -> Float -> Float -> ( ( Float, Float ), ( Float, Float ) ) -> ( ( ( Float, Float ), ( Float, Float ) ), ( Float, ( Float, Float ), Bool ), Bool )
swing env mode initSpringTime initSpringPos angle dt ( position, speed ) =
    let
        ( ( x1, y1 ), ( vx1, vy1 ) ) =
            updatePosition 0 1200 dt ( position, speed )

        currentTime =
            env.globalData.currentTimeStamp

        judge1 =
            case Tuple.first mode of
                Short ->
                    vy1 >= -400

                Medium ->
                    vy1 >= -600

                Long ->
                    vy1 >= -800

                Dash ->
                    True

        deltaT =
            (currentTime - initSpringTime) / 1000

        ( ( x2, y2 ), judge2 ) =
            case Tuple.first mode of
                Short ->
                    ( shortSpring (Tuple.second mode) initSpringPos deltaT, deltaT >= 0.5 )

                Medium ->
                    ( mediumSpring (Tuple.second mode) initSpringPos deltaT, deltaT >= 0.5 )

                Long ->
                    ( longSpring (Tuple.second mode) initSpringPos deltaT, deltaT >= 1 )

                Dash ->
                    ( dashMove (Tuple.second mode) angle position dt, True )
    in
    if judge1 == False then
        ( ( ( x1, y1 ), ( vx1, vy1 ) ), ( currentTime, ( x1, y1 ), True ), True )

    else if judge2 == False then
        ( ( ( x2, y2 ), ( vx1, vy1 ) ), ( currentTime, ( x1, y1 ), False ), True )

    else
        ( ( ( x2, y2 ), ( vx1, vy1 ) ), ( currentTime, ( x1, y1 ), False ), False )



-- theta0 = pi/4; k = 20


{-| Function for mechanical arm update in swing mode.
-}
swingArmChange : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
swingArmChange anchor position =
    let
        ( x0, y0 ) =
            position

        ( x, y ) =
            anchor

        newLength =
            distance anchor position

        newAngle =
            decideAngle anchor position
    in
    if newLength > 0 then
        ( newLength, newAngle )

    else
        ( 0, 0 )
