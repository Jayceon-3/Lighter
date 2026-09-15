module SceneProtos.Game.Components.Drop.Init exposing
    ( InitData
    , Droptype(..), Singledrop
    )

{-|


# Init module

Initialization for the drop component.

@docs InitData
@docs Droptype, Singledrop

-}


{-| Defines the types of drops available in the game.
`Life`: A drop that restores life.
`Energy`: A drop that restores energy.
`Scatterbullet`: A drop that provides scatter bullets.
-}
type Droptype
    = Life
    | Energy
    | Scatterbullet


{-| Defines the structure of a single drop in the game.
`position`: The position of the drop in the game world.
`size`: The size of the drop.
`droptype`: The type of the drop (Life, Energy, Scatterbullet).
`dir`: The moving direction of the drop.
`viewpos`: The position of the drop in the view.
`v`: The velocity of the drop.

Example:

    { position = ( 100, 200 )
    , size = 30
    , droptype = Life
    , dir = 0.5
    , viewpos = ( 150, 250 )
    , v = 1.0
    }

-}
type alias Singledrop =
    { position : ( Float, Float )
    , size : Float
    , droptype : Droptype
    , dir : Float
    , viewpos : ( Float, Float )
    , v : Float
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { drops : List Singledrop
    , playerpos : ( Float, Float )
    , lifedrop : Int
    , energydrop : Int
    , scatterdrop : Int
    }
