module SceneProtos.Game.Components.Boss.Model exposing (component)

{-| Component model

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import REGL.Effects exposing (alphamult)
import SceneProtos.Game.Components.Boss.Bosslaser exposing (..)
import SceneProtos.Game.Components.Boss.Bosslogic exposing (..)
import SceneProtos.Game.Components.Boss.Bossupdate exposing (..)
import SceneProtos.Game.Components.Boss.Bulletrender exposing (..)
import SceneProtos.Game.Components.Boss.Decreaseblood exposing (..)
import SceneProtos.Game.Components.Boss.Init exposing (..)
import SceneProtos.Game.Components.Boss.Laserrender exposing (laserupdate)
import SceneProtos.Game.Components.Boss.Renderpart exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (move)
import SceneProtos.Game.Components.Survcamera.Cchangemode exposing (judgeactivate)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data model for the boss component.
`id`: Unique identifier for the boss component. `ty`: Type of the component, typically "Boss". `position`: Position of the boss in the game scene. `hp`: Health points of the boss. `drone`: List of drones associated with the boss. `dronenumber`: Number of drones. `flash`: List of flash effects. `elaser`: List of laser lines. `bossbullet`: List of bullets fired by the boss.

Example:
{ id = 5
, ty = "Boss"
, position = ( 0, 0 )
, hp = 5000
, drone = []
, dronenumber = 0
, flash = []
, elaser = []
, bossbullet = []
}

-}
type alias Data =
    { id : Int
    , ty : String
    , position : ( Float, Float )
    , hp : Float
    , drone : List Drone
    , dronenumber : Int
    , flash : List ( Float, Float )
    , elaser : List Elaser
    , bossbullet : List BossBullet
    , dt : Float
    , msg : Bool
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        BossInitMsg data ->
            ( { id = 5, ty = "Boss", position = data.position, hp = data.hp, drone = data.drone, dronenumber = data.dronenumber, flash = data.flash, elaser = data.elaser, bossbullet = data.bossbullet, dt = 0, msg = False }, initBaseData )

        _ ->
            ( { id = 5, ty = "Boss", position = ( 0, 0 ), hp = 5000, drone = [], dronenumber = 0, flash = [], elaser = [], bossbullet = [], dt = 0, msg = False }, initBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    if basedata.isPaused then
        ( ( data, basedata ), [], ( env, False ) )

    else
        case evnt of
            Tick t ->
                let
                    delta =
                        t / 1000

                    temp1 =
                        updatedrone data data.dt

                    temp2 =
                        updatebullet temp1 env data.dt

                    time =
                        env.globalData.sceneStartTime / 1000

                    templaser =
                        updatelaser temp2.elaser env delta data.dt

                    newlaser =
                        laserupdate templaser time delta

                    newbullets =
                        bulletupdate temp2.bossbullet time delta

                    tempdata =
                        { temp2 | elaser = newlaser, bossbullet = newbullets, dt = t }

                    ( msg, newdata ) =
                        if data.hp <= 0 && data.msg == False then
                            ( [ Other ( "Interface", WinMsg ) ], { tempdata | msg = True } )

                        else
                            ( [], tempdata )
                in
                ( ( newdata, basedata ), msg, ( env, False ) )

            _ ->
                ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        Bullets bullets ->
            let
                ( newdata, newbullets ) =
                    playerbullet data bullets

                --_ =
                --    Debug.log "dronehp" (List.map (\d -> d.hp) data.drone)
            in
            ( ( newdata, basedata ), [ Other ( "Bullet", NewBullets newbullets ) ], env )

        PlayerStateMsg state ->
            let
                ( newbullets, hurt1 ) =
                    attackplayer state data.bossbullet

                hurt2 =
                    judgelasers data.elaser state

                judge1 =
                    judgeactivate state.position [ ( 180, 960 ), ( 180, 1020 ), ( 480, 1020 ), ( 480, 900 ), ( 300, 900 ) ] (Tuple.first state.position) 100

                judge2 =
                    judgeactivate state.position [ ( 1440, 900 ), ( 1620, 900 ), ( 1740, 960 ), ( 1740, 1020 ), ( 1440, 1020 ) ] (Tuple.first state.position) 100

                hurt =
                    if judge1 && judge2 then
                        0

                    else
                        hurt1 + hurt2

                newposition =
                    correctplayer state
            in
            ( ( { data | bossbullet = newbullets }, basedata ), [ Other ( "Player", Hurt hurt ) ], env )

        LaserMsg laser ->
            ( ( judgeLaser laser data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        time =
            env.globalData.sceneStartTime / 1000
    in
    ( group
        [ alphamult 1 ]
        ([ P.rect ( 0, 0 ) ( 1920, 1080 ) Color.black
         , P.centeredTexture data.position ( 450, 252 ) 0 "bosshead"
         ]
            ++ List.map
                (\d ->
                    P.circle d.position 25 Color.lightBlue
                )
                data.drone
            ++ [ renderlasers data.elaser time
               , renderbullets data.bossbullet time
               , P.rect (move ( 900, 100 ) ( -100, -7.5 )) ( 200, 15 ) Color.white
               , P.rect (move ( 900, 100 ) ( -100, -7.5 )) ( 200 * data.hp / 3000, 15 ) (Color.rgb 0.0 0.941 0.988)
               , P.poly [ ( 180, 960 ), ( 180, 1020 ), ( 480, 1020 ), ( 480, 900 ), ( 300, 900 ) ] Color.black
               , P.poly [ ( 1440, 900 ), ( 1620, 900 ), ( 1740, 960 ), ( 1740, 1020 ), ( 1440, 1020 ) ] Color.black
               ]
        )
    , 0
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Boss"


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
