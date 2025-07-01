module SceneProtos.Game.Components.Bullet.Init exposing (..)

{-|


# Init module

@docs InitData

-}


type alias SingleBullet =
    { position : ( Float, Float )
    , direction : Float
    , angle : Float
    , bulletType : Int
    , attack : Float
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , bullets : List SingleBullet
    }
