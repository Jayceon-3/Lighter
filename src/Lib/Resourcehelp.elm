module Lib.Resourcehelp exposing
    ( background1, background2, background3, background4
    , enemygun, ceosprite, ceoSize, button, tiles
    , enemyAction, enemyrun, enemystand, enemywalk, enemyknife
    , symbol, bullets
    )

{-|


# Resourcehelp

The resources that will be used in the game.

@docs background1, background2, background3, background4
@docs enemygun, ceosprite, ceoSize, button, tiles
@docs enemyAction, enemyrun, enemystand, enemywalk, enemyknife
@docs symbol, bullets

-}

import Messenger.Resources.Base exposing (ResourceDef(..), ResourceDefs)
import REGL exposing (..)


{-| resource definitions for the game images for background1.
-}
background1 : ResourceDefs
background1 =
    [ ( "bg1_1", TextureRes "assets/img/gameBG/bg1_1.png" Nothing )
    , ( "bg1_2", TextureRes "assets/img/gameBG/bg1_2.png" Nothing )
    , ( "bg1_3", TextureRes "assets/img/gameBG/bg1_3.png" Nothing )
    , ( "bg1_4", TextureRes "assets/img/gameBG/bg1_4.png" Nothing )
    , ( "bg1_5", TextureRes "assets/img/gameBG/bg1_5.png" Nothing )
    ]


{-| resource definitions for the game images for background2.
-}
background2 : ResourceDefs
background2 =
    [ ( "bg2_1", TextureRes "assets/img/gameBG/bg2_1.png" Nothing )
    , ( "bg2_2", TextureRes "assets/img/gameBG/bg2_2.png" Nothing )
    , ( "bg2_3", TextureRes "assets/img/gameBG/bg2_3.png" Nothing )
    , ( "bg2_4", TextureRes "assets/img/gameBG/bg2_4.png" Nothing )
    , ( "bg2_5", TextureRes "assets/img/gameBG/bg2_5.png" Nothing )
    ]


{-| resource definitions for the game images for background3.
-}
background3 : ResourceDefs
background3 =
    [ ( "bg3_1", TextureRes "assets/img/gameBG/bg3_1.png" Nothing )
    , ( "bg3_2", TextureRes "assets/img/gameBG/bg3_2.png" Nothing )
    , ( "bg3_3", TextureRes "assets/img/gameBG/bg3_3.png" Nothing )
    , ( "bg3_4", TextureRes "assets/img/gameBG/bg3_4.png" Nothing )
    , ( "bg3_5", TextureRes "assets/img/gameBG/bg3_5.png" Nothing )
    ]


{-| resource definitions for the game images for background4.
-}
background4 : ResourceDefs
background4 =
    [ ( "bg4_1", TextureRes "assets/img/gameBG/bg4_1.png" Nothing )
    , ( "bg4_2", TextureRes "assets/img/gameBG/bg4_2.png" Nothing )
    , ( "bg4_3", TextureRes "assets/img/gameBG/bg4_3.png" Nothing )
    , ( "bg4_4", TextureRes "assets/img/gameBG/bg4_4.png" Nothing )
    , ( "bg4_5", TextureRes "assets/img/gameBG/bg4_5.png" Nothing )
    ]


{-| resource definitions for the game images for enemy gun.
-}
enemygun : ResourceDefs
enemygun =
    [ ( "gunup1", TextureRes "assets/img/Enemy1/gunup1.png" Nothing )
    , ( "gundown1", TextureRes "assets/img/Enemy1/gundown1.png" Nothing )
    , ( "gunup2", TextureRes "assets/img/Enemy2/gunup2.png" Nothing )
    , ( "gundown2", TextureRes "assets/img/Enemy2/gundown2.png" Nothing )
    , ( "gunup3", TextureRes "assets/img/Enemy3/gunup3.png" Nothing )
    , ( "gundown3", TextureRes "assets/img/Enemy3/gundown3.png" Nothing )
    ]


{-| Definition for ceo's size.
-}
ceoSize : List Int
ceoSize =
    [ 4
    , 4
    , 4
    , 4
    , 4
    ]


