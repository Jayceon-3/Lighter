module SceneProtos.Game.Components.DW.Model exposing (component)

{-| Component model

@docs component

-}

import Color exposing (..)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.Coordinate.Camera exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Camera, group)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.DW.BlockLogic exposing (UpdateKind(..), specialBlockEffect)
import SceneProtos.Game.Components.DW.DWhelp exposing (help_stat, help_update, help_y_camera, stayClose)
import SceneProtos.Game.Components.DW.KeyGuide exposing (getKeyBlockPos, renderKeyGuide)
import SceneProtos.Game.Components.DW.RenderHelp exposing (renderDW)
import SceneProtos.Game.Components.DW.RenderKeyNum exposing (keyAnimation, keyNumRender, updateKeyPos)
import SceneProtos.Game.Components.Map.Init exposing (..)
import SceneProtos.Game.Components.Particle.Particleview exposing (genColor)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.Components.Player.Doublejump exposing (can_jump, double_jump_msg)
import SceneProtos.Game.Components.Player.Init exposing (Spritetype(..), State)
import SceneProtos.Game.Components.Player.Playerlogic exposing (..)
import SceneProtos.Game.Components.Player.Playerview exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data model for the DW (player in the digital world) component.
`id`: Unique identifier for the DW component.
`ty`: Type of the component, typically "DW".
`state`: Current state of the DW.
`pendingCollisions`: List of collision directions to help detect collision with tiles.
`dwcamera`: Camera of dw.
`playerpos`: Position of player in physical world.
`tiles`: The tile information.
`keyPos`: The positions of the keys in the map.
`currentKeyPos`: The current position of the key animation.
`keyAnimation`: Judge whether the animation is ongoing.

Example:
{ id = 100
, ty = "DW"
, state = { position = ( 150, 700 ), direction = 1, angle = 0, weaponType = 1, energy = 100 }
, pendingCollisions = []
, dwcamera = { x = data.state.position |> Tuple.first
, y = (data.state.position |> Tuple.second) - 200
, zoom = 1
, rotation = 0
}
, playerpos = ( 900, 500 )
, tiles = []
, keyPos = Just ( (100, 200), (200, 300), (300, 400) )
, currentKeyPos = ( 1000, 800 )
, keyAnimation = False
}

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


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        DWInitMsg data ->
            let
                cam =
                    { x = data.state.position |> Tuple.first
                    , y = (data.state.position |> Tuple.second) - 200
                    , zoom = 1
                    , rotation = 0
                    }
            in
            ( { state = data.state
              , id = data.id
              , ty = data.ty
              , pendingCollisions = []
              , dwcamera = cam
              , playerpos = data.state.position
              , tiles = []
              , keyPos = Nothing
              , currentKeyPos = ( 0, 0 )
              , keyAnimation = False
              }
            , initBaseData
            )

        _ ->
            ( { state =
                    { position = ( -5000, -5000 )
                    , vx = 0
                    , vy = 0
                    , direction = 1
                    , hp = 100
                    , alive = True
                    , a_pressed = False
                    , d_pressed = False
                    , s_pressed = False
                    , canjump = 1
                    , weaponDir = 1
                    , keyNum = 0
                    }
              , id = 100
              , ty = "DW"
              , pendingCollisions = []
              , dwcamera = env.globalData.camera
              , playerpos = ( -5000, -5000 )
              , tiles = []
              , keyPos = Nothing
              , currentKeyPos = ( 0, 0 )
              , keyAnimation = False
              }
            , initBaseData
            )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    if basedata.isPaused then
        ( ( data, basedata ), [], ( env, False ) )

    else if data.keyAnimation then
        case evnt of
            Tick dt ->
                let
                    ( newKeyPos, judge ) =
                        if data.keyAnimation then
                            updateKeyPos env dt data

                        else
                            ( data.currentKeyPos, False )
                in
                ( ( { data | currentKeyPos = newKeyPos, keyAnimation = judge }, basedata ), [], ( env, False ) )

            _ ->
                ( ( data, basedata ), [], ( env, False ) )

    else
        let
            camera =
                env.globalData.camera

            ( ( gdata, udata ), ( newdw, sta ) ) =
                ( ( env.globalData, env.globalData.userData ), ( not env.globalData.userData.dw, data.state ) )

            ( ( w, h ), ( vx, vy ) ) =
                ( ( 30, 60 ), ( sta.vx, sta.vy ) )

            dir =
                sta.direction

            ( x, y ) =
                sta.position

            oldcamera =
                data.dwcamera
        in
        help_update evnt env data basedata ( ( gdata, udata ), ( newdw, sta ) ) ( ( w, h ), ( vx, vy ) ) dir ( x, y ) oldcamera


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    let
        oldstate =
            data.state
    in
    case msg of
        InitPlayerStateMsg state ->
            ( ( { data | state = { oldstate | position = state.position, hp = state.hp } }, basedata ), [], env )

        PlayerStateMsg state ->
            let
                newHp =
                    stayClose data.state.hp data.state.position state.position
            in
            ( ( { data | state = { oldstate | hp = newHp }, playerpos = state.position }, basedata ), [], env )

        MapInfo newtile ->
            let
                keyPos =
                    getKeyBlockPos data.tiles
            in
            ( ( { data | tiles = newtile, keyPos = keyPos }, basedata ), [], env )

        CollisionResultDirMsg dir ->
            let
                fixedState =
                    resolveCollisions data.state dir
            in
            ( ( { data | state = fixedState, pendingCollisions = [] }, basedata ), [], env )

        CollisionResultMsg tile ->
            let
                ( value, updateKind ) =
                    specialBlockEffect tile data.state.keyNum data.state.hp
            in
            if updateKind == HP then
                ( ( { data | state = { oldstate | hp = value } }, basedata ), [], env )

            else if updateKind == Key then
                if value == 3 then
                    ( ( { data | state = { oldstate | keyNum = value }, currentKeyPos = data.state.position, keyAnimation = True }, basedata )
                    , [ Other ( "Map", FindKey data.state.position )

                      -- , Other ( "Interface", WinMsg )
                      ]
                    , env
                    )

                else
                    ( ( { data | state = { oldstate | keyNum = value }, currentKeyPos = data.state.position, keyAnimation = True }, basedata )
                    , [ Other ( "Map", FindKey data.state.position )
                      ]
                    , env
                    )

            else
                ( ( data, basedata ), [], env )

        EnemyBullets bullets ->
            ( ( { data | state = { oldstate | hp = data.state.hp - List.foldl (\b acc -> b.attack + acc) 0 (validbullet bullets data.state) } }, basedata ), [], env )

        EnemyStateMsg enemy ->
            ( ( { data | state = validenemy enemy data.state }, basedata ), [], env )

        ChangePause ->
            if basedata.isPaused then
                ( ( data, { basedata | isPaused = False } ), [], env )

            else
                ( ( data, { basedata | isPaused = True } ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    renderDW env data


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher _ _ tar =
    tar == "DW"


componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Component generator
-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
