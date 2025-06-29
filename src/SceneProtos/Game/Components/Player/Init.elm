module SceneProtos.Game.Components.Player.Init exposing (..)

{-|


# Init module

@docs InitData

-}


type alias State =
    { position : ( Float, Float )
    , speed : Float
    , direction : Int
    , hp : Float
    , alive : Bool
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , state : State
    }
