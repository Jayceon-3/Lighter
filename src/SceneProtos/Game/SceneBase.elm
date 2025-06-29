module SceneProtos.Game.SceneBase exposing
    ( LayerTarget
    , SceneCommonData
    , LayerMsg(..)
    )

{-|


# SceneBase

Basic data for the scene.

@docs LayerTarget
@docs SceneCommonData
@docs LayerMsg

-}

import SceneProtos.Game.Main.Init as MainInit


{-| Layer target type
-}
type alias LayerTarget =
    String


{-| Common data
-}
type alias SceneCommonData =
    {}


{-| General message for layers
-}
type LayerMsg scenemsg
    = NullLayerMsg
    | MainInitData (MainInit.InitData SceneCommonData scenemsg)
