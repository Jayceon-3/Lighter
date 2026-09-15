module Scenes.Transition2.Layer1.FunctionHelp exposing (dialogueLine, handleOptionSelect, update_data, userOptions)

{-|


# FunctionHelp

The transition2 update helper functions.

@docs dialogueLine, handleOptionSelect, update_data, userOptions

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (MMsg, SceneOutputMsg(..))
import Scenes.Transition1.Layer1.DataHelp exposing (..)
import Scenes.Transition1.Layer1.FunctionHelp exposing (selectedOptionText)
import Scenes.Transition2.SceneBase exposing (..)


{-| This function updates text word by word.
-}
update_data : Env SceneCommonData UserData -> Data -> Data
update_data env data =
    let
        line =
            dialogueLine data

        lineLen =
            String.length line.text

        now =
            env.globalData.currentTimeStamp
    in
    if data.isFinished then
        data

    else if now - data.char_lasttime > 60 then
        if data.num_of_char < lineLen then
            { data
                | char_lasttime = now
                , num_of_char = data.num_of_char + 1
            }

        else
            { data | isFinished = True }

    else
        data


{-| This function contains the text of options.
-}
userOptions : Int -> List String
userOptions para =
    case para of
        2 ->
            [ "Yes. Maybe I'm a genius of using it.", "It almost killed me!" ]

        7 ->
            [ "Who on earth are the enemies?", "I saw the enemies bleeding. They are not robots." ]

        9 ->
            [ "You never told me.", "So you made me a killer!" ]

        _ ->
            []


{-| This function resets the inOptionMode to ensure the dialogue moves on smoothly.
-}
handleOptionSelect : Int -> Env SceneCommonData UserData -> Data -> ( Data, List (MMsg LayerTarget LayerMsg SceneMsg UserData), ( Env SceneCommonData UserData, Bool ) )
handleOptionSelect index env data =
    ( { data
        | userSelectedOption = Just index
        , inOptionMode = False
        , para = data.para + 1
        , num_of_char = 0
        , char_lasttime = env.globalData.currentTimeStamp
        , isFinished = False
      }
    , []
    , ( env, False )
    )


{-| This function contains dialogues used in this transition, including different speakers and their words.
-}
dialogueLine : Data -> DialogueLine
dialogueLine data =
    case data.para of
        1 ->
            { speaker = "nova", text = "It seems that you get along well with the mechanical arm." }

        2 ->
            { speaker = "user", text = selectedOptionText data }

        3 ->
            { speaker = "nova", text = "Anyway, we are getting closer to the company.\nThe fight will become more challenging." }

        4 ->
            { speaker = "nova", text = "There's no time to waste! Forge ahead!" }

        5 ->
            { speaker = "user", text = "Wait, Nova.\nI have to figure out \none thing first." }

        6 ->
            { speaker = "nova", text = "What?" }

        7 ->
            { speaker = "user", text = selectedOptionText data }

        8 ->
            { speaker = "nova", text = "They are those driven out of control by the prosthesis." }

        9 ->
            { speaker = "nova", text = selectedOptionText data }

        10 ->
            { speaker = "nova", text = "Actually, the death of the body is not the true end.\nYou save them." }

        11 ->
            { speaker = "nova", text = "Question time is over. We have to move on." }

        12 ->
            { speaker = "nova", text = "I'll stay there to bypass the security lock. Good luck." }

        _ ->
            { speaker = "", text = "" }
