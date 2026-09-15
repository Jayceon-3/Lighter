module SceneProtos.Game.Components.Guidance.Init exposing (InitData)

{-|


# Init module

@docs InitData

-}


{-| The data used to initialize the scene.
Example:

    { id = 666
    , ty = "Guidance"
    }

-}
type alias InitData =
    { id : Int
    , ty : String
    }
