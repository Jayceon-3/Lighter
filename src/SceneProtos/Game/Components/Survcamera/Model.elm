module SceneProtos.Game.Components.Survcamera.Model exposing (component)

{-| Component model

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.Map.Init exposing (Tile)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.Components.Survcamera.Cbullet exposing (..)
import SceneProtos.Game.Components.Survcamera.Init exposing (..)
import SceneProtos.Game.Components.Survcamera.Scameraupdate exposing (updatebullet, updatecamera)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


type alias Data =
    { id : Int
    , ty : String
    , survcameras : List Survcamera
    , camerabullets : List CameraBullet
    , tiles : List ( Int, Int, Tile )
    , dt : Float
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        SurCameraInitMsg data ->
            ( { id = data.id, ty = data.ty, survcameras = data.survcameras, camerabullets = data.camerabullets, tiles = data.tiles, dt = 0 }, initBaseData )

        _ ->
            ( { id = 6
              , ty = "Survcamera"
              , survcameras = []
              , camerabullets = []
              , tiles = []
              , dt = 0
              }
            , initBaseData
            )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    if basedata.isPaused then
        ( ( data, basedata ), [], ( env, False ) )

    else
        case evnt of
            Tick t ->
                let
                    tempdata =
                        updatebullet data env data.dt

                    newdata =
                        { tempdata | dt = t }
                in
                ( ( newdata, basedata ), [], ( env, False ) )

            _ ->
                ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        PlayerStateMsg state ->
            let
                newdata =
                    updatecamera data state
            in
            ( ( newdata, basedata ), [ Other ( "Player", SurCameraBullets data.camerabullets ) ], env )

        NewCameraBullet newbullets ->
            ( ( { data | camerabullets = newbullets }, basedata ), [], env )

        Bullets bullets ->
            let
                ( newcamera, newbullet ) =
                    updateblood data.survcameras bullets
            in
            ( ( { data | survcameras = newcamera }, basedata ), [], env )

        LaserMsg laser ->
            ( ( { data | survcameras = judgeLaser laser data.survcameras }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( group
        []
        (List.map
            (\c ->
                if c.isAlive == False then
                    P.empty

                else if c.camerastate == Default then
                    P.poly c.drawpoints Color.lightOrange

                else
                    P.poly c.drawpoints Color.darkRed
            )
            data.survcameras
            ++ List.map
                (\b ->
                    P.circle b.position 5 Color.black
                )
                data.camerabullets
            ++ List.map
                (\c ->
                    if c.isAlive then
                        P.rectCentered c.position ( 20, 10 ) -c.angle Color.grey

                    else
                        P.rectCentered c.position ( 20, 10 ) -c.angle Color.black
                )
                data.survcameras
        )
      --buffer state should be added, later I'll add
    , 0
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Survcamera"


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
