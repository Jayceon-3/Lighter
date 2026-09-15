module Scenes.Home.FrontLayer.RenderHelp exposing (setButtonX, setButtonY, buttonWidth, buttonHeight, gameButtonX, gameButtonY, homePage, viewButton, logoPage)

{-|


# RenderHelp

Render helper functions for the Home Front Layer.

@docs setButtonX, setButtonY, buttonWidth, buttonHeight, gameButtonX, gameButtonY, homePage, viewButton, logoPage

-}

import Color
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import REGL.Effects exposing (alphamult)
import Scenes.Home.FrontLayer.DataHelp exposing (..)
import Scenes.Home.FrontLayer.SpecialEffect exposing (flickerOn, gen_text, jitterOffset, shouldJitter)
import Scenes.Home.SceneBase exposing (..)


{-| X coordinate for the set button
-}
setButtonX : Float
setButtonX =
    1220 + 100


{-| Y coordinate for the set button
-}
setButtonY : Float
setButtonY =
    700


{-| Decide the width of buttons.
-}
buttonWidth : Float
buttonWidth =
    210


{-| Height of the buttons
-}
buttonHeight : Float
buttonHeight =
    80


{-| X coordinate for the game button
-}
gameButtonX : Float
gameButtonX =
    950


{-| Y coordinate for the game button
-}
gameButtonY : Float
gameButtonY =
    700


{-| Render the home page with buttons and background.
-}
homePage : Env SceneCommonData UserData -> Data -> Renderable
homePage env data =
    let
        set =
            viewButton setButtonX setButtonY data.size_set "helpBT"

        game =
            viewButton gameButtonX gameButtonY data.size_game "gameBT"

        demo =
            let
                mp =
                    env.globalData.mousePos
            in
            if abs (Tuple.first mp - 1800) <= 100 && abs (Tuple.second mp - 1000) <= 50 then
                P.textboxCentered ( 1800, 1000 ) 40 "Demo" "consolas" Color.white

            else
                P.textboxCentered ( 1800, 1000 ) 40 "Demo" "consolas" Color.lightPurple

        background =
            P.centeredTexture ( 960, 540 ) ( 1920, 1280 ) 0 "home"

        now =
            env.globalData.currentTimeStamp

        isOn =
            flickerOn now

        alpha =
            if isOn then
                1.0

            else
                0

        jitter =
            if shouldJitter now then
                jitterOffset now

            else
                0

        titleX =
            1100 + jitter

        title =
            group [ alphamult alpha ] [ P.centeredTexture ( titleX, 350 ) ( 925 * 0.9, 350 * 0.9 ) 0 "name" ]
    in
    group [ alphamult 1 ]
        [ background
        , title
        , set
        , game
        , demo
        ]


{-| Render logo page.
-}
logoPage : Env SceneCommonData UserData -> Data -> Renderable
logoPage env data =
    let
        elapsed =
            (env.globalData.currentTimeStamp - data.startTime) / 1000

        fadeIn =
            5.0

        hold =
            1.0

        fadeOut =
            2.0

        total =
            fadeIn + hold + fadeOut

        alpha =
            if elapsed < fadeIn then
                elapsed / fadeIn

            else if elapsed < fadeIn + hold then
                1.0

            else if elapsed < total then
                1.0 - (elapsed - fadeIn - hold) / fadeOut

            else
                0.0

        background =
            P.rect ( 0, 0 ) ( 1920, 1080 ) Color.black

        logo =
            P.centeredTexture ( 960, 540 ) ( 400, 572 ) 0 "logo"

        slogan =
            P.textbox ( 545, 900 ) 50 (gen_text data.num_of_char) "consolas" Color.white
    in
    group []
        [ background
        , group [ alphamult alpha ] [ logo, slogan ]
        ]


{-| Render the button with given magnification
-}
viewButton : Float -> Float -> Float -> String -> Renderable
viewButton cx cy textScale label =
    group []
        [ P.centeredTexture ( cx, cy )
            ( 270 * textScale * 0.7, 145 * textScale * 0.7 )
            0
            label
        ]
