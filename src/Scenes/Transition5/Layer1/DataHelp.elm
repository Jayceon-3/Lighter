module Scenes.Transition5.Layer1.DataHelp exposing (Data, DialogueLine, TransitionState(..), DialoguePhase(..))

{-|


# DataHelp

Functions for initializing transition5.

@docs Data, DialogueLine, TransitionState, DialoguePhase

-}

import Scenes.Transition1.Layer1.Grid exposing (Coderain)


{-| Data structure for the front layer of the transition5 scene.
`para` indicates the current order of paragraphs.
`num_of_char` is the number of characters currently displayed.
`char_lasttime` is the last time a character was added.
`isFinished` indicates whether the dialogue is finished.
`transition` indicates different states of transition.
`userSelectedOption` is the options user select in one dialogue.
`inOptionMode` indicates whether the user needs to select options.
`enterBtnStartTime` is the time when enter button is pressed.
`phase` indicates the current phase of dialogue.
Example:

    { para = 1
    , num_of_char = 0
    , char_lasttime = 0.0
    , isFinished = False
    , transition = EndTransition
    , userSelectedOption = Nothing
    , inOptionMode = False
    , enterBtnStartTime = Nothing
    , phase = NormalPhase
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
    , enterBtnStartTime : Maybe Float
    , phase : DialoguePhase
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
SecondTransition means the time when the the second transition starts
-}
type TransitionState
    = StartTransition Float
    | EndTransition
    | SecondTransition Float


{-| Normal phase demonstrate dialogues. After transition phase demonstrate narratives.
-}
type DialoguePhase
    = NormalPhase
    | AfterTransitionPhase
