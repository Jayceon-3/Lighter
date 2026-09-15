module SceneProtos.Game.Components.Particle.Model exposing (component)

{-| Component model

@docs component

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import Random
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..))
import SceneProtos.Game.Components.Particle.Init exposing (Particlemodel, Particletype(..))
import SceneProtos.Game.Components.Particle.Particlegen exposing (addDropParticles, addParticles, adddoublejumpParticles, fireparticle_pos, updateParticlemodel)
import SceneProtos.Game.Components.Particle.Particleview exposing (viewParticlemodel)
import SceneProtos.Game.Components.Particle.Playerparticle exposing (addDwParticles, addPlayerParticles)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data model for the particle component.
`particlemodel`: The model containing the particles and their properties.
`playerpos`: The position of the player in the game scene.
`firepos`: The position where the fire particles are generated.
`mousepressed`: Indicates if the mouse is pressed, used to trigger particle generation.
`lasertime`: The last time the laser was fired, used to control firing rate.
`energy`: The current energy level of the player, used to determine if the player can fire.
`order`: The rendering order of the particle component.

Example:
{ particlemodel = { particles = [], bulletpos = [], seed = Random.initialSeed 23456 }
, playerpos = ( 0, 0 )
, firepos = ( 0, 0 )
, mousepressed = False
, lasertime = 0
, energy = 100
, order = 1
}

-}
type alias Data =
    { particlemodel : Particlemodel
    , playerpos : ( Float, Float )
    , firepos : ( Float, Float )
    , mousepressed : Bool
    , lasertime : Float
    , energy : Float
    , order : Int
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        ParticleInitMsg data ->
            ( { particlemodel = data.particlemodel
              , playerpos = data.playerpos
              , firepos = ( 0, 0 )
              , mousepressed = data.mousepressed
              , lasertime = data.lasertime
              , energy = data.energy
              , order = 1
              }
            , initBaseData
            )

        _ ->
            ( { particlemodel =
                    { particles = []
                    , bulletpos = []
                    , seed = Random.initialSeed 23456
                    }
              , playerpos = ( 0, 0 )
              , firepos = ( 0, 0 )
              , mousepressed = False
              , lasertime = 0
              , energy = 100
              , order = 1
              }
            , initBaseData
            )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        Tick dt ->
            let
                newparticlemodel =
                    updateParticlemodel dt data.particlemodel

                new =
                    if not env.globalData.userData.dw && data.mousepressed then
                        if (env.globalData.currentTimeStamp - data.lasertime) / 1000 >= 1 && data.energy >= 50 then
                            addParticles data.firepos newparticlemodel Laser

                        else
                            addParticles data.firepos newparticlemodel Fire

                    else
                        newparticlemodel
            in
            ( ( { data | particlemodel = new }, basedata ), [], ( env, False ) )

        MouseDown 0 _ ->
            ( ( { data | mousepressed = True, lasertime = env.globalData.currentTimeStamp }, basedata ), [], ( env, False ) )

        MouseUp 0 _ ->
            ( ( { data | mousepressed = False }, basedata ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        Bullets bullets ->
            let
                pos =
                    List.map (\bullet -> bullet.position) bullets

                oldparticlemodel =
                    data.particlemodel

                newparticlemodel =
                    { oldparticlemodel | bulletpos = pos }
            in
            ( ( { data | particlemodel = newparticlemodel }, basedata ), [], env )

        DoublejumpMsg pos ->
            let
                newPlayerPos =
                    pos

                newparticlemodel =
                    adddoublejumpParticles newPlayerPos data.particlemodel
            in
            ( ( { data
                    | playerpos = newPlayerPos
                    , particlemodel = newparticlemodel
                }
              , basedata
              )
            , []
            , env
            )

        WeaponStateMsg state ->
            let
                ( pos, updateenergy ) =
                    ( fireparticle_pos
                        state.position
                        state.angle
                        state.direction
                    , state.energy
                    )
            in
            ( ( { data | firepos = pos, energy = updateenergy }, basedata ), [], env )

        PlayerStateMsg playerState ->
            let
                newPlayerp =
                    playerState.position

                newparticlemodel =
                    if not <| env.globalData.userData.dw then
                        addPlayerParticles newPlayerp data.particlemodel Player

                    else
                        addDwParticles newPlayerp data.particlemodel Dw
            in
            ( ( { data
                    | playerpos = newPlayerp
                    , particlemodel = newparticlemodel
                }
              , basedata
              )
            , []
            , env
            )

        DropMsg droptype ->
            let
                newparticlemodel =
                    addDropParticles data.playerpos droptype data.particlemodel
            in
            ( ( { data | particlemodel = newparticlemodel }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( group []
        (viewParticlemodel
            data.particlemodel
        )
    , 5
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher _ _ tar =
    tar == "Particle"


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
