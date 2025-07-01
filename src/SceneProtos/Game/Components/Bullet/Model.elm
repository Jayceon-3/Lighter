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
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import REGL.Effects exposing (alphamult)
import SceneProtos.Game.Components.Bullet.Init exposing (SingleBullet)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


type alias Data =
    { id : Int
    , ty : String
    , bullets : List SingleBullet
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        BulletInitMsg data ->
            ( { bullets = data.bullets, id = data.id, ty = data.ty }, () )

        _ ->
            ( { bullets = [], id = 3, ty = "Bullet" }, () )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        Tick dt ->
            ( ( { data | bullets = bulletMove data.bullets }, basedata ), [ Other ( "Enemy", Bullets data.bullet ) ], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        FireMsg bullet ->
            ( ( { data | bullets = bullet :: data.bullets }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( group [] (List.map (\bullet -> P.rectCentered bullet.position ( 10, 5 ) bullet.angle Color.purple) data.bullets), 0 )


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


bulletMove : List SingleBullet -> List SingleBullet
bulletMove bullets =
    let
        speed =
            5

        newBullets =
            List.map
                (\bullet ->
                    { bullet | position = ( Tuple.first bullet.position + speed * cos bullet.angle * bullet.direction, Tuple.second bullet.position - speed * sin bullet.angle * bullet.direction ) }
                )
                bullets
    in
    newBullets
