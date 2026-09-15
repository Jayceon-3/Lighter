module SceneProtos.Game.Components.DW.Init exposing (InitData)

{-|


# Init module

@docs InitData

-}

import SceneProtos.Game.Components.Map.Init exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (State)


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , state : State
    , pendingCollisions : List CollisionDirection
    }
