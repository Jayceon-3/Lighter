module SceneProtos.Game.Components.Player.Init exposing (..)

{-|


# Init module

@docs InitData

-}

import Json.Decode exposing (bool)


type alias State =
    { position : ( Float, Float )
    , direction : Float
    , hp : Float
    , alive : Bool
    , vx : Float
    , vy : Float
    , a_pressed : Bool
    , d_pressed : Bool
    , canjump : Int
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , state : State
    }
