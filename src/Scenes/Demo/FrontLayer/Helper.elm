module Scenes.Demo.FrontLayer.Helper exposing (level12X, level34X, level13Y, level24Y, buttonWidth, buttonHeight, Data)

{-|


# Helper

Helper functions for rendering and updating the demo scene.

@docs level12X, level34X, level13Y, level24Y, buttonWidth, buttonHeight, Data

-}

import Scenes.Home.FrontLayer.DataHelp exposing (ButtonData)


{-| The x coordinate of level1 and level2 buttons.
-}
level12X : Float
level12X =
    1000


{-| The x coordinate of level3 and level4 buttons.
-}
level34X : Float
level34X =
    1400


{-| The y coordinate of level1 and level3 buttons.
-}
level13Y : Float
level13Y =
    400


{-| The width of buttons.
-}
buttonWidth : Float
buttonWidth =
    240


{-| The height of buttons.
-}
buttonHeight : Float
buttonHeight =
    80


{-| The y coordinate of level2 and level4 buttons.
-}
level24Y : Float
level24Y =
    650


{-| Data model for front layer of the demo scene.
`size1`, `size2`, `size3`, and `size4` represent the sizes of the buttons.
`current_time` is used to track the time for size adjustment.

Example:

    { size1 = 1.0
    , size2 = 1.0
    , size3 = 1.0
    , size4 = 1.0
    , current_time = 0.0
    }

-}
type alias Data =
    { size1 : Float
    , size2 : Float
    , size3 : Float
    , size4 : Float
    , current_time : Float
    , level1 : ButtonData
    , level2 : ButtonData
    , level3 : ButtonData
    , level4 : ButtonData
    }
