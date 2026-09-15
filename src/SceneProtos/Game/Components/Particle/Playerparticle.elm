module SceneProtos.Game.Components.Particle.Playerparticle exposing (addPlayerParticles, addDwParticles)

{-|


# Playerparticle

Functions for adding particles to the player.

@docs addPlayerParticles, addDwParticles

-}

import Random
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..))
import SceneProtos.Game.Components.Particle.Init exposing (Particle, Particlemodel, Particletype(..))
import SceneProtos.Game.Components.Particle.Particlegen exposing (generateNewParticles)


{-| Add particles to player.
-}
addPlayerParticles : ( Float, Float ) -> Particlemodel -> Particletype -> Particlemodel
addPlayerParticles pos model particletype =
    let
        newpos =
            ( Tuple.first pos, Tuple.second pos - 15 )

        ( newparticles, newseed ) =
            Random.step
                (generateNewParticles newpos particletype)
                model.seed
    in
    { model
        | particles = model.particles ++ newparticles
        , seed = newseed
    }


{-| Add particles in DW.
-}
addDwParticles : ( Float, Float ) -> Particlemodel -> Particletype -> Particlemodel
addDwParticles pos model particletype =
    let
        ( x0, y0 ) =
            pos

        l1 =
            ( x0 - 5, y0 - 28 )

        r1 =
            ( x0 + 5, y0 - 18 )

        l2 =
            ( x0 - 12, y0 - 5 )

        r2 =
            ( x0 + 12, y0 + 5 )

        m1 =
            ( x0 - 10, y0 + 15 )

        m2 =
            ( x0 + 10, y0 + 20 )

        ( p1, s1 ) =
            Random.step (generateNewParticles l1 particletype) model.seed

        ( p2, s2 ) =
            Random.step (generateNewParticles r1 particletype) s1

        ( p3, s3 ) =
            Random.step (generateNewParticles l2 particletype) s2

        ( p4, s4 ) =
            Random.step (generateNewParticles r2 particletype) s3

        ( p5, newSeed ) =
            Random.step (generateNewParticles m1 particletype) s4

        ( p6, _ ) =
            Random.step (generateNewParticles m2 particletype) newSeed
    in
    { model | particles = model.particles ++ p1 ++ p2 ++ p3 ++ p4 ++ p5 ++ p6, seed = newSeed }
