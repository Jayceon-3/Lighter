module SceneProtos.Game.Components.Guidance.Model exposing (component)

{-| Component model

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data structure for the Guidance component.
`id`: Unique identifier for the component.
`ty`: Type of the component, here it is "Guidance".

Example:

    { id = 8
    , ty = "Guidance"
    }

-}
type alias Data =
    { id : Int
    , ty : String
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        GuideInitMsg data ->
            ( { id = 8, ty = "Guidance" }, initBaseData )

        _ ->
            ( { id = 8, ty = "Guidance" }, initBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    if env.globalData.userData.currentlevel == 1 then
        ( lv1 env.globalData.userData, 5 )

    else if env.globalData.userData.currentlevel == 2 then
        ( lv2 env.globalData.userData, 5 )

    else
        ( P.empty, 0 )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Guidance"


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


lv1 : UserData -> Renderable
lv1 ud =
    let
        guidance1 =
            "use 'W/A/D' to move, \nand press 'W' twice to double jump"

        guidance2 =
            "What's beneath?"

        --guidance2I =
        --"- - - - - - - - - - - - - - - - - - -"
        guidance3 =
            "click left mouse button to shoot\npress 'E' to hold a shield. \nWhen holding shield, click right mouse to put down it. \nYou will get slower when holding shield."

        guidance4 =
            "press 'S' to look down"

        guidance5 =
            "be careful of the fake ground"

        guidance6 =
            "some bricks are affected by the digital world\n they will offer different buffs\n press 'Q' to enter the digital world and check"

        guidance6I =
            "be careful of the damaging bricks"

        guidance6II =
            "you can restore hp on recovery bricks"

        guidance7 =
            "in digital world, you can't use any weapon, but you can see the nature of the world\nfind and collect 3 keys in digital world to enter next level\ncollect the key by stepping on it in digital world"

        guidance8 =
            "if you don't know how to go upper, \njust try mechanical arm by clicking right mouse button"

        --guidance9 =
        --"collect the key by touching it from above"
        guidance10 =
            "Here are 3 kind of supplies. \nWhen enemies die, they will drop supplies. \nYou can apply them by pressing 1/2/3."

        allGuidance =
            group []
                [ P.textboxCentered ( 350, 2170 ) 30 guidance1 "consolas" Color.grey
                , P.textboxCentered ( 1850, 1640 ) 30 guidance2 "consolas" Color.grey

                --, P.textboxCentered ( 1850, 1770 ) 30 guidance2I "consolas" Color.grey
                , P.textboxCentered ( 700, 1670 ) 30 guidance3 "consolas" Color.grey
                , P.textboxCentered ( 1850, 1700 ) 30 guidance4 "consolas" Color.grey
                , P.textboxCentered ( 520, 790 ) 30 guidance5 "consolas" Color.grey
                , P.textboxCentered ( 650, 300 ) 30 guidance6 "consolas" Color.grey
                , P.textboxCentered ( 2400, 220 ) 30 guidance7 "consolas" Color.grey
                , P.textboxCentered ( 1800, 2000 ) 30 guidance8 "consolas" Color.grey
                , P.textboxCentered ( 1800, 2170 ) 30 guidance10 "consolas" Color.grey
                ]

        dwGuidance =
            if ud.dw then
                group []
                    [ --P.textboxCentered ( 4150, 930 ) 30 guidance9 "consolas" Color.grey
                      P.textboxCentered ( 650, 400 ) 30 guidance6I "consolas" Color.grey
                    , P.textboxCentered ( 1220, 570 ) 30 guidance6II "consolas" Color.grey
                    ]

            else
                P.empty
    in
    group [] [ allGuidance, dwGuidance ]


lv2 : UserData -> Renderable
lv2 ud =
    let
        guidance1 =
            "pay attention to the time limit"

        guidance2 =
            "using weapons will cost energy"
    in
    group []
        [ P.textboxCentered ( 360, 1860 ) 30 guidance1 "consolas" Color.grey
        , P.textboxCentered ( 360, 1890 ) 30 guidance2 "consolas" Color.grey
        ]
