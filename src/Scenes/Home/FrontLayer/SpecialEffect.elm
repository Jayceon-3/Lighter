module Scenes.Home.FrontLayer.SpecialEffect exposing (flickerOn, gen_text, jitterOffset, shouldJitter)

{-|


# SpecialEffect

Functions for implementing special effects.

@docs flickerOn, gen_text, jitterOffset, shouldJitter

-}


{-| Realize flicker effect.
When the scene is entered, the object will be invisible for 0.1s in every 10 seconds..
-}
flickerOn : Float -> Bool
flickerOn time =
    let
        t =
            time / 1000

        period =
            10

        onDuration =
            9.9

        phase =
            modByFloat period t
    in
    phase < onDuration


modByFloat : Float -> Float -> Float
modByFloat modulus x =
    x - toFloat (floor (x / modulus)) * modulus


{-| Describe the trajectory of jitter.
-}
jitterOffset : Float -> Float
jitterOffset time =
    let
        t =
            time / 1000

        frequency =
            20

        amplitude =
            15
    in
    amplitude * sin (2 * pi * frequency * t)


{-| Before the object is about to disappear, it will jitter.
-}
shouldJitter : Float -> Bool
shouldJitter time =
    let
        t =
            time / 1000

        period =
            10

        onDuration =
            9.9

        jitterLeadTime =
            0.1

        phase =
            modByFloat period t
    in
    phase < onDuration && (onDuration - phase) <= jitterLeadTime


{-| Generate the slogan word by word.
-}
gen_text : Int -> String
gen_text num =
    let
        text =
            "From the Void, Infinite Possibilities."

        old_lst =
            String.toList text

        new_lst =
            List.take num old_lst

        new_text =
            String.fromList new_lst
    in
    new_text
