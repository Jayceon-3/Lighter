module Scenes.Transition3.Layer1.FunctionHelp exposing (dialogueLine, handleOptionSelect, update_data, userOptions)

{-|


# FunctionHelp

The transition3 update helper functions.

@docs dialogueLine, handleOptionSelect, update_data, userOptions

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (MMsg, SceneOutputMsg(..))
import Scenes.Transition1.Layer1.DataHelp exposing (..)
import Scenes.Transition1.Layer1.FunctionHelp exposing (selectedOptionText)
import Scenes.Transition3.SceneBase exposing (..)


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
            { speaker = "boss", text = "Finally you are here...... \nI know you would beat all the normal people in this building." }

        2 ->
            { speaker = "user", text = selectedOptionText data }

        3 ->
            { speaker = "boss", text = "Look what we have in this world. \nChaotic...inefficient...flawed......" }

        4 ->
            { speaker = "user", text = "It's enough. \nThat can't be the reason \nwhy you control every one." }

        5 ->
            { speaker = "boss", text = "...... you know how fragile humans are, \nyou've seen all of those weak creatures on your way here, right? \nYou should have realized that my AI \nis the only possible answer to us." }

        6 ->
            { speaker = "user", text = selectedOptionText data }

        7 ->
            { speaker = "boss", text = "I remember the guy who helped you. \nNova, that crazy mechanical ascension believer \nI kicked out of the company ten years ago." }

        8 ->
            { speaker = "boss", text = "Look at that ridiculous mechanical arm. \nThat's her so-called 'innovation,' isn't it?" }

        9 ->
            { speaker = "user", text = selectedOptionText data }

        10 ->
            { speaker = "boss", text = "There's no point talking anymore. \nYou're a defective product, destined to be discarded by evolution. \nThe pain won't last long. I'll end it quickly, \nand you'll learn that eternal silence is your only fate." }

        _ ->
            { speaker = "", text = "" }


{-| This function contains the text of options.
-}
userOptions : Int -> List String
userOptions para =
    case para of
        2 ->
            [ "Ah, so you're the dreamer who actually thinks they can rule over humanity.", "Playing mysterious is completely outdated." ]

        6 ->
            [ "Do you mean the thing that sends people off the deep end like that?", "It's you who makes them weak." ]

        9 ->
            [ "You are ridiculous.", "Wait......what?!" ]

        _ ->
            []
