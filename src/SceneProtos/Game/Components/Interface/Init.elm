module SceneProtos.Game.Components.Interface.Init exposing (InitData)

{-|


# Init module

@docs InitData

-}

import REGL.Common exposing (Camera)


{-| The data used to initialize the scene.
Example:

    { id = 999
    , ty = "Interface"
    , current_camera = env.globalData.camera
    }

-}
type alias InitData =
    { id : Int
    , ty : String
    , current_camera : Camera
    }
