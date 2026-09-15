module Scenes.Transition1.Layer1.Grid exposing (Coderain, grid, update_codes, view_rain)

{-|


# Grid

Functions for generating code rain effect.

@docs Coderain, grid, update_codes, view_rain

-}

import Array exposing (Array)
import Color exposing (Color, rgba)
import Messenger.Base exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import REGL.Effects exposing (blur)
import Random


{-| Represents a single falling code character with:

`position`: (x, y) coordinates on screen
`text`: The character to display (either '0' or '1')
`color`: The color of the character with alpha transparency
`lasttime`: How long the character has been visible (used for fading)
Example:

    { position = ( 960, 540 )
    , text = '0'
    , color = rgba 0 0 0 0
    , lasttime = 0
    }

-}
type alias Singlecode =
    { position : ( Float, Float )
    , text : Char
    , color : Color
    , lasttime : Float
    }


{-| Represents the entire code rain effect with:

`codes`: List of all active code characters
`seed`: Random seed for generating new characters
`inittime`: Timestamp when the effect started
Example:

    { codes = []
    , seed = Random.float 0 1920
    , inittime = 0
    }

-}
type alias Coderain =
    { codes : List Singlecode
    , seed : Random.Seed
    , inittime : Float
    }


symbols : Array Char
symbols =
    Array.fromList
        (List.map Char.fromCode
            (List.range 0x30 0x31)
        )


index_generator : Random.Seed -> ( Int, Random.Seed )
index_generator seed =
    let
        ( index, newSeed ) =
            Random.step (Random.int 0 1) seed
    in
    ( index, newSeed )


pos_generator : Random.Seed -> ( ( Float, Float ), Random.Seed )
pos_generator seed =
    let
        ( x, seed1 ) =
            Random.step (Random.float 0 1920) seed

        ( y, newSeed ) =
            Random.step (Random.float 0 1080) seed1
    in
    ( ( x, y ), newSeed )


gen_code : Random.Seed -> ( Singlecode, Random.Seed )
gen_code seed =
    let
        ( index, newSeed ) =
            index_generator seed

        ( position, newnewSeed ) =
            pos_generator newSeed

        text =
            Array.get index symbols
                |> Maybe.withDefault '0'

        color =
            rgba 0 0 0 0

        lasttime =
            0
    in
    ( { position = position, text = text, color = color, lasttime = lasttime }
    , newnewSeed
    )


move_code : Singlecode -> Float -> Singlecode
move_code code dt =
    { code | position = ( code.position |> Tuple.first, (code.position |> Tuple.second) + dt / 1000 * 70 ) }


move_codes : List Singlecode -> Float -> List Singlecode
move_codes codes dt =
    List.map (\code -> move_code code dt) codes


fade_code : Singlecode -> Singlecode
fade_code code =
    { code | color = rgba 0.5 0.5 0.8 (max 0 (1 - code.lasttime / 1000 / 1.5)) }


fade_code_boss : Singlecode -> Singlecode
fade_code_boss code =
    { code | color = rgba 1 0.4 0.4 (max 0 (1 - code.lasttime / 1000 / 1.5)) }


{-| Main update function for the code rain effect
-}
update_codes : Coderain -> Float -> Float -> Bool -> Coderain
update_codes rain dt currenttime boss_or_not =
    let
        newcodes1 =
            if boss_or_not then
                List.map (\code -> fade_code_boss code) rain.codes

            else
                List.map (\code -> fade_code code) rain.codes

        newcodes2 =
            List.filter (\code -> (Color.toRgba code.color).alpha > 0) newcodes1

        newcodes3 =
            move_codes newcodes2 dt

        newcodes4 =
            List.map (\code -> { code | lasttime = code.lasttime + dt }) newcodes3

        ( newcode, newSeed ) =
            gen_code rain.seed

        ( newcodes5, newinittime ) =
            if currenttime - rain.inittime > 50 then
                ( newcodes4 ++ [ newcode ], currenttime )

            else
                ( newcodes4, rain.inittime )
    in
    { rain | codes = newcodes5, inittime = newinittime, seed = newSeed }


{-| Renders all active code characters as text elements
-}
view_rain : Coderain -> Renderable
view_rain rain =
    let
        renderCode code =
            P.textbox code.position 30 (String.fromChar code.text) "consolas" code.color
    in
    group []
        (List.map renderCode rain.codes)


x_list : List Float
x_list =
    List.range 0 160
        |> List.map (\x -> toFloat x)


y_list : List Float
y_list =
    List.range 0 90
        |> List.map (\y -> toFloat y)


gridColor : Color
gridColor =
    rgba 0.5 0.5 0.8 0.2


gridColorBoss : Color
gridColorBoss =
    rgba 1 0.4 0.4 0.2


{-| Renders a background grid of lines
-}
grid : Bool -> Renderable
grid boss_or_not =
    let
        color =
            if boss_or_not then
                gridColorBoss

            else
                gridColor

        x_lst =
            List.map (\x -> ( 200 * x, 0 )) x_list

        y_lst =
            List.map (\y -> ( 0, 200 * y )) y_list

        x_lines =
            List.map (\pos -> P.rect pos ( 2, 1080 ) color) x_lst

        y_lines =
            List.map (\pos -> P.rect pos ( 1920, 2 ) color) y_lst
    in
    group [] (x_lines ++ y_lines)
