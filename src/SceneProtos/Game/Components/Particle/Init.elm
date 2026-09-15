module SceneProtos.Game.Components.Particle.Init exposing
    ( InitData
    , Particle
    , Particlemodel
    , Particletype(..)
    )

{-|


# Init module

Initialization for particle components in the game.

@docs InitData
@docs Particle
@docs Particlemodel
@docs Particletype

-}

import Random
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..))


{-| Definition of a particle.
`partitype`: the type of the particle (Bullet, Doublejump, Laser, Fire, or Drop)
`pos`: the position of the particle
`vel`: the velocity of the particle
`size`: the size of the particle
`lifespan`: the current lifespan of the particle
`maxLifespan`: the maximum lifespan of the particle

Example:
{ partitype = Bullet
, pos = { x = 100, y = 200 }
, vel = { x = 1, y = 1 }
, size = 5
, lifespan = 0.5
, maxLifespan = 1.0
}

-}
type alias Particle =
    { partitype : Particletype
    , pos : { x : Float, y : Float }
    , vel : { x : Float, y : Float }
    , size : Float
    , lifespan : Float
    , maxLifespan : Float
    }


{-| Definition of a particle model.
`particles`: a list of particles in the model
`bulletpos`: a list of positions for bullet particles
`seed`: a random seed for particle generation

Example:
{ particles = [ { partitype = Bullet, pos = { x = 100, y = 200 }, vel = { x = 1, y = 1 }, size = 5, lifespan = 0.5, maxLifespan = 1.0 } ]
, bulletpos = [ ( 100, 200 ), ( 150, 250 ) ]
, seed = Random.initialSeed 42
}

-}
type alias Particlemodel =
    { particles : List Particle
    , bulletpos : List ( Float, Float )
    , seed : Random.Seed
    }


{-| The type of particle, which can be either a Bullet, Doublejump, Laser, Fire, or Drop.
-}
type Particletype
    = Bullet
    | Doublejump
    | Laser
    | Fire
    | Drop Droptype
    | Player
    | Dw


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , particlemodel : Particlemodel
    , playerpos : ( Float, Float )
    , mousepressed : Bool
    , lasertime : Float
    , energy : Float
    }
