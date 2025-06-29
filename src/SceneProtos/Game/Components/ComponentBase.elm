module SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..), ComponentTarget, BaseData)

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData

-}

import SceneProtos.Game.Components.Player.Init as PlayerInit


{-| Component message
-}
type ComponentMsg
    = NullComponentMsg
    | PlayerInitMsg PlayerInit.InitData


{-| Component target
-}
type alias ComponentTarget =
    String


{-| Component base data
-}
type alias BaseData =
    ()
