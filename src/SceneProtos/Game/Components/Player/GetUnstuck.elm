module SceneProtos.Game.Components.Player.GetUnstuck exposing (getUnstuck)

{-|


# GetUnstuck

Functions to help the player get unstuck from solid tiles.

@docs getUnstuck

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.Common exposing (Camera)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection, Tile)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, MechanicalArmState(..), Shield, ShieldState(..), SwingMode(..))
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


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


{-| This function enables player to get free when he/she is stuck unexpectedly.
-}
getUnstuck : Env SceneCommonData UserData -> Data -> BaseData -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
getUnstuck env data basedata =
    if isInSolidTile data.state.position data.tiles then
        case findNearestNonSolidTile data.state.position data.tiles of
            Just newPos ->
                let
                    ds =
                        data.state
                in
                ( ( { data | state = { ds | position = newPos } }, basedata )
                , []
                , ( env, False )
                )

            Nothing ->
                ( ( data, basedata ), [], ( env, False ) )

    else
        ( ( data, basedata ), [], ( env, False ) )


isInSolidTile : ( Float, Float ) -> List ( Int, Int, Tile ) -> Bool
isInSolidTile ( x, y ) tiles =
    tiles
        |> List.any
            (\( tx, ty, tile ) ->
                tile.solid
                    && abs (x - toFloat tx)
                    <= 43
                    && abs (y - toFloat ty)
                    <= 58
            )


findNearestNonSolidTile : ( Float, Float ) -> List ( Int, Int, Tile ) -> Maybe ( Float, Float )
findNearestNonSolidTile ( x, y ) tiles =
    tiles
        |> List.filter (\( _, _, t ) -> not t.solid)
        |> List.map (\( tx, ty, _ ) -> ( tx, ty ))
        |> List.sortBy (\( tx, ty ) -> distanceSquared x y (toFloat tx) (toFloat ty))
        |> List.head
        |> Maybe.map (\( tx, ty ) -> ( toFloat tx, toFloat ty ))


distanceSquared : Float -> Float -> Float -> Float -> Float
distanceSquared x1 y1 x2 y2 =
    (x1 - x2) ^ 2 + (y1 - y2) ^ 2
