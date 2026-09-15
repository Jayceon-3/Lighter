module SceneProtos.Game.Components.Bullet.Model exposing (component)

{-| Component model

@docs component

-}

import Color exposing (Color)
import Json.Decode exposing (bool)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import Messenger.Render.Texture exposing (renderSprite)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P exposing (centeredTexture)
import REGL.Common exposing (group)
import REGL.Effects exposing (alphamult, pixilation)
import Random
import SceneProtos.Game.Components.Bullet.Bulletlogic exposing (..)
import SceneProtos.Game.Components.Bullet.Init exposing (BulletType(..), SingleBullet)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.Map.CollisionLogic exposing (bulletCollisionJudge)
import SceneProtos.Game.Components.Map.Init as MapInit exposing (Tile)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data model for the bullet component.
`id`: Unique identifier for the bullet component.
`ty`: Type of the component, typically "Bullet".
`bullets`: List of bullets currently in the game.
`laser`: A tuple containing a single bullet representing the laser and a boolean indicating if the laser is active.
`laserInitTime`: The time when the laser was initialized, used for timing the laser's activation.
`tiles`: List of tiles in the game scene, used for collision detection.

Example:
{ id = 3
, ty = "Bullet"
, bullets = []
, laser = ( { position = ( 0, 0 ), direction = 0, shape = ( 600, 40 ), angle = 0, bulletType = Laser, attack = 0 }, False )
, laserInitTime = 0
, tiles = []
}

