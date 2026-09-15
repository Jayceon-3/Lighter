module SceneProtos.Game.Components.DW.DWhelp exposing (Data, help_y_camera, help_stat, stayClose, judgeFaceDirection, help_update, updateHelper)

{-|


# DWhelp

Helper functions fot DW.

@docs Data, help_y_camera, help_stat, stayClose, judgeFaceDirection, help_update, updateHelper

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.Common exposing (Camera)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.DW.RenderKeyNum exposing (updateKeyPos)
import SceneProtos.Game.Components.DW.VisualDW exposing (genRandomNum, refreshSurroundedTiles)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection, Tile)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.Components.Player.Doublejump exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.Components.Player.Playerlogic exposing (a, g, resolveCollisions)
import SceneProtos.Game.Components.Weapon.MechanicalArm exposing (distance)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The DW component data structure.
-}
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


{-| The function to adjust y coordinate of the camera.
-}
help_y_camera : State -> Data -> Float -> Float -> Float
help_y_camera stat data dt y1 =
    if stat.s_pressed then
        min 1855 (max 550 (min (data.dwcamera.y + 1500 * dt / 1000) (y1 - 200 + 300)))

    else
        min 1855 (max 550 (max (data.dwcamera.y - 1500 * dt / 1000) (y1 - 200)))


{-| The helper function of state update.
-}
help_stat : State -> Float -> Float -> Float -> Float -> Float -> State
help_stat sta x1 y1 vx1 vy1 vx2 =
    if sta.a_pressed || sta.d_pressed then
        { sta | position = ( x1, y1 ), vx = vx2, vy = vy1 }

    else
        { sta | position = ( x1, y1 ), vx = vx1, vy = vy1 }


{-| The function to implement distance restriction.
-}
stayClose : Float -> ( Float, Float ) -> ( Float, Float ) -> Float
stayClose dwHP dwPos playerPos =
    let
        d =
            distance dwPos playerPos

        decreaseSpeed =
            if d <= 400 then
                0

            else if d <= 600 then
                (d - 200) / 2000

            else
                100

        newHp =
            max (dwHP - decreaseSpeed) 0
    in
    newHp


{-| The helper function to judge dw face direction
-}
judgeFaceDirection : ( Float, Float ) -> ( Float, Float ) -> Float
judgeFaceDirection mousePos currenPos =
    let
        ( x0, y0 ) =
            mousePos

        ( x, y ) =
            currenPos

        dir =
            if x0 - x >= 0 then
                1

            else
                -1
    in
    dir



-- Tuple.first env.globalData.userData.canvas_mouse_pos - Tuple.first data.state.position


{-| The helper function of DW update.
-}
help_update : UserEvent -> Env SceneCommonData UserData -> Data -> BaseData -> ( ( GlobalData UserData, UserData ), ( Bool, State ) ) -> ( ( Float, Float ), ( Float, Float ) ) -> Float -> ( Float, Float ) -> Camera -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
help_update evnt env data basedata ( ( gdata, udata ), ( newdw, sta ) ) ( ( w, h ), ( vx, vy ) ) dir ( x, y ) oldcamera =
    if env.globalData.userData.dw then
        case evnt of
            KeyDown 81 ->
                if data.keyAnimation then
                    ( ( data, basedata ), [], ( env, False ) )

                else
                    ( ( data, basedata ), [ Parent <| SOMMsg <| SOMSaveGlobalData ], ( { env | globalData = { gdata | userData = { udata | dw = newdw } } }, False ) )

            Tick dt ->
                let
                    ( x1, y1 ) =
                        ( x + vx * dt / 1000 * dir, y + vy * dt / 1000 )

                    ( g, a ) =
                        ( 1500, 1500 )

                    ( vx1, vx2, vy1 ) =
                        ( max 0 (vx - a * dt / 1000), min 600 (vx + a * dt / 1000), vy + g * dt / 1000 )

                    stat =
                        help_stat sta x1 y1 vx1 vy1 vx2

                    statFixed =
                        resolveCollisions stat data.pendingCollisions

                    olduserdata =
                        env.globalData.userData

                    newFaceDir =
                        judgeFaceDirection env.globalData.userData.canvas_mouse_pos data.state.position

                    time =
                        floor env.globalData.currentTimeStamp

                    timeSec =
                        floor (toFloat time / 1000)

                    newTiles =
                        refreshSurroundedTiles data.tiles data.state.position time

                    ( newKeyPos, judge ) =
                        if data.keyAnimation then
                            updateKeyPos env dt data

                        else
                            ( data.currentKeyPos, False )
                in
                updateHelper env data basedata dt statFixed ( gdata, udata ) ( ( x, y ), ( x1, y1 ), ( w, h ) ) ( newdw, stat ) ( timeSec, time ) ( newFaceDir, newTiles ) ( newKeyPos, judge ) ( olduserdata, oldcamera )

            KeyDown 65 ->
                ( ( { data | state = { sta | a_pressed = True, direction = -1, vx = min sta.vx 100 } }, basedata ), [], ( env, False ) )

            KeyUp 65 ->
                ( ( { data | state = { sta | a_pressed = False } }, basedata ), [], ( env, False ) )

            KeyDown 68 ->
                ( ( { data | state = { sta | d_pressed = True, direction = 1, vx = min sta.vx 100 } }, basedata ), [], ( env, False ) )

            KeyUp 68 ->
                ( ( { data | state = { sta | d_pressed = False } }, basedata ), [], ( env, False ) )

            KeyDown 87 ->
                if can_jump sta then
                    ( ( { data | state = { sta | canjump = sta.canjump - 1, vy = -550, position = ( Tuple.first sta.position, Tuple.second sta.position - 2 ) } }, basedata ), double_jump_msg sta, ( env, False ) )

                else
                    ( ( data, basedata ), [], ( env, False ) )

            KeyDown 83 ->
                ( ( { data | state = { sta | s_pressed = True } }, basedata ), [], ( env, False ) )

            KeyUp 83 ->
                ( ( { data | state = { sta | s_pressed = False } }, basedata ), [], ( env, False ) )

            _ ->
                ( ( data, basedata ), [], ( env, False ) )

    else
        case evnt of
            KeyDown 81 ->
                ( ( { data | dwcamera = env.globalData.camera }, basedata )
                , [ Parent <| SOMMsg <| SOMSaveGlobalData ]
                , ( { env | globalData = { gdata | userData = { udata | dw = newdw } } }, False )
                )

            _ ->
                ( ( data, basedata ), [], ( env, False ) )


