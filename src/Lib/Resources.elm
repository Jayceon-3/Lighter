module Lib.Resources exposing (resources)

{-|


# Textures

@docs resources

-}

import Lib.Resourcehelp exposing (background1, background2, background3, background4, bullets, button, ceosprite, enemygun, enemyknife, enemyrun, enemystand, enemywalk, symbol, tiles)
import Messenger.Resources.Base exposing (ResourceDef(..), ResourceDefs)
import REGL exposing (..)


{-| Resources
-}
resources : ResourceDefs
resources =
    allTexture ++ allAudio ++ allFont ++ allProgram


{-| allTexture

A list of all the textures.

Add your textures here. Don't worry if your list is too long.

Example:

        [ ( "ball", TextureRes "assets/img/ball.png" Nothing )
        , ( "car", TextureRes "assets/img/car.jpg" Nothing )
        ]

-}
allTexture : ResourceDefs
allTexture =
    [ ( "home", TextureRes "assets/img/home.png" Nothing )
    , ( "name", TextureRes "assets/img/name.png" Nothing )
    , ( "logo", TextureRes "assets/img/logo.png" Nothing )
    , ( "gameBT", TextureRes "assets/img/gameBT.png" Nothing )
    , ( "helpBT", TextureRes "assets/img/helpBT.png" Nothing )
    , ( "gun", TextureRes "assets/img/gun.png" Nothing )
    , ( "keyArrow", TextureRes "assets/img/keyArrow.png" Nothing )
    , ( "marm", TextureRes "assets/img/marm.png" Nothing )
    , ( "hand1", TextureRes "assets/img/Enemy1/hand1.png" Nothing )
    , ( "hand2", TextureRes "assets/img/Enemy2/hand2.png" Nothing )
    , ( "hand3", TextureRes "assets/img/Enemy3/hand3.png" Nothing )
    , ( "bosshead", TextureRes "assets/img/Ceo/boss.png" Nothing )
    ]
        ++ laser
        ++ key
        ++ idle
        ++ run
        ++ jump
        ++ background1
        ++ background2
        ++ background3
        ++ background4
        ++ tiles
        ++ symbol
        ++ button
        ++ tiles
        ++ shield
        ++ enemyrun 1
        ++ enemyrun 2
        ++ enemyrun 3
        ++ enemystand 1
        ++ enemystand 2
        ++ enemystand 3
        ++ enemywalk 1
        ++ enemywalk 2
        ++ enemywalk 3
        ++ enemygun
        ++ enemyknife 1
        ++ enemyknife 2
        ++ enemyknife 3
        ++ ceosprite
        ++ drops
        ++ bullets


{-| All audio assets.

The format is similar to `allTexture`.

Example:

        [ ( "test", AudioRes "assets/test.ogg" )
        ]

-}
allAudio : ResourceDefs
allAudio =
    [ ( "battle", AudioRes "assets/audio/cyberpunk_beat.ogg" )
    , ( "bullet", AudioRes "assets/audio/bullet.ogg" )
    , ( "laser", AudioRes "assets/audio/laser.ogg" )
    ]


{-| All fonts.

Example:

        [ ( "firacode", FontRes "assets/FiraCode-Regular.png" "assets/FiraCode-Regular.json" )
        ]

-}
allFont : ResourceDefs
allFont =
    []


{-| All programs.

Example:

        [ ( "test", ProgramRes myprogram )
        ]

-}
allProgram : ResourceDefs
allProgram =
    []


lasersize : List Int
lasersize =
    [ 8 ]


laser : ResourceDefs
laser =
    List.concat <|
        List.indexedMap
            (\row colsize ->
                List.map
                    (\col ->
                        ( "laser" ++ String.fromInt row ++ String.fromInt col
                        , TextureRes "assets/img/laser.png"
                            (Just
                                { mag = Just MagNearest
                                , min = Nothing
                                , crop = Just ( ( 72 * col, 72 * row ), ( 72, 72 ) )
                                }
                            )
                        )
                    )
                <|
                    List.range 0 colsize
            )
            lasersize


life : ResourceDefs
life =
    [ ( "life", TextureRes "assets/img/life.png" Nothing ) ]


energy : ResourceDefs
energy =
    [ ( "energy", TextureRes "assets/img/energy.png" Nothing ) ]


scatter : ResourceDefs
scatter =
    [ ( "scatter", TextureRes "assets/img/scatter.png" Nothing ) ]


drops : ResourceDefs
drops =
    life ++ energy ++ scatter


shield : ResourceDefs
shield =
    List.map
        (\col ->
            ( "Shield" ++ String.fromInt col
            , TextureRes "assets/img/Shield.png"
                (Just
                    { mag = Just MagNearest
                    , min = Nothing
                    , crop = Just ( ( 48 * col, 0 ), ( 48, 48 ) )
                    }
                )
            )
        )
    <|
        List.range 0 8


key : ResourceDefs
key =
    List.map
        (\col ->
            ( "Key" ++ String.fromInt col
            , TextureRes "assets/img/key.png"
                (Just
                    { mag = Just MagNearest
                    , min = Nothing
                    , crop = Just ( ( 16 * col, 0 ), ( 16, 16 ) )
                    }
                )
            )
        )
    <|
        List.range 0 3


idle : ResourceDefs
idle =
    List.map
        (\col ->
            ( "Idle" ++ String.fromInt col
            , TextureRes "assets/img/Idle1.png"
                (Just
                    { mag = Just MagNearest
                    , min = Nothing
                    , crop = Just ( ( 48 * col, 0 ), ( 48, 48 ) )
                    }
                )
            )
        )
    <|
        List.range 0 7


run : ResourceDefs
run =
    List.map
        (\col ->
            ( "Run" ++ String.fromInt col
            , TextureRes "assets/img/Run1.png"
                (Just
                    { mag = Just MagNearest
                    , min = Nothing
                    , crop = Just ( ( 48 * col, 0 ), ( 48, 48 ) )
                    }
                )
            )
        )
    <|
        List.range 0 11


jump : ResourceDefs
jump =
    List.map
        (\col ->
            ( "Jump" ++ String.fromInt col
            , TextureRes "assets/img/Jump1.png"
                (Just
                    { mag = Just MagNearest
                    , min = Nothing
                    , crop = Just ( ( 48 * col, 0 ), ( 48, 48 ) )
                    }
                )
            )
        )
    <|
        List.range 0 7
