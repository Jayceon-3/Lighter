module SceneProtos.Game.Components.Player.Init exposing (InitData)

{-|


# Init module

@docs InitData

-}


{-| The data used to initialize the scene
-}
type alias InitData =
    { position : ( Float, Float )
    , speed : Float
    , direction : Int
    , hp : Float
    , id : Int
    , ty : String
    }
