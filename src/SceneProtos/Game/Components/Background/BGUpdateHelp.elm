module SceneProtos.Game.Components.Background.BGUpdateHelp exposing (BGType(..), floatRemainder, bgJudge, bgRenderHelp, decideSpeed)

{-|


# BGUpdateHelp

The background update helper functions.

@docs BGType, floatRemainder, bgJudge, bgRenderHelp, decideSpeed

-}

import Messenger.Base exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable)


{-| The data model for the background component.
`id`: Unique identifier for the background component.
`ty`: Type of the component, typically "Background".
`bgType`: A tuple of tuples representing the types of backgrounds to be used.
`initTime`: Initial time for the background, used for animations.
`position1` to `position5`: Positions for the background textures.

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


{-| The type of background used in the game.
-}
type BGType
    = BG1
    | BG2
    | BG3
    | BG4


{-| Calculate the remainder of a float division.
-}
floatRemainder : Float -> Float -> Float
floatRemainder a b =
    if b == 0 then
        a

    else
        a - toFloat (floor (a / b)) * b


{-| Judge the current background state based on the position.
-}
bgJudge : ( ( BGType, BGType ), ( BGType, BGType ) ) -> ( Float, Float ) -> ( ( ( BGType, BGType ), ( BGType, BGType ) ), Bool )
bgJudge ( ( firstBG, secondBG ), ( thirdBG, fourthBG ) ) position =
    let
        ( x0, y0 ) =
            position

        judge =
            x0 <= -980
    in
    if judge then
        case ( ( firstBG, secondBG ), ( thirdBG, fourthBG ) ) of
            ( ( BG1, BG2 ), ( BG3, BG4 ) ) ->
                ( ( ( BG2, BG3 ), ( BG4, BG1 ) ), judge )

            ( ( BG2, BG3 ), ( BG4, BG1 ) ) ->
                ( ( ( BG3, BG4 ), ( BG1, BG2 ) ), judge )

            ( ( BG3, BG4 ), ( BG1, BG2 ) ) ->
                ( ( ( BG4, BG1 ), ( BG2, BG3 ) ), judge )

            ( ( BG4, BG1 ), ( BG2, BG3 ) ) ->
                ( ( ( BG1, BG2 ), ( BG3, BG4 ) ), judge )

            _ ->
                ( ( ( BG1, BG2 ), ( BG3, BG4 ) ), judge )

    else
        ( ( ( firstBG, secondBG ), ( thirdBG, fourthBG ) ), judge )


{-| Calculate the next background position based on the current position.
-}
nextBGPos : ( Float, Float ) -> ( Float, Float )
nextBGPos ( x, y ) =
    ( x + 1960, y )


{-| Calculate the next two background positions based on the current position.
-}
nextTwoBGPos : ( Float, Float ) -> ( Float, Float )
nextTwoBGPos ( x, y ) =
    ( x + 1960 * 2, y )


{-| Calculate the next three background positions based on the current position.
-}
nextThreeBGPos : ( Float, Float ) -> ( Float, Float )
nextThreeBGPos ( x, y ) =
    ( x + 1960 * 3, y )


{-| Render the background based on the current data.
-}
bgRenderHelp : Data -> List Renderable
bgRenderHelp data =
    case data.bgType of
        ( ( BG1, BG2 ), ( BG3, BG4 ) ) ->
            order1BG1 data
                ++ order1BG2 data
                ++ order1BG3 data
                ++ order1BG4 data

        ( ( BG2, BG3 ), ( BG4, BG1 ) ) ->
            order2BG2 data
                ++ order2BG3 data
                ++ order2BG1 data
                ++ order2BG4 data

        ( ( BG3, BG4 ), ( BG1, BG2 ) ) ->
            order3BG3 data
                ++ order3BG1 data
                ++ order3BG2 data
                ++ order3BG4 data

        ( ( BG4, BG1 ), ( BG2, BG3 ) ) ->
            order4BG4 data
                ++ order4BG1 data
                ++ order4BG2 data
                ++ order4BG3 data

        _ ->
            [ P.empty ]


{-| Generate the background renderables based on the provided position function and background prefix.
-}
generateBG : (( Float, Float ) -> ( Float, Float )) -> String -> Data -> List Renderable
generateBG posFunc bgPrefix data =
    let
        positions =
            [ data.position1, data.position2, data.position3, data.position4, data.position5 ]

        getTexture index position =
            P.centeredTexture (posFunc position) ( 1960, 1080 ) 0 (bgPrefix ++ String.fromInt index)
    in
    List.indexedMap (\i pos -> getTexture (i + 1) pos) positions


{-| Decide the speed of animation of background.
-}
decideSpeed : Float -> ( Float, Float ) -> Float
decideSpeed speed position =
    let
        ( x, y ) =
            position

        slowerSpeed =
            40 - (speed - 40)

        newSpeed =
            if x >= -380 then
                speed

            else
                slowerSpeed
    in
    newSpeed


{-| Generate the renderables for the background based on the current state.
-}
order1BG1 : Data -> List Renderable
order1BG1 =
    generateBG identity "bg1_"


{-| Generate the renderables for the background based on the current state.
-}
order1BG2 : Data -> List Renderable
order1BG2 =
    generateBG nextBGPos "bg2_"


{-| Generate the renderables for the background based on the current state.
-}
order1BG3 : Data -> List Renderable
order1BG3 =
    generateBG nextTwoBGPos "bg3_"


{-| Generate the renderables for the background based on the current state.
-}
order1BG4 : Data -> List Renderable
order1BG4 =
    generateBG nextThreeBGPos "bg4_"


{-| Generate the renderables for the background based on the current state.
-}
order2BG1 : Data -> List Renderable
order2BG1 =
    generateBG nextThreeBGPos "bg1_"


{-| Generate the renderables for the background based on the current state.
-}
order2BG2 : Data -> List Renderable
order2BG2 =
    generateBG identity "bg2_"


{-| Generate the renderables for the background based on the current state.
-}
order2BG3 : Data -> List Renderable
order2BG3 =
    generateBG nextBGPos "bg3_"


{-| Generate the renderables for the background based on the current state.
-}
order2BG4 : Data -> List Renderable
order2BG4 =
    generateBG nextTwoBGPos "bg4_"


{-| Generate the renderables for the background based on the current state.
-}
order3BG1 : Data -> List Renderable
order3BG1 =
    generateBG nextTwoBGPos "bg1_"


{-| Generate the renderables for the background based on the current state.
-}
order3BG2 : Data -> List Renderable
order3BG2 =
    generateBG nextThreeBGPos "bg2_"


{-| Generate the renderables for the background based on the current state.
-}
order3BG3 : Data -> List Renderable
order3BG3 =
    generateBG identity "bg3_"


{-| Generate the renderables for the background based on the current state.
-}
order3BG4 : Data -> List Renderable
order3BG4 =
    generateBG nextBGPos "bg4_"


{-| Generate the renderables for the background based on the current state.
-}
order4BG1 : Data -> List Renderable
order4BG1 =
    generateBG nextBGPos "bg1_"


{-| Generate the renderables for the background based on the current state.
-}
order4BG2 : Data -> List Renderable
order4BG2 =
    generateBG nextTwoBGPos "bg2_"


{-| Generate the renderables for the background based on the current state.
-}
order4BG3 : Data -> List Renderable
order4BG3 =
    generateBG nextThreeBGPos "bg3_"


{-| Generate the renderables for the background based on the current state.
-}
order4BG4 : Data -> List Renderable
order4BG4 =
    generateBG identity "bg4_"