{-| Another helper function of DW update.
-}
updateHelper : Env SceneCommonData UserData -> Data -> BaseData -> Float -> State -> ( GlobalData UserData, UserData ) -> ( ( Float, Float ), ( Float, Float ), ( Float, Float ) ) -> ( Bool, State ) -> ( Int, Int ) -> ( Float, List ( Int, Int, Tile ) ) -> ( ( Float, Float ), Bool ) -> ( UserData, Camera ) -> ( ( Data, BaseData ), List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), ( Env SceneCommonData UserData, Bool ) )
updateHelper env data basedata dt statFixed ( gdata, udata ) ( ( x, y ), ( x1, y1 ), ( w, h ) ) ( newdw, stat ) ( timeSec, time ) ( newFaceDir, newTiles ) ( newKeyPos, judge ) ( olduserdata, oldcamera ) =
    if data.state.hp == 0 then
        ( ( data, basedata ), [ Parent <| SOMMsg <| SOMSaveGlobalData ], ( { env | globalData = { gdata | userData = { udata | dw = newdw } } }, False ) )

    else if data.state.keyNum == 3 && data.keyAnimation == False then
        ( ( data, basedata ), [ Other ( "Interface", WinMsg ) ], ( env, False ) )

    else if modBy 3 timeSec == 0 && (abs ((toFloat time / 1000) - toFloat timeSec) <= 0.04) && newTiles /= data.tiles then
        ( ( { data | state = { statFixed | weaponDir = newFaceDir }, pendingCollisions = [], dwcamera = { oldcamera | x = max 965 (min 3835 x1), y = help_y_camera stat data dt y1 } }, basedata )
        , [ Other ( "Map", DWCheckCollisionMsg { x = x, y = y, x1 = x1, y1 = y1, w = w, h = h } )

          -- Other ( "Enemy", PlayerStateMsg statFixed )
          , Other ( "Map", PlayerStateMsg statFixed )
          , Other ( "Particle", PlayerStateMsg statFixed )
          , Parent <| SOMMsg SOMSaveGlobalData
          ]
        , ( { env | globalData = { gdata | camera = data.dwcamera, userData = { olduserdata | canvas_mouse_pos = screentocanvas env.globalData.camera env.globalData.mousePos } } }, False )
        )

    else
        ( ( { data
                | state = { statFixed | weaponDir = newFaceDir }
                , pendingCollisions = []
                , dwcamera = { oldcamera | x = max 965 (min 3835 x1), y = help_y_camera stat data dt y1 }
                , currentKeyPos = newKeyPos
                , keyAnimation = judge
            }
          , basedata
          )
        , [ Other ( "Map", DWCheckCollisionMsg { x = x, y = y, x1 = x1, y1 = y1, w = w, h = h } )

          -- Other ( "Enemy", PlayerStateMsg statFixed )
          , Other ( "Particle", PlayerStateMsg statFixed )
          , Other ( "Player", KeyAnimationMsg data.keyAnimation )
          , Parent <| SOMMsg SOMSaveGlobalData
          ]
        , ( { env | globalData = { gdata | camera = data.dwcamera, userData = { olduserdata | canvas_mouse_pos = screentocanvas env.globalData.camera env.globalData.mousePos } } }, False )
        )
