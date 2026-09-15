module SceneProtos.Game.Components.Drop.Model exposing
    ( component
    , Data
    , init
    )

{-| Component model

@docs component
@docs Data
@docs init

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.DW.BlockLogic exposing (UpdateKind(..))
import SceneProtos.Game.Components.Drop.Dropapply exposing (apply_drop, decreasecount)
import SceneProtos.Game.Components.Drop.Dropgen exposing (add_drops, addallcount, deleted_drops, move_drops, remained_drops)
import SceneProtos.Game.Components.Drop.Dropview exposing (view_life_got, viewdropsWithTexture)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..), Singledrop)
import SceneProtos.Game.Components.Drop.Viewhelper exposing (keyrender, view_energy_got, view_scatter_got)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data model for the drop component.
`drops`: List of drops currently in the game.
`playerpos`: Position of the player.
`lifedrop`: Count of life drops available.
`energydrop`: Count of energy drops available.
`scatterdrop`: Count of scatter bullet drops available.

Example:
{ drops = []
, playerpos = ( 0, 0 )
, lifedrop = 1
, energydrop = 1
, scatterdrop = 1
}

-}
type alias Data =
    { drops : List Singledrop
    , playerpos : ( Float, Float )
    , lifedrop : Int
    , energydrop : Int
    , scatterdrop : Int
    }


{-| Initializes the drop component with the provided data.
-}
init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        DropInitMsg initdata ->
            ( { drops = initdata.drops
              , playerpos = initdata.playerpos
              , lifedrop = initdata.lifedrop
              , energydrop = initdata.energydrop
              , scatterdrop = initdata.scatterdrop
              }
            , initBaseData
            )

        _ ->
            ( { drops = []
              , playerpos = ( 0, 0 )
              , lifedrop = 1
              , energydrop = 1
              , scatterdrop = 1
              }
            , initBaseData
            )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        Tick dt ->
            let
                drops_deleted =
                    deleted_drops data.playerpos data.drops

                newcountdata =
                    addallcount drops_deleted data

                drops_remained =
                    remained_drops data.playerpos data.drops

                newdrops =
                    move_drops dt drops_remained
            in
            ( ( { data
                    | drops = newdrops
                    , lifedrop = newcountdata.lifedrop
                    , energydrop = newcountdata.energydrop
                    , scatterdrop = newcountdata.scatterdrop
                }
              , basedata
              )
            , []
            , ( env, False )
            )

        KeyDown 49 ->
            let
                newdata =
                    decreasecount Life data
            in
            ( ( newdata, basedata ), apply_drop data Life, ( env, False ) )

        KeyDown 50 ->
            let
                newdata =
                    decreasecount Energy data
            in
            ( ( newdata, basedata ), apply_drop data Energy, ( env, False ) )

        KeyDown 51 ->
            let
                newdata =
                    decreasecount Scatterbullet data
            in
            ( ( newdata, basedata ), apply_drop data Scatterbullet, ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        EnemyDieMsg pos ->
            let
                newDrops =
                    add_drops env.globalData.currentTimeStamp pos data.drops
            in
            ( ( { data | drops = newDrops }, basedata ), [], env )

        PlayerStateMsg state ->
            let
                newpos =
                    state.position
            in
            ( ( { data | playerpos = newpos }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( group []
        [ viewdropsWithTexture data.drops
        , view_energy_got env.globalData.camera data
        , view_life_got env.globalData.camera data
        , view_scatter_got env.globalData.camera data
        , keyrender env.globalData.camera
        ]
    , 20
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Drop"


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
