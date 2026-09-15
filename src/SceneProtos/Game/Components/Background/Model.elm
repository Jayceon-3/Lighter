module SceneProtos.Game.Components.Background.Model exposing (component)

{-| Component model

@docs component

-}

-- import Messenger.Coordinate.Camera exposing (..)

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (..)
import SceneProtos.Game.Components.Background.BGUpdateHelp exposing (BGType(..), bgJudge, bgRenderHelp, decideSpeed, floatRemainder)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.Survcamera.Cbullet exposing (newcbullet)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)



-- import Messenger.Scene.Scene exposing (SceneOutputMsg(..))


{-| The data model for the background component.
`id`: Unique identifier for the background component. `ty`: Type of the component, typically "Background". `bgType`: A tuple of tuples representing the types of backgrounds to be used. `initTime`: Initial time for the background, used for animations. `position1` to `position5`: Positions for the background textures.

example:
{ id = 1
, ty = "Background"
, bgType = ( ( BG1, BG2 ), ( BG3, BG4 ) )
, initTime = 0.0
, position1 = ( 0, 0 ), position2 = ( 1960, 0 ), position3 = ( 3920, 0 ), position4 = ( 5880, 0 ), position5 = ( 7840, 0 )
}

-}
type alias Data =
    { id : Int
    , ty : String
    , bgType : ( ( BGType, BGType ), ( BGType, BGType ) )
    , initTime : Float
    , position1 : ( Float, Float )
    , position2 : ( Float, Float )
    , position3 : ( Float, Float )
    , position4 : ( Float, Float )
    , position5 : ( Float, Float )
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        BGInitMsg data ->
            ( { id = 0, ty = "Background", bgType = data.bgType, initTime = data.initTime, position1 = data.position1, position2 = data.position2, position3 = data.position3, position4 = data.position4, position5 = data.position5 }, initBaseData )

        _ ->
            ( { id = 0, ty = "Background", bgType = ( ( BG1, BG2 ), ( BG3, BG4 ) ), initTime = 0, position1 = ( 0, 0 ), position2 = ( 0, 0 ), position3 = ( 0, 0 ), position4 = ( 0, 0 ), position5 = ( 0, 0 ) }, initBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        Tick dt ->
            let
                deltaT =
                    floatRemainder (env.globalData.sceneStartTime / 1000) data.initTime

                ( ( x1, y1 ), ( x2, y2 ), ( x3, y3 ) ) =
                    ( data.position1, data.position2, data.position3 )

                ( ( x4, y4 ), ( x5, y5 ) ) =
                    ( data.position4, data.position5 )

                camera =
                    env.globalData.camera

                newPos ( x0, y0 ) t v =
                    ( x0 - v * t, y0 )

                ( newType, judge ) =
                    bgJudge data.bgType data.position1
            in
            if judge then
                ( ( { data
                        | position1 = ( x1 + 1960, y1 )
                        , position2 = ( x2 + 1960, y2 )
                        , position3 = ( x3 + 1960, y3 )
                        , position4 = ( x4 + 1960, y4 )
                        , position5 = ( x5 + 1960, y5 )
                        , initTime = env.globalData.sceneStartTime / 1000
                        , bgType = newType
                    }
                  , basedata
                  )
                , []
                , ( env, False )
                )

            else
                ( ( { data
                        | position1 = newPos ( Tuple.first data.position1, camera.y ) (dt / 1000) 40
                        , position2 = newPos ( Tuple.first data.position2, camera.y ) (dt / 1000) (decideSpeed 45 data.position2)
                        , position3 = newPos ( Tuple.first data.position3, camera.y ) (dt / 1000) (decideSpeed 50 data.position3)
                        , position4 = newPos ( Tuple.first data.position4, camera.y ) (dt / 1000) (decideSpeed 55 data.position4)
                        , position5 = newPos ( Tuple.first data.position5, camera.y ) (dt / 1000) (decideSpeed 60 data.position5)
                    }
                  , basedata
                  )
                , []
                , ( env, False )
                )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data _ =
    let
        camera =
            env.globalData.camera

        newCenter =
            ( camera.x, camera.y )

        background =
            if env.globalData.userData.dw then
                P.rectCentered newCenter ( 1960, 1080 ) 0 Color.black

            else
                group []
                    (bgRenderHelp data
                        ++ [ P.rectCentered newCenter ( 1960, 1080 ) 0 (Color.rgba 0 0 0 0.2) ]
                    )
    in
    ( background, 0 )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher _ _ tar =
    tar == "Background"


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