{-| resource definitions for the game images for ceo sprite.
-}
ceosprite : ResourceDefs
ceosprite =
    List.concat <|
        List.indexedMap
            (\row colsize ->
                List.map
                    (\col ->
                        ( "ceo" ++ String.fromInt row ++ String.fromInt col
                        , TextureRes "assets/img/Ceo/ceo.png"
                            (Just
                                { mag = Just MagNearest
                                , min = Nothing
                                , crop = Just ( ( 420 * col, 420 * row ), ( 420, 420 ) )
                                }
                            )
                        )
                    )
                <|
                    List.range 0 colsize
            )
            ceoSize


{-| resource definitions for the game images for button.
-}
button : ResourceDefs
button =
    [ ( "level1", TextureRes "assets/img/button/1.png" Nothing )
    , ( "level2", TextureRes "assets/img/button/2.png" Nothing )
    , ( "level3", TextureRes "assets/img/button/3.png" Nothing )
    , ( "level4", TextureRes "assets/img/button/4.png" Nothing )
    ]


{-| resource definitions for the game images for tiles.
-}
tiles : ResourceDefs
tiles =
    [ ( "top", TextureRes "assets/img/tiles3/top.png" Nothing )
    , ( "fake", TextureRes "assets/img/tiles3/fake.png" Nothing )
    , ( "middle", TextureRes "assets/img/tiles3/middle.png" Nothing )
    , ( "key", TextureRes "assets/img/key.jpg" Nothing )
    , ( "frame", TextureRes "assets/img/tiles3/frame.png" Nothing )
    ]



-- these are for the resource


{-| resource definitions for the game images for enemy actions.
-}
enemyAction :
    { prefix : String
    , folder : String
    , action : String
    , frameCount : Int
    }
    -> Int
    -> ResourceDefs
enemyAction { prefix, folder, action, frameCount } index =
    List.map
        (\col ->
            ( prefix ++ String.fromInt index ++ String.fromInt col
            , TextureRes
                ("assets/img/Enemy" ++ String.fromInt index ++ "/" ++ action ++ String.fromInt index ++ ".png")
                (Just
                    { mag = Just MagNearest
                    , min = Nothing
                    , crop = Just ( ( 48 * col, 0 ), ( 48, 48 ) )
                    }
                )
            )
        )
        (List.range 0 (frameCount - 1))


{-| resource definitions for the game images for enemy run.
-}
enemyrun : Int -> ResourceDefs
enemyrun =
    enemyAction
        { prefix = "enemyrun"
        , folder = "Enemy"
        , action = "run"
        , frameCount = 6 -- range 0~5
        }


{-| resource definitions for the game images for enemy stand.
-}
enemystand : Int -> ResourceDefs
enemystand =
    enemyAction
        { prefix = "enemystand"
        , folder = "Enemy"
        , action = "stand"
        , frameCount = 4 -- range 0~3
        }


{-| resource definitions for the game images for enemy walk.
-}
enemywalk : Int -> ResourceDefs
enemywalk =
    enemyAction
        { prefix = "enemywalk"
        , folder = "Enemy"
        , action = "walk"
        , frameCount = 6 -- range 0~5
        }


{-| resource definitions for the game images for enemy knife.
-}
enemyknife : Int -> ResourceDefs
enemyknife =
    enemyAction
        { prefix = "knife"
        , folder = "Enemy"
        , action = "knife"
        , frameCount = 6 -- range 0~5
        }


{-| resource definitions for the game images for symbols.
-}
symbol : ResourceDefs
symbol =
    [ ( "lmb", TextureRes "assets/img/symbol/lmb.png" Nothing )
    , ( "rmb", TextureRes "assets/img/symbol/rmb.png" Nothing )
    , ( "dw", TextureRes "assets/img/symbol/dw.png" Nothing )
    , ( "sd", TextureRes "assets/img/symbol/sd.png" Nothing )
    ]


{-| resource definitions for the game images for bullets.
-}
bullets : ResourceDefs
bullets =
    [ ( "bullet1", TextureRes "assets/img/Enemy1/bullet1.png" Nothing )
    , ( "bullet2", TextureRes "assets/img/Enemy2/bullet2.png" Nothing )
    , ( "bullet3", TextureRes "assets/img/Enemy3/bullet3.png" Nothing )
    ]
