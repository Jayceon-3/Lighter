module SceneProtos.Game.Components.Interface.RenderHelp exposing (interfaceRender, adjustVolume, inExit, inExitPause)

{-|


# RenderHelp

Functions for rendering the interface in the game.

@docs interfaceRender, adjustVolume, inExit, inExitPause

-}

import Color
import Lib.UserData exposing (UserData)
import Messenger.Audio.Base exposing (AudioOption(..), AudioTarget(..))
import Messenger.Base exposing (Env, UserEvent(..))
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Camera, Renderable, group)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data structure for the interface component. Copied from the Model to avoid import loop.
-}
type alias Data =
    { id : Int
    , ty : String
    , isDead : Bool
    , isHelpFolded : Bool
    , isWin : Bool
    , timeLeft : Float
    }


{-| This function is used to render the components of interface.
-}
interfaceRender : Env SceneCommonData UserData -> Data -> BaseData -> ( Renderable, Int )
interfaceRender env data basedata =
    let
        camera =
            env.globalData.camera

        timeText =
            timeRender camera env.globalData.userData.currentlevel data.timeLeft

        death =
            resultRender camera "You Failed" Color.red "Press 'Enter' to try again"

        win =
            resultRender camera "Mission Accomplished" Color.green "Press 'Enter' to next level"

        pause =
            pasueRender camera

        guide =
            guideRender camera

        symbol =
            guideSymbol camera

        hint =
            functionRender ( camera.x + 630, camera.y - 460 ) ( 500, 80 ) (Color.rgba 1 1 1 0.7) 30 "Press 'H' to unfold Quick Help" Color.blue

        volume =
            volumeRender env

        exit =
            crossButton camera
    in
    if data.isDead then
        ( group [] [ death, exit ], 100 )

    else if data.isWin then
        ( group [] [ win, exit ], 100 )

    else if basedata.isPaused then
        ( group [] [ guide, symbol, timeText, pause, volume, exit ], 100 )

    else if data.isHelpFolded then
        ( group [] [ hint, symbol, timeText ], 99 )

    else
        ( group [] [ guide, symbol, timeText ], 99 )


resultRender : Camera -> String -> Color.Color -> String -> Renderable
resultRender camera mainText mainColor hintText =
    let
        mainTextPos =
            ( camera.x, camera.y - 100 )
    in
    group []
        [ P.rectCentered ( camera.x, camera.y ) ( 1920, 1080 ) 0 (Color.rgba 0 0 0 0.5)
        , P.textboxCentered mainTextPos 100 mainText "consolas" mainColor
        , P.textboxCentered ( camera.x, camera.y ) 50 hintText "consolas" Color.grey
        ]


pasueRender : Camera -> Renderable
pasueRender camera =
    let
        pauseTextPos =
            ( camera.x, camera.y - 100 )

        pauseImagePos1 =
            ( camera.x - 30, camera.y )

        pauseImagePos2 =
            ( camera.x + 30, camera.y )

        hintTextPos =
            ( camera.x, camera.y + 100 )

        color =
            Color.rgb 0.0 0.941 0.988
    in
    group []
        [ P.rectCentered ( camera.x, camera.y ) ( 1920, 1080 ) 0 (Color.rgba 0 0 0 0.5)
        , P.textboxCentered pauseTextPos 80 "Paused" "consolas" color
        , P.rectCentered pauseImagePos1 ( 25, 80 ) 0 color
        , P.rectCentered pauseImagePos2 ( 25, 80 ) 0 color
        , P.textboxCentered hintTextPos 50 "Press 'ESC' to resume" "consolas" Color.grey
        ]


timeRender : Camera -> Int -> Float -> Renderable
timeRender camera level timeLeft =
    if level == 1 then
        P.empty

    else
        group []
            [ P.rectCentered ( camera.x, camera.y - 500 ) ( 450, 80 ) 0 (Color.rgba 0 0 0 0.7)
            , P.textboxCentered
                ( camera.x, camera.y - 500 )
                50
                ("Time Left: " ++ String.fromInt (ceiling timeLeft) ++ " s")
                "consolas"
                Color.lightRed
            ]


guideRender : Camera -> Renderable
guideRender camera =
    group []
        [ P.rectCentered ( camera.x + 630, camera.y - 400 ) ( 500, 200 ) 0 (Color.rgba 1 1 1 0.7)
        , P.textboxCentered ( camera.x + 630, camera.y - 470 ) 30 "Quick Help" "consolas" Color.black
        , P.textboxCentered ( camera.x + 630, camera.y - 335 ) 30 "Press 'H' to fold" "consolas" Color.blue
        , P.textboxCentered ( camera.x + 630, camera.y - 400 )
            25
            "Long press Left Mouse Button: Laser\nRight Mouse Button: Place the Shield\nEsc: Pause\nR: Get Unstuck"
            "consolas"
            Color.black
        ]


