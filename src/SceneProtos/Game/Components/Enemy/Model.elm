module SceneProtos.Game.Components.Enemy.Model exposing (component)

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
import REGL.Common exposing (Renderable, group)
import REGL.Effects exposing (alphamult)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.Enemy.Enemyblood exposing (updateblood)
import SceneProtos.Game.Components.Enemy.Enemybulletlogic exposing (..)
import SceneProtos.Game.Components.Enemy.Enemydead exposing (msg_list)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (move, moveenemy, updateenemy)
import SceneProtos.Game.Components.Enemy.Enemytarget exposing (refreshtarget)
import SceneProtos.Game.Components.Enemy.Init exposing (..)
import SceneProtos.Game.Components.Map.Init exposing (Tile)
import SceneProtos.Game.Components.Player.Init exposing (..)
import SceneProtos.Game.Components.Player.Playerlogic exposing (validbullet)
import SceneProtos.Game.Components.Weapon.Init exposing (ShieldState(..))
import SceneProtos.Game.Components.Weapon.WeaponUpdate exposing (shieldValidBullet)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


type alias Data =
    { id : Int
    , ty : String
    , enemy : List Enemy
    , enemybullet : List EnemyBullet
    , dt : Float
    , real : ( Float, Float )
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        EnemyInitMsg data ->
            ( { id = data.id, ty = data.ty, enemy = data.enemy, enemybullet = data.enemybullet, dt = 0, real = data.real }, initBaseData )

        _ ->
            ( { id = 4
              , ty = "Enemy"
              , enemy = []
              , enemybullet = []
              , dt = 0
              , real = ( 0, 0 )
              }
            , initBaseData
            )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    let
        enemy =
            List.head data.enemy

        hp =
            case enemy of
                Just ene ->
                    ene.hp

                _ ->
                    0

        ( msgs, tempdata ) =
            msg_list data
    in
    case evnt of
        Tick t ->
            let
                newenemy =
                    List.filter
                        (\e ->
                            e.enemytype /= Dead
                        )
                        tempdata.enemy

                newdata =
                    { tempdata | enemy = newenemy, dt = t }
            in
            ( ( newdata, basedata ), [ Other ( "Player", EnemyBullets data.enemybullet ), Other ( "Player", EnemyStateMsg data.enemy ) ] ++ msgs, ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        Bullets bullets ->
            ( ( { data | enemy = Tuple.first (updateblood data.enemy bullets) }, basedata ), [ Other ( "Bullet", NewBullets (Tuple.second (updateblood data.enemy bullets)) ) ], env )

        PlayerStateMsg state ->
            let
                newenemy =
                    List.map
                        (\e ->
                            { e | target = state.position }
                        )
                        data.enemy

                newbullet =
                    remainbullet data.enemybullet state

                hurt =
                    toFloat (List.length (validbullet data.enemybullet state)) * 5
            in
            ( ( { data | enemy = newenemy, enemybullet = newbullet, real = state.position }, basedata ), [ Other ( "Player", Hurt hurt ), Other ( "Player", EnemyStateMsg data.enemy ) ], env )

        LaserMsg laser ->
            ( ( { data | enemy = judgeLaser laser data.enemy }, basedata ), [], env )

        ShieldMsg shield ->
            let
                midenemy =
                    if shield.shieldState /= Unused then
                        let
                            tempenemy =
                                refreshtarget data.enemy shield.position
                        in
                        tempenemy

                    else
                        --List.map
                        --    (\e ->
                        --        { e | target = ( -10000, -10000 ) }
                        --    )
                        data.enemy

                newbullet =
                    updatebullet data.enemybullet data.enemy env data.dt

                newenemy =
                    updateenemy midenemy env data.dt data.real
            in
            ( ( { data | enemybullet = shieldValidBullet newbullet shield, enemy = newenemy }, basedata ), [], env )

        --MapInfo newtiles ->
        --    ( ( { data | enemybullet = cleanbullet data.enemybullet newtiles, tiles = newtiles }, basedata ), [], env )
        _ ->
            ( ( data, basedata ), [], env )


enemyToViews : Float -> Enemy -> List Renderable
enemyToViews time enemy =
    let
        movePos =
            move enemy.position ( 0, -20 )

        walkFrame =
            modBy 6 (floor (time / 6))

        standFrame =
            modBy 4 (floor (time / 6))

        ( ( x1, _ ), ( x2, _ ) ) =
            ( enemy.position, enemy.target )

        direction =
            (x2 - x1) / abs (x2 - x1)
    in
    if enemy.enemytype == Dead then
        []

    else if enemy.enemystate /= Attack then
        [ P.centeredTexture movePos
            ( 50 * enemy.direction, 50 )
            0
            ("gundown" ++ String.fromInt enemy.appear)
        , P.centeredTexture movePos
            ( 100 * enemy.direction, 100 )
            0
            ("enemywalk" ++ String.fromInt enemy.appear ++ String.fromInt walkFrame)
        ]

    else if enemy.enemytype == Normal then
        [ P.centeredTexture movePos
            ( 100 * direction, 100 )
            0
            ("enemyrun" ++ String.fromInt enemy.appear ++ String.fromInt walkFrame)
        , P.centeredTexture movePos
            ( 100 * direction, 100 )
            0
            ("knife" ++ String.fromInt enemy.appear ++ String.fromInt walkFrame)
        ]

    else if enemy.vx == 0 then
        [ P.centeredTexture movePos
            ( 50 * direction, 23 )
            0
            ("gunup" ++ String.fromInt enemy.appear)
        , P.centeredTexture movePos
            ( 100 * direction, 100 )
            0
            ("enemystand" ++ String.fromInt enemy.appear ++ String.fromInt standFrame)
        ]

    else
        [ P.centeredTexture movePos
            ( 50 * direction, 23 )
            0
            ("gunup" ++ String.fromInt enemy.appear)
        , P.centeredTexture movePos
            ( 100 * direction, 100 )
            0
            ("enemywalk" ++ String.fromInt enemy.appear ++ String.fromInt walkFrame)
        ]


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        time =
            env.globalData.sceneStartTime / 1000 / 0.1

        enemyViews =
            List.concatMap (enemyToViews time) data.enemy

        bulletViews =
            List.map (\b -> P.centeredTexture (move b.position ( 0, -20 )) ( 12, 9 ) 0 ("bullet" ++ String.fromInt b.appear)) data.enemybullet

        exclamationViews =
            data.enemy
                |> List.filter (\e -> e.enemystate == Buffer && e.enemytype /= Dead)
                |> List.map (\enemy -> P.textbox (move enemy.position ( -15, -110 )) 40 "!" "consolas" Color.red)

        hpViews =
            List.map (\e -> [ P.rect (move e.position ( -30 - 10 * e.direction, -60 )) ( 60, 5 ) Color.grey, P.rect (move e.position ( -30 - 10 * e.direction, -60 )) ( 60 * e.hp / 200, 5 ) Color.red ]) (List.filter (\e -> e.enemytype /= Dead) data.enemy)
                |> List.concat

        render =
            List.concat [ enemyViews, bulletViews, exclamationViews, hpViews ]
    in
    ( group [ alphamult 1 ] render
    , 9
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Enemy"


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
