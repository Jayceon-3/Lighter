module SceneProtos.Game.Components.Weapon.RenderHelper exposing (renderAll)

{-|


# RenderHelper

This module contains functions for the render of weapon.

@docs renderAll

-}

import Color
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import SceneProtos.Game.Components.Map.Init as MapInit exposing (Tile)
import SceneProtos.Game.Components.Player.Coordtransform exposing (screentocanvas)
import SceneProtos.Game.Components.Weapon.Init exposing (MechanicalArm, Scatter, Shield, ShieldState(..), State)
import SceneProtos.Game.Components.Weapon.PredictLine exposing (predictLine)
import SceneProtos.Game.Components.Weapon.WeaponUpdate exposing (decideAngle)
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


renderShield : Data -> List Renderable
renderShield data =
    if data.shield.shieldState /= Unused then
        [ P.rectCentered data.shield.position ( 30, 60 ) data.shield.angle Color.brown ]

    else
        []


renderPredictLine : Env SceneCommonData UserData -> Data -> List ( Int, Int, Tile ) -> List Renderable
renderPredictLine env data tiles =
    if data.isLineOn then
        let
            angle =
                decideAngle env.globalData.userData.canvas_mouse_pos data.state.position
        in
        predictLine data.state.direction angle data.state.position tiles

    else
        []


renderWeaponAndEnergy : Env SceneCommonData UserData -> Data -> Float -> Float -> List Renderable
renderWeaponAndEnergy env data weaponDir deltaT =
    let
        length =
            min ((deltaT / 1.5) * 30) 30

        length1 =
            min length ((data.state.energy / 100) * 30)

        length2 =
            (data.state.energy / 100) * 100

        gunAngle =
            if weaponDir >= 0 then
                data.state.angle - (pi / 5)

            else
                data.state.angle + (pi / 5)

        gunRender dir =
            if dir >= 0 then
                [ P.centeredTexture data.state.position ( 70, 50 ) gunAngle "gun" ]

            else
                [ P.centeredTexture data.state.position ( -70, 50 ) gunAngle "gun" ]

        ( x0, y0 ) =
            data.state.position

        energyBarPos =
            ( x0 + weaponDir * 5 * cos data.state.angle, y0 - weaponDir * 10 * sin data.state.angle )
    in
    if data.initPressedTime /= 0 then
        gunRender weaponDir
            ++ [ P.rectCentered data.state.position ( length1 / 1.3, 5 ) data.state.angle Color.yellow
               , renderBatteryBar env (screentocanvas env.globalData.camera ( 50, 1000 )) length2
               ]

    else
        gunRender weaponDir
            ++ [ P.rect (screentocanvas env.globalData.camera ( 50, 1000 )) ( length2, 40 ) Color.green
               , renderBatteryBar env (screentocanvas env.globalData.camera ( 50, 1000 )) length2
               ]



-- ++ [ P.rectCentered data.state.position ( length1, 20 ) data.state.angle Color.yellow ]


{-| Help function for weapon render.
-}
renderAll : Env SceneCommonData UserData -> Data -> Float -> Float -> List ( Int, Int, Tile ) -> ( Renderable, Int )
renderAll env data weaponDir deltaT tiles =
    let
        weaponElement =
            renderWeaponAndEnergy env data weaponDir deltaT

        shieldElement =
            renderShield data

        predictLineElement =
            renderPredictLine env data tiles
    in
    ( group [] (weaponElement ++ predictLineElement), 60 )


renderBatteryBar : Env SceneCommonData UserData -> ( Float, Float ) -> Float -> Renderable
renderBatteryBar env ( x, y ) length2 =
    let
        time =
            env.globalData.sceneStartTime / 300

        percent =
            clamp 0 1 (length2 / 100)

        baseColor =
            if percent == 1 then
                Color.green

            else if percent > 0.6 then
                Color.rgb
                    (1 - (percent - 0.6) / 0.4 * 0.8)
                    1
                    (0 + (percent - 0.6) / 0.4 * 0.5)

            else if percent > 0.3 then
                Color.rgb
                    1
                    ((percent - 0.3) / 0.3)
                    0

            else
                Color.rgb
                    (0.5 + 0.5 * (percent / 0.3))
                    0
                    0

        pulseIntensity =
            if percent >= 0.98 then
                0.5 + 0.5 * sin (time / 200)

            else
                0

        finalColor =
            if pulseIntensity > 0 then
                Color.green
                -- Color.rgb
                --     (min 1 (0.8 + pulseIntensity * 0.2))
                --     (min 1 (0.9 + pulseIntensity * 0.1))
                --     (min 1 (0.7 + pulseIntensity * 0.3))

            else
                baseColor

        energyFlow =
            if percent >= 0.98 then
                let
                    offset =
                        modBy 20 (round (time / toFloat 50))
                in
                [ P.rect
                    ( x + toFloat offset - 20, y )
                    ( 15, 40 )
                    (Color.rgba 0.8 1 0.8 0.7)
                ]

            else
                []
    in
    group []
        ([ P.rect ( x, y ) ( 100, 40 ) (Color.rgb 0.2 0.2 0.2)
         , P.rect ( x + 100 + 4, y + 10 ) ( 8, 20 ) (Color.rgb 0.5 0.5 0.5)
         , P.rect ( x, y ) ( length2, 40 ) finalColor
         ]
            ++ energyFlow
        )
