module SceneProtos.Game.Components.Particle.Particlegen exposing
    ( updateParticlemodel, adddoublejumpParticles, addParticles
    , updateParticle, generateNewParticles, particleGenerator
    , randomVelocity, dropvelocity, fireparticle_pos, addDropParticles
    )

{-|


# Particlegen

Functions for generating particles in the game.

@docs updateParticlemodel, adddoublejumpParticles, addParticles
@docs updateParticle, generateNewParticles, particleGenerator
@docs randomVelocity, dropvelocity, fireparticle_pos, addDropParticles

-}

import Random
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..))
import SceneProtos.Game.Components.Particle.Init exposing (Particle, Particlemodel, Particletype(..))


{-| Updates the particle model based on the current state and delta time.
-}
updateParticlemodel : Float -> Particlemodel -> Particlemodel
updateParticlemodel dt model =
    let
        postoparticles pos =
            let
                ( newParticles, _ ) =
                    Random.step (generateNewParticles pos Bullet) model.seed
            in
            newParticles

        newSeed =
            case List.head model.bulletpos of
                Just pos ->
                    Random.step (generateNewParticles pos Bullet) model.seed
                        |> Tuple.second

                Nothing ->
                    Random.step (generateNewParticles ( 0, 0 ) Bullet) model.seed
                        |> Tuple.second

        newList =
            List.concat (List.map postoparticles model.bulletpos)

        updatedParticles =
            List.map (updateParticle dt) model.particles

        livingParticles =
            List.filter (\p -> p.lifespan > 0) updatedParticles

        allParticles =
            livingParticles ++ newList
    in
    { model | particles = allParticles, seed = newSeed }


{-| Adds double jump particles at the player's position.
This function generates particles that simulate the effect of a double jump.
-}
adddoublejumpParticles : ( Float, Float ) -> Particlemodel -> Particlemodel
adddoublejumpParticles pos model =
    let
        leftfoot =
            ( Tuple.first pos - 14, Tuple.second pos + 30 )

        rightfoot =
            ( Tuple.first pos + 14, Tuple.second pos + 30 )

        left2 =
            ( Tuple.first pos - 18, Tuple.second pos + 42 )

        right2 =
            ( Tuple.first pos + 18, Tuple.second pos + 42 )

        poslist =
            [ leftfoot, rightfoot, left2, right2 ]

        ( listlistparticles, listnewSeed ) =
            List.map (\p -> Random.step (generateNewParticles p Doublejump) model.seed) poslist
                |> List.unzip

        newparticles =
            List.concat listlistparticles

        newSeed =
            List.head listnewSeed
                |> Maybe.withDefault model.seed
    in
    { model | particles = model.particles ++ newparticles, seed = newSeed }


{-| Adds particles of a specific type at a given position.
This function generates particles based on the provided position and particle type.
-}
addParticles : ( Float, Float ) -> Particlemodel -> Particletype -> Particlemodel
addParticles pos model particletype =
    let
        ( newparticles, newseed ) =
            Random.step (generateNewParticles pos particletype) model.seed
    in
    { model | particles = model.particles ++ newparticles, seed = newseed }



-- addLaserParticles : ( Float, Float ) -> Particlemodel -> Particlemodel
-- addLaserParticles pos model =
--     let
--         ( newparticles, newseed ) =
--             Random.step (generateNewParticles pos Laser) model.seed
--     in
--     { model | particles = model.particles ++ newparticles, seed = newseed }


{-| Calculates the position of a particle based on the initial position, angle, and length.
-}
updateParticle : Float -> Particle -> Particle
updateParticle dt particle =
    let
        dtSeconds =
            dt / 1000
    in
    { particle
        | pos =
            { x = particle.pos.x + particle.vel.x * dtSeconds
            , y = particle.pos.y + particle.vel.y * dtSeconds
            }
        , lifespan = particle.lifespan - dtSeconds
    }


{-| Generates new particles based on the emitter position and particle type.
This function creates a list of particles with random properties such as velocity, size, and lifespan.
-}
generateNewParticles : ( Float, Float ) -> Particletype -> Random.Generator (List Particle)
generateNewParticles emitterPos particletype =
    let
        ( x, y ) =
            emitterPos

        pos =
            { x = x, y = y }
    in
    case particletype of
        Bullet ->
            Random.list 5 (particleGenerator pos Bullet 1 5 10 0.05 0.15 0.05 0.15)

        -- Random.list 0 (particleGenerator pos Bullet 1 5 10 0.05 0.15 0.05 0.15)
        Doublejump ->
            Random.list 15 (particleGenerator pos Doublejump 50 5 15 0.25 0.35 0.25 0.35)

        -- Random.list 0 (particleGenerator pos Doublejump 30 5 15 0.2 0.3 0.2 0.3)
        Laser ->
            Random.list 2 (particleGenerator pos Laser 100 5 10 0.2 0.4 0.2 0.4)

        Fire ->
            Random.list 2 (particleGenerator pos Fire 100 5 10 0.2 0.4 0.2 0.4)

        Drop droptype ->
            case droptype of
                Life ->
                    Random.list 5 (particleGenerator pos (Drop Life) 50 7 13 0.5 0.8 0.5 0.8)

                Energy ->
                    Random.list 5 (particleGenerator pos (Drop Energy) 50 7 13 0.5 0.8 0.5 0.8)

                Scatterbullet ->
                    Random.list 5 (particleGenerator pos (Drop Scatterbullet) 50 7 13 0.5 0.8 0.5 0.8)

        Player ->
            Random.list 1 (particleGenerator pos Player 40 4 7 0.3 0.5 0.3 0.5)

        Dw ->
            Random.list 1 (particleGenerator pos Dw 30 10 14 0.2 0.4 0.2 0.4)


