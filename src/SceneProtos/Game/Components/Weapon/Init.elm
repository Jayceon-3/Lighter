module SceneProtos.Game.Components.Weapon.Init exposing (..)

{-|


# Init module

@docs InitData

-}


type alias State =
    { position : ( Float, Float )
    , direction : Float
    , weaponType : Int
    , energy : Float
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , state : State
    }
