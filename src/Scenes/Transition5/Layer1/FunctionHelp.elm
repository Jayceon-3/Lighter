module Scenes.Transition5.Layer1.FunctionHelp exposing (dialogueLine, enterButton, handleOptionSelect, inEnterButton, newDialogueLine, update_data, userOptions)

{-|


# FunctionHelp

The transition5 update and render helper functions.

@docs dialogueLine, enterButton, handleOptionSelect, inEnterButton, newDialogueLine, update_data, userOptions

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (MMsg, SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import Scenes.Transition5.Layer1.DataHelp exposing (..)
import Scenes.Transition5.SceneBase exposing (..)


selectedOptionText : Data -> String
selectedOptionText data =
    case data.userSelectedOption of
        Just index ->
            userOptions (data.para - 1)
                |> List.drop index
                |> List.head
                |> Maybe.withDefault ""

        Nothing ->
            ""


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
            { data | char_lasttime = now, num_of_char = data.num_of_char + 1 }

        else
            { data | isFinished = True }

    else
        data


{-| This function contains dialogues used in this transition, including different speakers and their words.
-}
dialogueLine : Data -> DialogueLine
dialogueLine data =
    case data.para of
        1 ->
            { speaker = "boss", text = "Now that you've won, you can do whatever you want. \nI probably won't see our new world...... \nBut you can't stop it, you can't stop all this......" }

        2 ->
            { speaker = "nova", text = "You did it! Humanity finally returns to the path of Ascension...... \nNow send me the CEO's live cortical scans. \nThey're the key to our new world!" }

        3 ->
            { speaker = "user", text = selectedOptionText data }

        4 ->
            { speaker = "nova", text = "...... what? What do you mean?" }

        5 ->
            { speaker = "user", text = selectedOptionText data }

        6 ->
            { speaker = "", text = "" }

        _ ->
            { speaker = "", text = "" }


{-| This function contains the text of options.
-}
userOptions : Int -> List String
userOptions para =
    case para of
        3 ->
            [ "Then you become the new 'leader'.", "No." ]

        5 ->
            [ "You both forge cages. Both his perfect order and your mechanical godhood.", "Neither of you treats human as HUMAN." ]

        _ ->
            []


{-| This function draws the confirm button
-}
enterButton : Color.Color -> Renderable
enterButton color =
    group []
        [ P.rectCentered ( 960, 540 ) ( 300, 150 ) 0 color
        , P.textboxCentered ( 960, 540 ) 50 "CONFIRM" "consolas" Color.white
        , P.textboxCentered ( 960, 650 ) 30 "Are you sure to delete the data?" "consolas" Color.grey
        ]


{-| This function judges whether the mouse position is in the confirm button.
-}
inEnterButton : ( Float, Float ) -> Bool
inEnterButton ( x, y ) =
    let
        centerX =
            960

        centerY =
            540

        halfW =
            150

        halfH =
            75
    in
    abs (x - centerX) <= halfW && abs (y - centerY) <= halfH


{-| This function contains new dialogues used in this transition, including different speakers and their words.
-}
newDialogueLine : Data -> DialogueLine
newDialogueLine data =
    case data.para of
        1 ->
            { speaker = "default", text = "           ......I'm back?" }

        2 ->
            { speaker = "default", text = "It is not the body's death that marks the end,\nbut the silence of a soul no longer free to be human." }

        _ ->
            { speaker = "", text = "" }
