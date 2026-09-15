module Scenes.Transition1.Layer1.FunctionHelp exposing (crossButton, dialogueLine, fadeOutAlpha, gen_text, handleOptionSelect, inExit, selectedOptionText, update_data, userOptions)

{-|


# FunctionHelp

The transition1 update and render helper functions.

@docs crossButton, dialogueLine, fadeOutAlpha, gen_text, handleOptionSelect, inExit, selectedOptionText, update_data, userOptions

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (MMsg, SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import Scenes.Transition1.Layer1.DataHelp exposing (Data, DialogueLine, TransitionState(..))
import Scenes.Transition1.SceneBase exposing (..)


{-| This function contains the text of options.
-}
userOptions : Int -> List String
userOptions para =
    case para of
        2 ->
            [ "Who are you?", "Do I die?" ]

        5 ->
            [ "Are you joking?", "Why the anti-fraud software doesn't work?" ]

        _ ->
            []


{-| This function enables user to select the displayed options in storytelling.
-}
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


{-| This function draws the symbol of a cross button.
-}
crossButton : Renderable
crossButton =
    group []
        [ P.rectCentered ( 1850, 80 ) ( 50, 50 ) 0 Color.white
        , P.rectCentered ( 1850, 80 ) ( 40, 40 ) 0 Color.black
        , P.rectCentered ( 1850, 80 ) ( 50, 5 ) 0.785 Color.white
        , P.rectCentered ( 1850, 80 ) ( 50, 5 ) 2.356 Color.white
        ]


{-| This function checks whether the given position is in the exit button.
-}
inExit : ( Float, Float ) -> Bool
inExit ( x, y ) =
    let
        centerX =
            1850

        centerY =
            80

        halfW =
            25

        halfH =
            25
    in
    abs (x - centerX) <= halfW && abs (y - centerY) <= halfH


{-| This function generates text word by word.
-}
gen_text : Int -> String -> String
gen_text num text =
    text
        |> String.toList
        |> List.take num
        |> String.fromList


{-| This function decides the alpha when the scene changes from storytelling to game.
-}
fadeOutAlpha : Float -> Float -> Float
fadeOutAlpha start now =
    let
        duration =
            200

        elapsed =
            clamp 0 duration (now - start)
    in
    elapsed / duration


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


{-| This function contains dialogues used in this transition, including different speakers and their words.
-}
dialogueLine : Data -> DialogueLine
dialogueLine data =
    case data.para of
        1 ->
            { speaker = "nova", text = "Oh, you awoke!" }

        2 ->
            { speaker = "user", text = selectedOptionText data }

        3 ->
            { speaker = "nova", text = "I'm Nova, a mechanical expert." }

        4 ->
            { speaker = "nova", text = "You are invited to our world." }

        5 ->
            { speaker = "user", text = selectedOptionText data }

        6 ->
            { speaker = "nova", text = "I'm serious. \nAs you can see,\nmany people in our world have equipped with prosthesis.\nBut the prosthesis company is trying to control all of us!" }

        7 ->
            { speaker = "nova", text = "I turn to you because \nyou are the one who hasn't been polluted." }

        8 ->
            { speaker = "nova", text = "I'm sorry that there's no time for the whole story. \nHere is the weapon, follow me!" }

        _ ->
            { speaker = "", text = "" }