{-| Generator for a particle with specific properties such as position, velocity, size, lifespan, and maximum lifespan.
-}
particleGenerator : { x : Float, y : Float } -> Particletype -> Float -> Int -> Int -> Float -> Float -> Float -> Float -> Random.Generator Particle
particleGenerator pos particletype v sizemin sizemax lifemin lifemax maxlifemin maxlifemax =
    Random.map5 (Particle particletype)
        -- Position of the particle
        (Random.constant pos)
        -- Slightly slower velocity can look better for pixel styles
        (case particletype of
            Drop _ ->
                dropvelocity v

            _ ->
                randomVelocity v
        )
        -- Generate integer sizes (2x2, 3x3, 4x4 pixels)
        (Random.map toFloat (Random.int sizemin sizemax))
        -- A particle's lifespan
        (Random.float lifemin lifemax)
        -- The maximum lifespan of a particle
        (Random.float maxlifemin maxlifemax)



-- _ ->
--     Random.map5 (Particle particletype)
--         -- Position of the particle
--         (Random.constant pos)
--         -- Slightly slower velocity can look better for pixel styles
--         (randomVelocity v)
--         -- Generate integer sizes (2x2, 3x3, 4x4 pixels)
--         (Random.map toFloat (Random.int sizemin sizemax))
--         -- A particle's lifespan
--         (Random.float lifemin lifemax)
--         -- The maximum lifespan of a particle
--         (Random.float maxlifemin maxlifemax)


{-| Generator for a random velocity for a particle within a specified maximum speed.
-}
randomVelocity : Float -> Random.Generator { x : Float, y : Float }
randomVelocity maxSpeed =
    Random.map2 (\x y -> { x = x, y = y })
        (Random.float -maxSpeed maxSpeed)
        (Random.float -maxSpeed maxSpeed)


{-| Generator for a random velocity for a drop particle within a specified maximum speed.
This function is similar to `randomVelocity` but tailored for drop particles.
-}
dropvelocity : Float -> Random.Generator { x : Float, y : Float }
dropvelocity maxSpeed =
    Random.map2 (\x y -> { x = x, y = y })
        (Random.float -(maxSpeed * 0.5) (maxSpeed * 0.5))
        (Random.float -maxSpeed 0)


{-| Calculates the position for fire particles based on the initial position, angle, and direction.
-}
fireparticle_pos : ( Float, Float ) -> Float -> Float -> ( Float, Float )
fireparticle_pos position angle direction =
    let
        ( x, y ) =
            position

        ( x1, y1 ) =
            ( x + 30 * cos angle * direction, y - 30 * sin angle * direction )
    in
    ( x1, y1 )


{-| Adds drop particles at a specific position based on the droptype.
This function generates particles that simulate the effect of drops, such as life or energy.
-}
addDropParticles : ( Float, Float ) -> Droptype -> Particlemodel -> Particlemodel
addDropParticles pos droptype model =
    let
        ( x0, y0 ) =
            pos

        l1 =
            ( x0 - 10, y0 - 40 )

        r1 =
            ( x0 + 10, y0 - 30 )

        l2 =
            ( x0 - 22, y0 - 10 )

        r2 =
            ( x0 + 22, y0 )

        m1 =
            ( x0 - 15, y0 + 20 )

        m2 =
            ( x0 + 15, y0 + 25 )

        ( p1, s1 ) =
            Random.step (generateNewParticles l1 (Drop droptype)) model.seed

        ( p2, s2 ) =
            Random.step (generateNewParticles r1 (Drop droptype)) s1

        ( p3, s3 ) =
            Random.step (generateNewParticles l2 (Drop droptype)) s2

        ( p4, s4 ) =
            Random.step (generateNewParticles r2 (Drop droptype)) s3

        ( p5, newSeed ) =
            Random.step (generateNewParticles m1 (Drop droptype)) s4

        ( p6, _ ) =
            Random.step (generateNewParticles m2 (Drop droptype)) newSeed
    in
    { model | particles = model.particles ++ p1 ++ p2 ++ p3 ++ p4 ++ p5 ++ p6, seed = newSeed }