-}
type alias Data =
    { id : Int
    , ty : String
    , bullets : List SingleBullet
    , laser : ( SingleBullet, Bool )
    , laserInitTime : Float
    , tiles : List ( Int, Int, Tile )
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        BulletInitMsg data ->
            ( { bullets = data.bullets, id = data.id, ty = data.ty, laser = data.laser, laserInitTime = data.laserInitTime, tiles = data.tiles }, initBaseData )

        _ ->
            ( { bullets = [], laser = ( { position = ( 0, 0 ), direction = 0, shape = ( 600, 40 ), angle = 0, bulletType = Laser, attack = 0 }, False ), laserInitTime = 0, id = 3, ty = "Bullet", tiles = [] }, initBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    if basedata.isPaused then
        ( ( data, basedata ), [], ( env, False ) )

    else
        case evnt of
            Tick dt ->
                let
                    currentTime =
                        env.globalData.currentTimeStamp

                    deltaT =
                        (currentTime - data.laserInitTime) / 1000

                    bulletCollisionMsg =
                        List.map
                            (\b ->
                                let
                                    ( x, y ) =
                                        b.position

                                    ( w, h ) =
                                        b.shape

                                    newbullet =
                                        case List.head (bulletMove dt [ b ]) of
                                            Just nb ->
                                                nb

                                            _ ->
                                                b

                                    ( x1, y1 ) =
                                        newbullet.position
                                in
                                Other ( "Map", BulletCheckCollisionMsg { x = x, y = y, x1 = x1, y1 = y1, w = w, h = h } )
                            )
                            (bulletMove dt data.bullets)
                in
                -- let
                --     -- _ =
                --     --     Debug.log "updateNumber: " (List.length data.bullets)
                --     -- ( x1, y1 ) =
                --     --     collisionBullet
                --     -- newBullets =
                --     --     clearCollisionBullet data.bullets ( x1, y1 )
                -- in
                if deltaT > 1 && data.laserInitTime /= 0 then
                    ( ( { data | laser = ( Tuple.first data.laser, False ), bullets = bulletMove dt data.bullets, laserInitTime = 0 }, basedata ), [ Other ( "Enemy", Bullets (bulletMove dt data.bullets) ), Other ( "Enemy", LaserMsg data.laser ), Other ( "Survcamera", Bullets (bulletMove dt data.bullets) ), Other ( "Survcamera", LaserMsg data.laser ), Other ( "Ceo", Bullets (bulletMove dt data.bullets) ), Other ( "Ceo", LaserMsg data.laser ), Other ( "Boss", Bullets (bulletMove dt data.bullets) ), Other ( "Boss", LaserMsg data.laser ), Other ( "Particle", Bullets (bulletMove dt data.bullets) ), Other ( "Particle", LaserMsg data.laser ) ], ( env, False ) )

                else
                    ( ( { data | bullets = bulletMove dt data.bullets }, basedata ), [ Other ( "Enemy", Bullets (bulletMove dt data.bullets) ), Other ( "Enemy", LaserMsg data.laser ), Other ( "Survcamera", Bullets (bulletMove dt data.bullets) ), Other ( "Survcamera", LaserMsg data.laser ), Other ( "Ceo", Bullets (bulletMove dt data.bullets) ), Other ( "Ceo", LaserMsg data.laser ), Other ( "Boss", Bullets (bulletMove dt data.bullets) ), Other ( "Boss", LaserMsg data.laser ), Other ( "Particle", Bullets (bulletMove dt data.bullets) ) ], ( env, False ) )

            _ ->
                ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    let
        currentTime =
            env.globalData.currentTimeStamp
    in
    case msg of
        FireMsg bullet ->
            if bullet.bulletType == Ordinary then
                ( ( { data | bullets = bullet :: data.bullets }, basedata ), [], env )

            else
                ( ( { data | laser = ( bullet, True ), laserInitTime = currentTime }, basedata ), [], env )

        WeaponStateMsg stat ->
            let
                ( x2, y2 ) =
                    ( Tuple.first stat.position + 325 * cos stat.angle * stat.direction, Tuple.second stat.position - 325 * sin stat.angle * stat.direction )

                newLaser =
                    { position = ( x2, y2 ), direction = stat.direction, shape = ( 600, 40 ), angle = stat.angle, bulletType = Laser, attack = 0 }
            in
            ( ( { data | laser = ( newLaser, Tuple.second data.laser ) }, basedata ), [], env )

        NewBullets newbullet ->
            ( ( { data | bullets = cleanbullet newbullet data.tiles }, basedata ), [], env )

        -- MapMsg tiles ->
        --     let
        --         bulletList =
        --             List.map
        --                 (\b ->
        --                     let
        --                         ( x, y ) =
        --                             b.position
        --                         -- newbullet =
        --                         --     case List.head (bulletMove [ b ]) of
        --                         --         Just nb ->
        --                         --             nb
        --                         --         _ ->
        --                         --             b
        --                         -- ( x1, y1 ) =
        --                         --     newbullet.position
        --                     in
        --                     bulletCollisionJudge ( x, y ) tiles
        --                 )
        --                 data.bullets
        --         collisionList =
        --             trueCollisionPos bulletList
        --         newBullets =
        --             List.foldl
        --                 (\( x, y ) bullets ->
        --                     clearCollisionBullet bullets ( x, y )
        --                 )
        --                 data.bullets
        --                 collisionList
        --     in
        --     ( ( { data | bullets = newBullets }, basedata ), [], env )
        MapInfo newtile ->
            ( ( { data | tiles = newtile }, basedata ), [], env )

        ChangePause ->
            ( ( data, { basedata | isPaused = not basedata.isPaused } ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data _ =
    let
        laser =
            Tuple.first data.laser

        gd =
            env.globalData

        id =
            gd.internalData

        rate =
            600

        currentAct =
            if (env.globalData.currentTimeStamp - data.laserInitTime) / 1000 > 0.875 then
                "7"

            else if (env.globalData.currentTimeStamp - data.laserInitTime) / 1000 > 0.75 then
                "6"

            else if (env.globalData.currentTimeStamp - data.laserInitTime) / 1000 > 0.625 then
                "5"

            else if (env.globalData.currentTimeStamp - data.laserInitTime) / 1000 > 0.5 then
                "4"

            else if (env.globalData.currentTimeStamp - data.laserInitTime) / 1000 > 0.375 then
                "3"

            else if (env.globalData.currentTimeStamp - data.laserInitTime) / 1000 > 0.25 then
                "2"

            else if (env.globalData.currentTimeStamp - data.laserInitTime) / 1000 > 0.125 then
                "1"

            else
                "0"
    in
    if Tuple.second data.laser == True then
        ( group []
            (List.map (\bullet -> P.rectCentered bullet.position ( 10, 5 ) bullet.angle Color.white) data.bullets
                -- ++ [ P.rectCentered laser.position ( 600, 40 ) laser.angle Color.red ]
                ++ [ centeredTexture laser.position ( 600, 100 ) laser.angle ("laser0" ++ currentAct) ]
            )
        , 7
        )

    else
        ( group []
            (List.map (\bullet -> P.rectCentered bullet.position ( 10, 5 ) bullet.angle Color.white) data.bullets)
        , 7
        )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Bullet"


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
