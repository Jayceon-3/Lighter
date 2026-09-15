module Scenes.Home.FrontLayer.DataHelp exposing (ScreenState(..), Buttonstate(..), Data, ButtonData)

{-|


# DataHelp

Types for the front layer of the home scene.

@docs ScreenState, Buttonstate, Data, ButtonData

-}


{-| ScreenState represents the current state of the screen.
`LogoScreen` is the initial state showing the logo.
`HomeScreen` is the home page after the logo is shown.
-}
type ScreenState
    = LogoScreen
    | HomeScreen


{-| Data structure for the front layer of the home scene.
`screenState` indicates the current state of the screen.
`startTime` is the timestamp when the scene starts.
`num_of_char` is the number of characters currently displayed.
`char_lasttime` is the last time a character was added.
`size_set` is the size of the set button.
`size_game` is the size of the game button.
`current_time` is the current timestamp for animations or updates.

Example:

    { screenState = LogoScreen
    , startTime = 0.0
    , num_of_char = 0
    , char_lasttime = 0.0
    , size_set = 1.0
    , size_game = 1.0
    , current_time = 0.0
    }

-}
type alias Data =
    { screenState : ScreenState
    , startTime : Float
    , num_of_char : Int
    , char_lasttime : Float
    , size_set : Float
    , size_game : Float
    , current_time : Float
    , help : ButtonData
    , game : ButtonData
    }


{-| Data structure for single button data.
`position`: the position of the button
`size`: the size of the button
`state`: the current state of the button (On, Off)
`inittime`: the time when the button was initialized or last pressed
Example:

    { position = ( 100, 200 )
    , size = ( 150, 50 )
    , state = Off
    , inittime = 0.0
    }

-}
type alias ButtonData =
    { position : ( Float, Float )
    , size : ( Float, Float )
    , state : Buttonstate
    , inittime : Float
    }


{-| The state of buttons.
`On` means the mouse is in the button.
`Off` means the mouse is outside the button.
-}
type Buttonstate
    = On
    | Off
