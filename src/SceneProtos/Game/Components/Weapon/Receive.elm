module SceneProtos.Game.Components.Weapon.Receive exposing (handle_dropmsg, scatterBullet)

{-|


# Receive

This module contains functions for the update when player receive the drop.

@docs handle_dropmsg, scatterBullet

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.Common exposing (Camera)
import SceneProtos.Game.Components.Bullet.Init exposing (BulletType(..), SingleBullet)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..))
import SceneProtos.Game.Components.Map.Init as MapInit exposing (Tile)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, Scatter, Shield, ShieldState(..), State)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


type alias Data =
    { id : Int
    , ty : String
    , state : State
    , shield : Shield
    , mechanicalArm : MechanicalArm
    , initPressedTime : Float
    , deltaPosition : Float
    , isLineOn : Bool
    , isMousePressed : Bool
    , tiles : List ( Int, Int, Tile )
    , scatter : Scatter
    }


{-| Help function for drop msg.
-}
handle_dropmsg : State -> Droptype -> Data -> BaseData -> Env SceneCommonData UserData -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), Env SceneCommonData UserData )
handle_dropmsg currentState droptype data basedata env =
    case droptype of
        Energy ->
            let
                newstate =
                    { currentState | energy = 100 }
            in
            ( ( { data | state = newstate }, basedata ), [], env )

        Scatterbullet ->
            let
                oldscatter =
                    data.scatter

                newscatter =
                    { oldscatter | ability = True, starttime = env.globalData.currentTimeStamp }
            in
            ( ( { data | scatter = newscatter }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


{-| Function to generate scatter bullet.
-}
scatterBullet : ( Float, Float ) -> Float -> Float -> ( SingleBullet, SingleBullet )
scatterBullet position angle direction =
    let
        ( x, y ) =
            position

        ( x1, y1 ) =
            ( x + 30 * cos angle * direction, y - 30 * sin angle * direction )

        dx =
            10

        ( x2, y2 ) =
            ( x + 30 * cos (angle + pi / 100) * direction, y - 30 * sin (angle + pi / 100) * direction )

        bullet2 =
            { position = ( x2, y2 )
            , direction = direction
            , shape = ( 10, 5 )
            , angle = angle + pi / 100
            , bulletType = Ordinary
            , attack = 5
            }

        ( x3, y3 ) =
            ( x + 30 * cos (angle - pi / 100) * direction, y - 30 * sin (angle - pi / 100) * direction )

        bullet3 =
            { position = ( x3, y3 )
            , attack = 5
            , bulletType = Ordinary
            , direction = direction
            , angle = angle - pi / 100
            , shape = ( 10, 5 )
            }
    in
    ( bullet2, bullet3 )
