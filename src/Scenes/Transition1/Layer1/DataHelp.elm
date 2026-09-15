module Scenes.Transition1.Layer1.DataHelp exposing (Data, DialogueLine, TransitionState(..))

{-|


# DataHelp

Functions for initializing transition1.

@docs Data, DialogueLine, TransitionState

-}

import Scenes.Transition1.Layer1.Grid exposing (Coderain)


{-| Data structure for the front layer of the transition1 scene.
`para` indicates the current order of paragraphs.
`num_of_char` is the number of characters currently displayed.
`char_lasttime` is the last time a character was added.
`isFinished` indicates whether the dialogue is finished.
`transition` indicates different states of transition.
`userSelectedOption` is the options user select in one dialogue.
`inOptionMode` indicates whether the user needs to select options.
Example:

    { para = 1
    , num_of_char = 0
    , char_lasttime = 0.0
    , isFinished = False
    , transition = EndTransition
    , userSelectedOption = Nothing
    , inOptionMode = False
    }

-}
type alias Data =
    { para : Int
    , num_of_char : Int
    , char_lasttime : Float
    , isFinished : Bool
    , transition : TransitionState
    , userSelectedOption : Maybe Int
    , inOptionMode : Bool
    , coderain : Coderain
    }


{-| Definition of a dialogue.
`speaker`: the one who says the words
`text`: the words said by the speaker

example:
{ speaker = "John"
, text = "Hello"
}

-}
type alias DialogueLine =
    { speaker : String
    , text : String
    }


{-| StartTransition means the time when the transition starts.
EndTransition means the transition ends.
-}
type TransitionState
    = StartTransition Float
    | EndTransition
