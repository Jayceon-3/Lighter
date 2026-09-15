module SceneProtos.Game.Components.Background.Init exposing (InitData)

{-|


# Init

The initialization for the background component.

@docs InitData

-}

import SceneProtos.Game.Components.Background.BGUpdateHelp exposing (BGType(..))
import SceneProtos.Game.Components.Boss.Init exposing (InitData)


{-| The data used to initialize the background component.
-}
type alias InitData =
    { id : Int
    , ty : String
    , bgType : ( ( BGType, BGType ), ( BGType, BGType ) )
    , initTime : Float
    , position1 : ( Float, Float )
    , position2 : ( Float, Float )
    , position3 : ( Float, Float )
    , position4 : ( Float, Float )
    , position5 : ( Float, Float )
    }
