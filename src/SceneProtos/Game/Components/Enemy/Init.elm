module SceneProtos.Game.Components.Enemy.Init exposing (..)

{-|


# Init module

@docs InitData

-}


type alias Bullet =
    { position : ( Float, Float )
    , attack : Float
    }


type Enemytype
    = Normal
    | Advanced
    | Dead


type alias Enemy =
    { position : ( Float, Float )
    , direction : Float -- 1 for right, -1 for left
    , vx : Float
    , hp : Float
    , normal : Bool
    , enemytype : Enemytype
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , enemy : List Enemy
    , bullet : List Bullet
    }
