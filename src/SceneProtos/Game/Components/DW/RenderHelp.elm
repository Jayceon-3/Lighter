module SceneProtos.Game.Components.DW.RenderHelp exposing (renderDW)

{-|


# RenderHelp

Helper function to render DW.

@docs renderDW

-}

import Color
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.Coordinate.Camera exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Camera, Renderable, group)
import Random
import SceneProtos.Game.Components.DW.KeyGuide exposing (getKeyBlockPos, renderKeyGuide)
import SceneProtos.Game.Components.DW.RenderKeyNum exposing (keyAnimation, keyNumRender, updateKeyPos)
import SceneProtos.Game.Components.Drop.Dropview exposing (genColor)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection(..), Tile, TileKind(..))
import SceneProtos.Game.Components.Player.Coordtransform exposing (screentocanvas)
import SceneProtos.Game.Components.Player.Init exposing (Spritetype(..), State)
import SceneProtos.Game.Components.Player.Playerview exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)



--The DW component data structure.


type alias Data =
    { id : Int
    , ty : String
    , state : State
    , pendingCollisions : List CollisionDirection
    , dwcamera : Camera
    , playerpos : ( Float, Float )
    , tiles : List ( Int, Int, Tile )
    , keyPos : Maybe ( ( Float, Float ), ( Float, Float ), ( Float, Float ) )
    , currentKeyPos : ( Float, Float )
    , keyAnimation : Bool
    }


{-| Helper function to render DW.
-}
renderDW : Env SceneCommonData UserData -> Data -> ( Renderable, Int )
renderDW env data =
    let
        hpNum =
            round data.state.hp

        render =
            [ P.rect (screentocanvas env.globalData.camera ( 50, 900 )) ( data.state.hp / 100 * 200, 30 ) Color.blue
            , P.textbox (screentocanvas env.globalData.camera ( 100, 905 )) 25 (String.fromInt hpNum ++ "/100") "consolas" Color.white

            -- , P.textbox (screentocanvas env.globalData.camera ( 50, 200 )) 40 ("Key Number:" ++ String.fromFloat data.state.keyNum) "consolas" Color.white
            -- , P.textbox env.globalData.userData.canvas_mouse_pos 40 (String.fromFloat (Tuple.first env.globalData.userData.canvas_mouse_pos) ++ " " ++ String.fromFloat (Tuple.second env.globalData.userData.canvas_mouse_pos)) "consolas" Color.white
            , P.circle data.playerpos 600 (genColor 0.9 0.9 1 0.2)
            , P.circle data.playerpos 400 (genColor 0.56 0.93 0.56 0.2)
            ]
                ++ Tuple.first (renderKeyGuide env data.state.position data.keyPos)
                ++ keyNumRender env data
                ++ keyAnimation data
    in
    if env.globalData.userData.dw then
        if data.state.vy /= 0 then
            jump_run_stay Jump env data.ty data.state render

        else if data.state.vx == 0 then
            jump_run_stay Stay env data.ty data.state render

        else
            jump_run_stay Run env data.ty data.state render

    else
        ( group []
            (keyNumRender env data
                ++ keyAnimation data
            )
        , 8
        )
