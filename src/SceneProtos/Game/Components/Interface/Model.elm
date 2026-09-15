module SceneProtos.Game.Components.Interface.Model exposing (component)

{-| Component model

@docs component

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Audio.Base exposing (AudioOption(..), AudioTarget(..))
import Messenger.Base exposing (Env, UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.Interface.RenderHelp exposing (adjustVolume, inExit, inExitPause, interfaceRender)
import SceneProtos.Game.Components.Player.Coordtransform exposing (..)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data structure for the Interface component.
`id`: Unique identifier for the component.
`ty`: Type of the component, here it is "Interface".
`isDead`: Indicates if the player is dead.
`isHelpFolded`: Indicates if the help section is folded.
`isWin`: Indicates if the player has won.
`timeLeft`: The time left in the game, used for countdowns.
Example:

    { id = 10
    , ty = "Interface"
    , isDead = False
    , isHelpFolded = False
    , isWin = False
    , timeLeft = 180.0
    }

-}
type alias Data =
    { id : Int
    , ty : String
    , isDead : Bool
    , isHelpFolded : Bool
    , isWin : Bool
    , timeLeft : Float
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        InterfaceInitMsg _ ->
            ( { id = 10, ty = "Interface", isDead = False, isHelpFolded = False, isWin = False, timeLeft = 180.0 }, initBaseData )

        _ ->
            ( { id = 10, ty = "Interface", isDead = False, isHelpFolded = False, isWin = False, timeLeft = -1 }, initBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    let
        noChange =
            ( ( data, basedata ), [], ( env, False ) )

        exitToHome =
            ( ( data, basedata )
            , [ Parent (SOMMsg (SOMChangeScene Nothing "Home")), Parent <| SOMMsg <| SOMStopAudio <| AudioName 0 "battle" ]
            , ( resetCameraAndUserData env, False )
            )

        togglePause =
            ( ( data, basedata )
            , [ Other ( "Interface", ChangePause )
              , Other ( "Weapon", ChangePause )
              , Other ( "Player", ChangePause )
              , Other ( "Enemy", ChangePause )
              , Other ( "DW", ChangePause )
              , Other ( "Bullet", ChangePause )
              , Other ( "Boss", ChangePause )
              ]
            , ( env, False )
            )

        checkExit ( x, y ) =
            inExit env.globalData.userData.canvas_mouse_pos env
                || inExit ( x, y ) env
                || inExitPause ( x, y )
                || inExitPause env.globalData.userData.canvas_mouse_pos
    in
    case env.globalData.sceneStartFrame of
        0 ->
            ( ( data, basedata )
            , [ Parent <| SOMMsg <| SOMStopAudio <| AudioName 0 "battle" ]
            , ( env, False )
            )

        1 ->
            ( ( data, basedata )
            , [ Parent <| SOMMsg <| SOMPlayAudio 0 "battle" <| ALoop Nothing Nothing ]
            , ( env, False )
            )

        _ ->
            case evnt of
                MouseDown 0 pos ->
                    if basedata.isPaused || data.isWin || data.isDead then
                        if checkExit pos then
                            exitToHome

                        else
                            noChange

                    else
                        noChange

                KeyDown 38 ->
                    if basedata.isPaused then
                        adjustVolume 0.05 env data basedata

                    else
                        noChange

                KeyDown 40 ->
                    if basedata.isPaused then
                        adjustVolume -0.05 env data basedata

                    else
                        noChange

                KeyDown 27 ->
                    if not data.isDead then
                        togglePause

                    else
                        noChange

                KeyDown 13 ->
                    if data.isWin || data.isDead then
                        let
                            level =
                                env.globalData.userData.currentlevel

                            sceneName =
                                if basedata.isPaused then
                                    "Level" ++ String.fromInt level

                                else
                                    "Transition" ++ String.fromInt level
                        in
                        ( ( data, basedata )
                        , [ Parent (SOMMsg SOMSaveGlobalData)
                          , Parent (SOMMsg (SOMChangeScene Nothing sceneName))
                          ]
                        , ( resetCameraAndUserData env, False )
                        )

                    else
                        noChange

                KeyDown 72 ->
                    ( ( { data | isHelpFolded = not data.isHelpFolded }, basedata )
                    , []
                    , ( env, False )
                    )

                KeyDown 66 ->
                    ( ( data, basedata )
                    , [ Parent (SOMMsg (SOMChangeScene Nothing "Demo"))
                      , Parent <| SOMMsg <| SOMStopAudio <| AudioName 0 "battle"
                      ]
                    , ( resetCameraAndUserData env, False )
                    )

                Tick dt ->
                    if env.globalData.userData.currentlevel == 1 then
                        noChange

                    else if not (data.isWin || data.isDead || basedata.isPaused) then
                        let
                            newTimeLeft =
                                data.timeLeft - dt / 1000
                        in
                        if newTimeLeft <= 0 then
                            ( ( { data | isDead = True, timeLeft = 0 }, { basedata | isPaused = True } ), [], ( env, False ) )

                        else
                            ( ( { data | timeLeft = newTimeLeft }, basedata )
                            , []
                            , ( env, False )
                            )

                    else
                        noChange

                _ ->
                    noChange


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        ChangePause ->
            ( ( data, { basedata | isPaused = not basedata.isPaused } )
            , []
            , env
            )

        PlayerDeadMsg ->
            ( ( { data | isDead = True }, { basedata | isPaused = True } ), [], env )

        WinMsg ->
            let
                gdata =
                    env.globalData

                oldUserData =
                    env.globalData.userData

                newUserData =
                    { oldUserData | currentlevel = oldUserData.currentlevel + 1 }

                newGlobalData =
                    { gdata | userData = newUserData }

                newEnv =
                    { env | globalData = newGlobalData }
            in
            ( ( { data | isWin = True }
              , { basedata | isPaused = True }
              )
            , [ Other ( "Interface", ChangePause )
              , Other ( "Weapon", ChangePause )
              , Other ( "Player", ChangePause )
              , Other ( "Enemy", ChangePause )
              , Other ( "DW", ChangePause )
              , Other ( "Bullet", ChangePause )
              , Other ( "Ceo", ChangePause )
              , Other ( "Boss", ChangePause )
              , Parent <| SOMMsg <| SOMSaveGlobalData
              ]
            , newEnv
            )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    interfaceRender env data basedata


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Interface"


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


resetCameraAndUserData : Env SceneCommonData UserData -> Env SceneCommonData UserData
resetCameraAndUserData env =
    let
        gdata =
            env.globalData

        ( oldcamera, oldUserdata ) =
            ( gdata.camera, gdata.userData )
    in
    { env
        | globalData =
            { gdata
                | camera = { oldcamera | x = 960, y = 540 }
                , userData = { oldUserdata | dw = False }
            }
    }
