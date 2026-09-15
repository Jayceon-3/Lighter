module SceneProtos.Game.Components.Particle.Particleview exposing
    ( genColor, whitecolorset1, bluecolorset1, bluecolorset2, yellowcolorset1, greencolorset1, yellowcolorset2, purplecolorset1
    , lifespanToColor, viewParticle, viewParticlemodel
    )

{-|


# Particleview

Functions for rendering particles in the game.

@docs genColor, whitecolorset1, bluecolorset1, bluecolorset2, yellowcolorset1, greencolorset1, yellowcolorset2, purplecolorset1
@docs lifespanToColor, viewParticle, viewParticlemodel

-}

import Color exposing (Color)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..))
import SceneProtos.Game.Components.Particle.Init exposing (Particle, Particlemodel, Particletype(..))


{-| Generates a color based on the provided RGBA values.
-}
genColor : Float -> Float -> Float -> Float -> Color
genColor r g b a =
    Color.fromRgba
        { red = r
        , green = g
        , blue = b
        , alpha = a
        }


{-| List of colors for white colorset1.
-}
whitecolorset1 : List Color
whitecolorset1 =
    -- [ genColor 1 0.92549 0.3491 1 -- Bright Yellow
    -- , genColor 1 0.6156 0.1682 1 -- Orange
    -- , genColor 0.8196 0.3333 0.16078 1 -- Burnt Orange
    -- , genColor 0.34117 0.17254 0.23529 1 -- Dark Purple/Brown
    -- ]
    [ genColor (255 / 255) (255 / 255) (255 / 255) 1
    , genColor (215 / 255) (215 / 255) (215 / 255) 1
    , genColor (185 / 255) (185 / 255) (185 / 255) 1
    , genColor (65 / 255) (65 / 255) (65 / 255) 1
    ]


{-| List of colors for blue colorset1.
-}
bluecolorset1 : List Color
bluecolorset1 =
    [ genColor (153 / 255) (214 / 255) (255 / 255) 1 -- Bright Blue
    , genColor (60 / 255) (71 / 255) (236 / 255) 1 -- Deep Blue
    , genColor (148 / 255) (68 / 255) (214 / 255) 1 -- Purple
    , genColor (99 / 255) (33 / 255) (255 / 255) 1 -- dark Purple
    ]


{-| List of colors for blue colorset2.
-}
bluecolorset2 : List Color
bluecolorset2 =
    [ genColor (99 / 255) (33 / 255) (255 / 255) 1 -- dark Purple
    , genColor (15 / 255) (83 / 255) (249 / 255) 1 -- dark blue
    , genColor (128 / 255) (164 / 255) (254 / 255) 1 -- Deep Blue
    , genColor (235 / 255) (241 / 255) (255 / 255) 1 -- Bright Blue
    ]


{-| List of colors for yellow colorset1.
-}
yellowcolorset1 : List Color
yellowcolorset1 =
    [ genColor (255 / 255) (159 / 255) (0 / 255) 1
    , genColor (255 / 255) (232 / 255) (2 / 255) 1
    , genColor (255 / 255) (255 / 255) (95 / 255) 1
    , genColor (254 / 255) (249 / 255) (231 / 255) 1 -- light yellow
    ]


{-| List of colors for green colorset1.
-}
greencolorset1 : List Color
greencolorset1 =
    [ genColor (10 / 255) (170 / 255) (40 / 255) 1 -- Darkest Green
    , genColor (42 / 255) (228 / 255) (138 / 255) 1 -- Darker Green
    , genColor (10 / 255) (226 / 255) (30 / 255) 1 -- Dark Green
    , genColor (10 / 255) (255 / 255) (0 / 255) 1 -- Bright Green
    ]


{-| List of colors for yellow colorset2.
-}
yellowcolorset2 : List Color
yellowcolorset2 =
    [ genColor (220 / 255) (150 / 255) (6 / 255) 1
    , genColor (255 / 255) (190 / 255) (0 / 255) 1
    , genColor (245 / 255) (245 / 255) (0 / 255) 1
    , genColor (255 / 255) (255 / 255) (0 / 255) 1
    ]


{-| List of colors for purple colorset1.
-}
purplecolorset1 : List Color
purplecolorset1 =
    [ genColor (106 / 255) (9 / 255) (254 / 255) 1 -- Purple
    , genColor (133 / 255) (51 / 255) (255 / 255) 1 -- Light Purple
    , genColor (153 / 255) (102 / 255) (255 / 255) 1 -- Lighter Purple
    , genColor (188 / 255) (206 / 255) (255 / 255) 1 -- Lightest Purple
    ]


purplecolorset2 : List Color
purplecolorset2 =
    -- [ genColor (244 / 255) (236 / 255) (247 / 255) 1
    [ genColor (203 / 255) (214 / 255) (255 / 255) 1 -- Bright Blue
    , genColor (175 / 255) (122 / 255) (197 / 255) 1
    , genColor (118 / 255) (68 / 255) (138 / 255) 1
    , genColor (74 / 255) (35 / 255) (90 / 255) 1
    ]


{-| Determine the color of a particle based on its lifespan and type.
This function maps the lifespan of the particle to a color from a predefined color set based on its type.
-}
lifespanToColor : Particle -> Particletype -> Color
lifespanToColor particle particletype =
    let
        lifePercent =
            particle.lifespan / particle.maxLifespan

        colorset =
            case particletype of
                Bullet ->
                    bluecolorset1

                Doublejump ->
                    whitecolorset1

                Laser ->
                    yellowcolorset1

                Fire ->
                    bluecolorset2

                Drop droptype ->
                    case droptype of
                        Life ->
                            greencolorset1

                        Energy ->
                            yellowcolorset2

                        Scatterbullet ->
                            purplecolorset1

                Player ->
                    purplecolorset2

                Dw ->
                    bluecolorset1

        color =
            if lifePercent > 0.75 then
                List.head colorset
                    |> Maybe.withDefault (genColor 0 0 0 1)

            else if lifePercent > 0.5 then
                List.head (List.drop 1 colorset)
                    |> Maybe.withDefault (genColor 0 0 0 1)

            else if lifePercent > 0.25 then
                List.head (List.drop 2 colorset)
                    |> Maybe.withDefault (genColor 0 0 0 1)

            else
                List.head (List.drop 3 colorset)
                    |> Maybe.withDefault (genColor 0 0 0 1)
    in
    color


{-| Renders a single particle based on its properties.
-}
viewParticle : Particle -> Renderable
viewParticle particle =
    let
        ( x, y ) =
            ( particle.pos.x, particle.pos.y )

        ( w, h ) =
            ( particle.size, particle.size )

        color =
            lifespanToColor particle particle.partitype
    in
    P.rectCentered ( x, y ) ( w, h ) 0 color


{-| Renders a list of particles in the particle model.
-}
viewParticlemodel : Particlemodel -> List Renderable
viewParticlemodel model =
    let
        particles =
            List.map viewParticle model.particles
    in
    particles
