module SceneProtos.Game.Components.Player.Doublejump exposing (can_jump, double_jump_msg)

{-|


# Doublejump

Functions for handling double jump mechanics for player.

@docs can_jump, double_jump_msg

-}

import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Player.Init exposing (..)


{-| Checks if the player can perform a double jump based on the current state.
-}
can_jump : State -> Bool
can_jump state =
    state.canjump > 0


{-| Generates a message to trigger double jump particles based on the player's position.
-}
double_jump_msg : State -> List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata))
double_jump_msg state =
    if state.canjump == 1 then
        [ Other ( "Particle", DoublejumpMsg state.position ) ]

    else
        []
