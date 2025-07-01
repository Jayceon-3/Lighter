module SceneProtos.Game.Components.Enemy.Init exposing (..)

{-|


# Init module

@docs InitData

-}


type alias EnemyBullet =
    { position : ( Float, Float )
    , direction : Float
    , angle : Float
    , attack : Float
    }


type Enemytype
    = Normal
    | Advanced
    | Dead


type Enemystate
    = Default
    | Buffer
    | Attack


type alias Enemy =
    { position : ( Float, Float )
    , defaultposition : ( Float, Float )
    , direction : Float
    , vx : Float
    , hp : Float
    , state : Enemystate
    , enemytype : Enemytype
    , angle : Float
    , time : Float
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , enemy : List Enemy
    , enemybullet : List EnemyBullet
    }
