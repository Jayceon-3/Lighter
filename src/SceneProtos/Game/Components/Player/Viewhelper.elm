module SceneProtos.Game.Components.Player.Viewhelper exposing (playersize, flippedPlayersize, playersize_left, shieldRender)

{-|


# Viewhelper

Functions for rendering players and shield

@docs playersize, flippedPlayersize, playersize_left, shieldRender

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection(..))
import SceneProtos.Game.Components.Player.Helper exposing (Data)
import SceneProtos.Game.Components.Player.Init exposing (Spritetype(..))
import SceneProtos.Game.Components.Weapon.Init exposing (ShieldState(..))
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The size of the player character.
-}
playersize : ( Float, Float )
playersize =
    ( 110, 110 )


{-| The flipped size of the player character for rendering when facing left.
-}
flippedPlayersize : ( Float, Float )
flippedPlayersize =
    ( -110, 110 )


{-| The size of the player character when facing left.
-}
playersize_left : ( Float, Float )
playersize_left =
    ( -110, 110 )


{-| Renders the shield of the player character based on the current state and environment.
-}
shieldRender : Env SceneCommonData UserData -> Data -> List Renderable
shieldRender env data =
    let
        shield =
            data.currentShield

        weaponDir =
            data.state.weaponDir

        initHandTime =
            shield.initHandTime

        currentTime =
            env.globalData.currentTimeStamp

        deltaT =
            currentTime - initHandTime

        shieldState =
            shield.shieldState

        currentAct =
            if shieldState == Hand then
                if (deltaT / 250) >= 4 then
                    "8"

                else
                    String.fromInt (modBy 4 (floor (deltaT / 250)))

            else if shieldState == Unused then
                if shield.initHandTime == 0 then
                    "100"

                else if (deltaT / 300) >= 2 then
                    "100"

                else
                    String.fromInt (modBy 3 (floor (deltaT / 250)) + 3)

            else
                "6"

        ( x0, y0 ) =
            data.state.position

        newPosition =
            ( x0 + 15, y0 - 25 )

        shieldPos =
            if weaponDir >= 0 then
                ( x0 + 20, y0 - 15 )

            else
                ( x0 + 10, y0 - 15 )
    in
    if currentAct == "100" then
        [ P.empty ]

    else if currentAct == "6" then
        if weaponDir >= 0 then
            [ P.centeredTexture shield.position playersize 0 ("Shield" ++ currentAct) ]

        else
            [ P.centeredTexture shield.position flippedPlayersize 0 ("Shield" ++ currentAct) ]

    else if currentAct == "8" then
        if weaponDir >= 0 then
            [ P.centeredTexture newPosition playersize 0 ("Shield" ++ currentAct) ]
                ++ [ P.centeredTexture shieldPos playersize shield.angle ("Shield" ++ "7") ]

        else
            [ P.centeredTexture newPosition flippedPlayersize 0 ("Shield" ++ currentAct) ]
                ++ [ P.centeredTexture shieldPos flippedPlayersize shield.angle ("Shield" ++ "7") ]

    else if weaponDir >= 0 then
        [ P.centeredTexture newPosition playersize 0 ("Shield" ++ currentAct) ]

    else
        [ P.centeredTexture newPosition flippedPlayersize 0 ("Shield" ++ currentAct) ]
