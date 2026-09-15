module SceneProtos.Game.Components.Ceo.Model exposing (component)

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
import SceneProtos.Game.Components.Ceo.Bombrender exposing (..)
import SceneProtos.Game.Components.Ceo.Bulletlogic exposing (advanceskills, newplayer)
import SceneProtos.Game.Components.Ceo.Ceorender exposing (cameraupdate, ceoToViews)
import SceneProtos.Game.Components.Ceo.Init exposing (..)
import SceneProtos.Game.Components.Ceo.Punchlogic exposing (judgeLaser, normalskills, playerbullet)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (move)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Data structure of ceo data
`id`: unique entity identifier
`ty`: entity type name
`position`: spawn coordinates
`hp`: current health points
`bullet`: BulletSkill parameters
`punch`: PunchSkill parameters
`bomb`: BombSkill parameters
`defend`: DefendSkill parameters
`hit`: HitSkill parameters
`periodtime`: update interval duration
`player`: target player coordinates
`dt`: delta time accumulator
`msg`: message display flag
Example:
{ id = 42
, ty = "Enemy"
, position = (300, 500)
, hp = 150.0
, bullet = ...
, punch = ...
, bomb = ...
, defend = ...
, hit = ...
, periodtime = 0.016
, player = (100, 200)
, dt = 0.016
, msg = True
}
-}
type alias Data =
    { id : Int
    , ty : String
    , position : ( Float, Float )
    , hp : Float
    , bullet : BulletSkill
    , punch : PunchSkill
    , bomb : BombSkill
    , defend : DefendSkill
    , hit : HitSkill
    , periodtime : Float
    , player : ( Float, Float )
    , dt : Float
    , msg : Bool
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        CeoInitMsg data ->
            -- recommend position: (1000,1900),recommend hp: 3000
            ( { id = 7, ty = "Ceo", position = data.position, hp = data.hp, bullet = data.bullet, punch = data.punch, bomb = data.bomb, defend = data.defend, hit = data.hit, periodtime = data.periodtime, player = data.player, dt = 0, msg = False }, initBaseData )

        _ ->
            ( defaultceo, initBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    if basedata.isPaused then
        ( ( data, basedata ), [], ( env, False ) )

    else
        case evnt of
            Tick t ->
                let
                    --_ =
                    --    Debug.log "(bullet,bomb,hit,punch,defend)" [ data.bullet.ifon, data.bomb.ifon, data.hit.ifon, data.punch.ifon, data.defend.ifon ]
                    judge =
                        data.punch.ifon || data.hit.ifon

                    oldglobal =
                        env.globalData

                    newcamera =
                        if judge then
                            cameraupdate env.globalData.camera env t

                        else
                            env.globalData.camera

                    bombskill =
                        data.bomb

                    newbomb =
                        bombupdate data.bomb.bombs (env.globalData.sceneStartTime / 1000) (t / 1000)

                    ( msg, newdata ) =
                        if data.hp <= 0 && data.msg == False then
                            ( [ Other ( "Interface", WinMsg ), Other ( "Player", Rightbound (Tuple.first data.position) ) ], { data | msg = True } )

                        else
                            ( [ Other ( "Player", Rightbound (Tuple.first data.position) ) ], data )
                in
                ( ( { newdata | bomb = { bombskill | bombs = newbomb }, dt = t }, basedata ), msg, ( { env | globalData = { oldglobal | camera = newcamera } }, False ) )

            _ ->
                ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        PlayerStateMsg state ->
            let
                player =
                    state.position

                ( newdata, hurt ) =
                    advanceskills data env player data.dt

                newpos =
                    newplayer player newdata

                --_ =
                --    Debug.log "(bomb,player)" ( List.map (\b -> b.position) data.bomb.bombs, newpos )
            in
            ( ( { newdata | player = newpos }, basedata ), [ Other ( "Player", Hurt hurt ) ], env )

        Bullets bullets ->
            let
                ( tempdata, hurt ) =
                    normalskills data data.player bullets env data.dt

                ( newdata, newbullets ) =
                    playerbullet tempdata bullets
            in
            ( ( newdata, basedata ), [ Other ( "Bullet", NewBullets newbullets ), Other ( "Player", Hurt hurt ) ], env )

        LaserMsg laser ->
            ( ( judgeLaser laser data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        time =
            env.globalData.sceneStartTime / 1000

        index =
            ceoToViews time data

        ceoTexture =
            let
                pos =
                    move data.position ( 0, 58 )
            in
            P.centeredTexture pos ( -600, 600 ) 0 ("ceo" ++ index)

        bulletViews =
            List.map (\b -> P.centeredTexture b.position ( 16, 12 ) b.direction "bullet3") data.bullet.bullets

        bombViews =
            renderbombs data.bomb.bombs

        hpViews =
            [ P.rect (move ( 960, 100 ) ( -100, -7.5 )) ( 200, 15 ) Color.grey
            , P.rect (move ( 960, 100 ) ( -100, -7.5 )) ( 200 * data.hp / 3000, 15 ) Color.red
            ]

        render =
            [ ceoTexture, bombViews ] ++ bulletViews ++ hpViews
    in
    ( group [] render
    , 0
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Ceo"


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


defaultceo : Data
defaultceo =
    { id = 7
    , ty = "Ceo"
    , position = ( 1400, 670 ) -- 400*700
    , hp = 3000
    , bullet =
        { ifon = False
        , activatetime = 0
        , shoottime = -pi * 3 / 4
        , shootangle = -pi
        , bullets = []
        , state = Default
        , angle = 0
        , direction = -1
        }
    , punch =
        { ifon = False
        , direction = -1
        , state = Hand
        , time = 0
        }
    , bomb =
        { ifon = False
        , bombs = []
        , time = 0
        }
    , defend =
        { ifon = False
        , activatetime = 0
        , cd = 2.5
        , v = -10
        }
    , hit =
        { ifon = False
        , activatetime = 0
        , camera =
            { x = 1400
            , y = 640
            , zoom = 1
            , rotation = 0
            }
        }
    , periodtime = 0
    , player = ( 300, 960 )
    , dt = 0
    , msg = False
    }



-- TODO: add bomb visual effect, add camera effect, add win or lose condition, fix player falling issue