functionRender : ( Float, Float ) -> ( Float, Float ) -> Color.Color -> Float -> String -> Color.Color -> Renderable
functionRender ( x, y ) ( w, h ) bgColor fontSize text color =
    group []
        [ P.rectCentered ( x, y ) ( w, h ) 0 bgColor
        , P.textboxCentered ( x, y ) fontSize text "consolas" color
        ]


guideSymbol : Camera -> Renderable
guideSymbol camera =
    group []
        [ P.centeredTexture ( camera.x + 400, camera.y + 470 ) ( 50, 75 ) 0 "lmb"
        , P.textboxCentered ( camera.x + 400, camera.y + 420 ) 20 "Shoot" "consolas" Color.white
        , P.centeredTexture ( camera.x + 550, camera.y + 470 ) ( 50, 75 ) 0 "rmb"
        , P.textboxCentered ( camera.x + 550, camera.y + 420 ) 20 "Mechanical Arm" "consolas" Color.white
        , P.centeredTexture ( camera.x + 700, camera.y + 470 ) ( 80, 80 ) 0 "sd"
        , P.textboxCentered ( camera.x + 700, camera.y + 420 ) 20 "E" "consolas" Color.white
        , P.centeredTexture ( camera.x + 850, camera.y + 470 ) ( 80, 80 ) 0 "dw"
        , P.textboxCentered ( camera.x + 850, camera.y + 420 ) 20 "Q" "consolas" Color.white
        ]


volumeRender : Env SceneCommonData UserData -> Renderable
volumeRender env =
    let
        camera =
            env.globalData.camera

        volumex =
            camera.x - 250 + 500 * env.globalData.volume

        volumeHint =
            P.textboxCentered ( camera.x, camera.y + 300 ) 30 "Press 'Up'/'Down' to adjust volume" "consolas" Color.grey

        volumenbar1 =
            P.rect ( camera.x - 250, camera.y + 360 ) ( 500, 12 ) Color.grey

        volumenbar2 =
            P.rect ( camera.x - 250, camera.y + 360 ) ( volumex - (camera.x - 250), 12 ) (Color.rgb 0.0 0.941 0.988)
    in
    group []
        [ volumenbar1
        , volumenbar2
        , volumeHint
        ]


{-| This function enables the user to adjust volume.
-}
adjustVolume : Float -> Env SceneCommonData UserData -> Data -> BaseData -> ( ( Data, BaseData ), List (Msg othertar msg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
adjustVolume delta env data basedata =
    let
        currentVolume =
            env.globalData.volume

        newVolume =
            clamp 0 1 (currentVolume + delta)
    in
    ( ( data, basedata )
    , [ Parent (SOMMsg (SOMSetVolume newVolume)) ]
    , ( env, False )
    )


crossButton : Camera -> Renderable
crossButton camera =
    group []
        [ P.rectCentered ( camera.x - 850, camera.y - 460 ) ( 50, 50 ) 0 Color.white
        , P.rectCentered ( camera.x - 850, camera.y - 460 ) ( 40, 40 ) 0 Color.black
        , P.rectCentered ( camera.x - 850, camera.y - 460 ) ( 50, 5 ) 0.785 Color.white
        , P.rectCentered ( camera.x - 850, camera.y - 460 ) ( 50, 5 ) 2.356 Color.white
        ]


{-| This function handles the exit judgement.
-}
inExit : ( Float, Float ) -> Env SceneCommonData UserData -> Bool
inExit ( x, y ) env =
    let
        camera =
            env.globalData.camera

        centerX =
            camera.x - 850

        centerY =
            camera.y - 460

        halfW =
            25

        halfH =
            25
    in
    x
        >= centerX
        - halfW
        && x
        <= centerX
        + halfW
        && y
        >= centerY
        - halfH
        && y
        <= centerY
        + halfH


{-| This function handles the exit judgement when paused.
-}
inExitPause : ( Float, Float ) -> Bool
inExitPause ( x, y ) =
    let
        centerX =
            115

        centerY =
            60

        halfW =
            25

        halfH =
            25
    in
    x
        >= centerX
        - halfW
        && x
        <= centerX
        + halfW
        && y
        >= centerY
        - halfH
        && y
        <= centerY
        + halfH
