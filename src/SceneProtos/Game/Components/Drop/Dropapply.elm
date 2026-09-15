module SceneProtos.Game.Components.Drop.Dropapply exposing (decreasecount, apply_drop)

{-|


# Dropapply

Functions for applying drops to the player.

@docs decreasecount, apply_drop

-}

import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import Random
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..), Singledrop)


{-| The drop component data structure. Copied from the Model to avoid import loop.
-}
type alias Data =
    { drops : List Singledrop
    , playerpos : ( Float, Float )
    , lifedrop : Int
    , energydrop : Int
    , scatterdrop : Int
    }


{-| Decreases the count of a specific drop type in the data structure.
-}
decreasecount : Droptype -> Data -> Data
decreasecount droptype data =
    let
        life =
            data.lifedrop

        energy =
            data.energydrop

        scatter =
            data.scatterdrop
    in
    case droptype of
        Life ->
            { data | lifedrop = max (life - 1) 0 }

        Energy ->
            { data | energydrop = max (energy - 1) 0 }

        Scatterbullet ->
            { data | scatterdrop = max (scatter - 1) 0 }


{-| Applies a drop to the player based on the drop type and updates the state accordingly.
It generates messages to notify other components about the drop application.
-}
apply_drop : Data -> Droptype -> List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata))
apply_drop data droptype =
    case droptype of
        Life ->
            if data.lifedrop > 0 then
                [ Other ( "Player", DropMsg Life )
                , Other ( "Particle", DropMsg Life )
                ]

            else
                []

        Energy ->
            if data.energydrop > 0 then
                [ Other ( "Weapon", DropMsg Energy )
                , Other ( "Particle", DropMsg Energy )
                ]

            else
                []

        Scatterbullet ->
            if data.scatterdrop > 0 then
                [ Other ( "Weapon", DropMsg Scatterbullet )
                , Other ( "Particle", DropMsg Scatterbullet )
                ]

            else
                []
