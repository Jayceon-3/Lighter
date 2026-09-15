module SceneProtos.Game.Components.Player.Playerview exposing (Data, fixpos, playersize, flippedPlayersize, playersize_left, pos_left, run, stay, jump, jump_run_stay)

{-|


# Playerview

Functions for rendering the player view in the game.

@docs Data, fixpos, playersize, flippedPlayersize, playersize_left, pos_left, run, stay, jump, jump_run_stay

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Camera, Renderable, group)
import REGL.Effects exposing (alphamult)
import SceneProtos.Game.Components.DW.VisualDW exposing (decideAlpha)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection(..), Tile)
import SceneProtos.Game.Components.Player.Coordtransform exposing (screentocanvas)
import SceneProtos.Game.Components.Player.Init exposing (Spritetype(..), State)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, Shield, ShieldState(..))
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The player component data structure. Copied from the Model to avoid import loop.
-}
type alias Data =
    { id : Int
    , ty : String
    , state : State
    , isSwing : Bool
    , mechanicalArm : MechanicalArm
    , pendingCollisions : List CollisionDirection
    , playercamera : Camera
    , tiles : List ( Int, Int, Tile )
    , currentShield : Shield
    , keyAnimation : Bool
    , rightbound : Float
    }


{-| Fixes the position of the player by adjusting the coordinates.
-}
fixpos : ( Float, Float ) -> ( Float, Float )
fixpos ( x, y ) =
    ( x + 28, y - 25 )


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


{-| Adjusts the position of the player character when facing left.
-}
pos_left : ( Float, Float ) -> ( Float, Float )
pos_left ( x, y ) =
    ( x + 28 - 55, y - 25 )


{-| Renders the player character in a running animation based on the current state.
-}
run : Env SceneCommonData UserData -> String -> State -> Renderable
run env ty state =
    let
        fixedpos =
            fixpos <| state.position

        gd =
            env.globalData

        rate =
            100

        currentAct =
            modBy 6 (floor (gd.sceneStartTime / rate)) |> String.fromInt

        time =
            round env.globalData.currentTimeStamp

        ( size, pos ) =
            if state.weaponDir == 1 then
                ( playersize, fixedpos )

            else
                ( playersize_left, pos_left state.position )
    in
    if env.globalData.userData.dw then
        if ty == "Player" then
            group [] [ P.centeredTexture pos size 0 ("Run" ++ currentAct) ]

        else
            group [] [ P.centeredTextureWithAlpha pos size 0 (decideAlpha env time) ("Run" ++ currentAct) ]

    else
        group [] [ P.centeredTexture pos size 0 ("Run" ++ currentAct) ]


{-| Renders the player character in a stationary position based on the current state.
-}
stay : Env SceneCommonData UserData -> String -> State -> Renderable
stay env ty state =
    let
        fp =
            state.position |> fixpos

        time =
            round env.globalData.currentTimeStamp

        ( p, player ) =
            if state.weaponDir == 1 then
                ( fp, playersize )

            else
                ( pos_left state.position, playersize_left )

        currentAct =
            String.fromInt (modBy 4 (floor (env.globalData.sceneStartTime / 300)))
    in
    if env.globalData.userData.dw then
        if ty == "Player" then
            group [] [ P.centeredTexture p player 0 ("Idle" ++ currentAct) ]

        else
            group [] [ P.centeredTextureWithAlpha p player 0 (decideAlpha env time) ("Idle" ++ currentAct) ]

    else
        group [] [ P.centeredTexture p player 0 ("Idle" ++ currentAct) ]


{-| Renders the player character in a jumping position based on the current state.
-}
jump : Env SceneCommonData UserData -> String -> State -> Renderable
jump env ty state =
    let
        fixedpos =
            fixpos state.position

        time =
            round env.globalData.currentTimeStamp

        currentAct =
            if state.vy < -200 then
                if state.weaponDir == 1 then
                    "0"

                else
                    "0"

            else if state.vy < -100 then
                if state.weaponDir == 1 then
                    "1"

                else
                    "1"

            else if state.vy < 50 then
                if state.weaponDir == 1 then
                    "2"

                else
                    "2"

            else if state.weaponDir == 1 then
                "3"

            else
                "3"

        s =
            if state.weaponDir == 1 then
                playersize

            else
                playersize_left

        position =
            if state.weaponDir == 1 then
                fixedpos

            else
                pos_left state.position
    in
    if env.globalData.userData.dw then
        if ty == "Player" then
            group [] [ P.centeredTexture position s 0 ("Jump" ++ currentAct) ]

        else
            group [] [ P.centeredTextureWithAlpha position s 0 (decideAlpha env time) ("Jump" ++ currentAct) ]

    else
        group [] [ P.centeredTexture position s 0 ("Jump" ++ currentAct) ]


{-| Renders the player character in a jumping, running, or stationary position based on the current state.
-}
jump_run_stay : Spritetype -> Env SceneCommonData UserData -> String -> State -> List Renderable -> ( Renderable, Int )
jump_run_stay spritetype env ty state render =
    case spritetype of
        Run ->
            ( group
                []
                (render
                    ++ [ run env ty state ]
                )
            , 10
            )

        Stay ->
            ( group
                []
                (render
                    ++ [ stay env ty state ]
                )
            , 10
            )

        Jump ->
            ( group
                []
                (render
                    ++ [ jump env ty state ]
                )
            , 10
            )
