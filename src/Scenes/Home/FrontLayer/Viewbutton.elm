module Scenes.Home.FrontLayer.Viewbutton exposing (Axis(..), viewButtonFrame)

{-|


# Viewbutton

Functions to render buttons in the Home scene.

@docs Axis, viewButtonFrame

-}

import Color exposing (Color(..))
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)
import Scenes.Home.FrontLayer.DataHelp exposing (ButtonData, Buttonstate(..), ScreenState(..))


type alias ButtonData =
    { position : ( Float, Float )
    , size : ( Float, Float )
    , state : Buttonstate
    , inittime : Float
    }


{-| Type to represent the axis for rendering.
-}
type Axis
    = X
    | Y


recsize : Float
recsize =
    15


n_size : Axis -> Float -> ( Float, Float )
n_size axis n =
    case axis of
        X ->
            ( recsize * (1 - (n - 1) / 20), recsize * (1 - (n - 1) / 20) )

        Y ->
            ( recsize * (1 - (n - 1) / 15), recsize * (1 - (n - 1) / 15) )


interval : Float
interval =
    5


distance : Float
distance =
    23


firstpos : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
firstpos ( x, y ) ( w, h ) =
    ( x - w / 2 - distance + 6, y - h / 2 - distance - 5 )


n_pos : Axis -> ( Float, Float ) -> ( Float, Float ) -> Float -> ( Float, Float )
n_pos axis ( x, y ) ( w, h ) n =
    let
        ( x_1, y_1 ) =
            firstpos ( x, y ) ( w, h )
    in
    if n <= 1 then
        ( x_1, y_1 )

    else
        let
            ( x_0, y_0 ) =
                n_pos axis ( x, y ) ( w, h ) (n - 1)
        in
        -- ( x_0 + (interval + Tuple.first (n_size n) / 2 + Tuple.first (n_size (n - 1)) / 2)
        -- , y_1
        -- )
        ( x_0 + (Tuple.first (n_size axis n) / 2 * sqrt 2 + Tuple.first (n_size axis (n - 1)) / 2 * sqrt 2)
        , y_0 + (Tuple.first (n_size axis n) / 2 * sqrt 2 + Tuple.first (n_size axis (n - 1)) / 2 * sqrt 2)
        )


chooseAxis : Axis -> ( Float, Float ) -> ( Float, Float ) -> Float -> ( Float, Float )
chooseAxis axis ( x, y ) ( w, h ) n =
    let
        ( x_1, y_1 ) =
            firstpos ( x, y ) ( w, h )

        ( x_n, y_n ) =
            n_pos axis ( x, y ) ( w, h ) n
    in
    case axis of
        X ->
            ( x_n, y_1 )

        Y ->
            ( x_1, y_n )



-- n_pos_y_axis : ( Float, Float ) -> ( Float, Float ) -> Float -> ( Float, Float )
-- n_pos_y_axis ( c, d ) ( width, height ) n =
--     let
--         ( a, b ) =
--             firstpos ( c, d ) <|
--                 ( width, height )
--     in
--     ( a, b + (n - 1) * interval )


central_sym : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
central_sym ( x, y ) ( cx, cy ) =
    ( 2 * cx - x, 2 * cy - y )


recset1 : ( Float, Float ) -> ( Float, Float ) -> Renderable
recset1 ( x, y ) ( w, h ) =
    group []
        [ P.rectCentered (n_pos X ( x, y ) ( w, h ) 1) (n_size X 1) 0 Color.purple
        ]


recset2 : ( Float, Float ) -> ( Float, Float ) -> Renderable
recset2 ( x, y ) ( w, h ) =
    group []
        [ P.rectCentered (n_pos X ( x, y ) ( w, h ) 2) (n_size X 2) 0 Color.purple
        ]


genColor : Float -> Float -> Color
genColor n_max n =
    let
        -- 71 201 255 254 84 228
        ratio =
            n / n_max

        -- r =
        --     (71 + (254 - 71) * ratio) / 255
        -- g =
        --     (201 + (84 - 201) * ratio) / 255
        -- b =
        --     (255 + (228 - 255) * ratio) / 255
        -- 200 205 251 124 84 239
        r =
            (200 + (124 - 200) * ratio) / 255

        g =
            (205 + (84 - 205) * ratio) / 255

        b =
            (251 + (239 - 251) * ratio) / 255
    in
    Color.rgba r g b 1


reclist : Axis -> Float -> ( Float, Float ) -> ( Float, Float ) -> List Renderable
reclist axis n ( a, b ) ( w, h ) =
    let
        listfloat =
            List.map
                (\i -> toFloat i)
                (List.range 1 (floor n))

        ( x, y ) =
            ( a + 3, b )

        n_max =
            case axis of
                X ->
                    18

                Y ->
                    8
    in
    List.map
        -- (\i -> P.roundedRect (n_pos_x_axis ( x, y ) ( w, h ) i) (n_size i) 3 Color.white)
        -- listfloat
        (\i -> P.rectCentered (chooseAxis axis ( x, y ) ( w, h ) i) (n_size axis i) (pi / 4) (genColor n_max i))
        listfloat
        ++ List.map
            -- (\i -> P.roundedRect (n_pos_x_axis ( x, y ) ( w, h ) i) (n_size i) 3 Color.white)
            -- listfloat
            (\i ->
                P.rectCentered (central_sym (chooseAxis axis ( x, y ) ( w, h ) i) ( x, y )) (n_size axis i) (pi / 4) (genColor n_max i)
            )
            listfloat


decidenumber : Float -> ButtonData -> Env SceneCommonData UserData -> Float
decidenumber n_max buttonData env =
    let
        currentTime =
            env.globalData.currentTimeStamp

        state =
            buttonData.state

        initTime =
            buttonData.inittime

        deltaT =
            (currentTime - initTime) / 1000

        maxtime =
            0.2

        n =
            case state of
                Off ->
                    n_max - deltaT / maxtime * n_max + 1

                On ->
                    deltaT / maxtime * n_max
    in
    if n > n_max then
        n_max

    else if n < 1 then
        0

    else
        toFloat (floor n)


{-| Render the button frame based on the button data and environment.
-}
viewButtonFrame : Env SceneCommonData UserData -> ButtonData -> Renderable
viewButtonFrame env buttonData =
    let
        ( x, y ) =
            buttonData.position

        ( w, h ) =
            buttonData.size

        n_x_max =
            15

        n_y_max =
            8

        n_x =
            decidenumber n_x_max buttonData env

        n_y =
            decidenumber n_y_max buttonData env
    in
    group []
        (reclist X n_x ( x, y ) ( w, h )
            ++ reclist Y n_y ( x, y ) ( w, h )
        )
