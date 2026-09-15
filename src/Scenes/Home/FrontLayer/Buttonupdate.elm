module Scenes.Home.FrontLayer.Buttonupdate exposing (updateButtondata)

{-|


# Buttonupdate

Functions to update button data in the Home scene.

@docs updateButtondata

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.Components.Player.Doublejump exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)
import Scenes.Home.FrontLayer.DataHelp exposing (ButtonData, Buttonstate(..), ScreenState(..))


{-| Data structure for single button data. Copied from init to avoid import loop.
-}
type alias ButtonData =
    { position : ( Float, Float )
    , size : ( Float, Float )
    , state : Buttonstate
    , inittime : Float
    }


scope : ButtonData -> ( ( Float, Float ), ( Float, Float ) )
scope data =
    let
        ( x0, y0 ) =
            data.position

        ( w, h ) =
            data.size

        x1 =
            x0 - w / 2

        x2 =
            x0 + w / 2

        y1 =
            y0 - h / 2

        y2 =
            y0 + h / 2
    in
    ( ( x1, x2 ), ( y1, y2 ) )


judge : ButtonData -> ( Float, Float ) -> Bool
judge data ( x, y ) =
    let
        ( ( x1, x2 ), ( y1, y2 ) ) =
            scope data
    in
    x >= x1 && x <= x2 && y >= y1 && y <= y2


{-| Update the button data based on the current position and state.
-}
updateButtondata : ButtonData -> Env SceneCommonData UserData -> ( Float, Float ) -> ButtonData
updateButtondata data env ( x, y ) =
    if data.state == Off && judge data ( x, y ) then
        { data | state = On, inittime = env.globalData.currentTimeStamp }

    else if data.state == On && not (judge data ( x, y )) then
        { data | state = Off, inittime = env.globalData.currentTimeStamp }

    else
        data
