module SceneProtos.Game.Components.Map.MapHelp exposing (CollisionType(..), collisionHelp, renderKey)

{-|


# MapHelp

Functions to help with map-related operations, such as collision detection.

@docs CollisionType, collisionHelp, renderKey

-}

import Array exposing (Array)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable)
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Map.CollisionLogic exposing (detectCollisionDirection)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection(..), Tile)
import SceneProtos.Game.Components.Map.SpecialBlock exposing (getBottomTile)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The data structure for map component. Copied from model to avoid import loop.
-}
type alias Data =
    { id : Int
    , ty : String
    , tiles : Array (Array Tile)
    , tileWidth : Int
    , tileHeight : Int
    }


{-| The type of collision that occurred.
`Player`: collision with the player.
`DW`: collision with player in dw.
-}
type CollisionType
    = Player
    | DW


{-| Helper function to handle collision results based on the collision type.
-}
collisionHelp : Data -> CollisionType -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata))
collisionHelp data collisionType ( x, y ) ( x1, y1 ) ( w, h ) =
    let
        dir =
            detectCollisionDirection x y x1 y1 w h data

        tile =
            getBottomTile x y w h data
    in
    if collisionType == Player then
        [ Other ( "Player", CollisionResultDirMsg dir )
        , Other ( "Player", CollisionResultMsg tile )
        ]

    else
        [ Other ( "DW", CollisionResultMsg tile )
        , Other ( "DW", CollisionResultDirMsg dir )
        ]


verticalMove : ( Float, Float ) -> Float -> ( Float, Float )
verticalMove pos time =
    let
        ( x, y ) =
            pos

        floatAmplitude =
            5

        floatSpeed =
            3

        verticalOffset =
            floatAmplitude * sin (time * floatSpeed)

        floatPos =
            ( x, y + verticalOffset )
    in
    floatPos


sizeChange : Float -> ( Float, Float )
sizeChange time =
    let
        pulseAmplitude =
            2

        pulseSpeed =
            4

        sizeModifier =
            1 + (pulseAmplitude * 0.01 * cos (time * pulseSpeed))

        baseSize =
            60

        keySize =
            ( baseSize * sizeModifier, baseSize * sizeModifier )
    in
    keySize


decideAlpha : Float -> Float
decideAlpha time =
    let
        blinkSpeed =
            2

        blinkMinAlpha =
            0.6

        blinkMaxAlpha =
            1.0

        -- Maximum transparency
        blinkAlpha =
            blinkMinAlpha
                + (blinkMaxAlpha - blinkMinAlpha)
                * (0.5 + 0.5 * sin (time * blinkSpeed * pi))
    in
    blinkAlpha


{-| Function to render keys.
-}
renderKey : Env SceneCommonData UserData -> ( Float, Float ) -> List Renderable
renderKey env pos =
    let
        ( x, y ) =
            pos

        keyPos =
            ( x, y - 60 )

        alpha =
            1

        time =
            env.globalData.sceneStartTime / 300

        floatKeyPos =
            verticalMove keyPos time

        rawCurrentAct =
            modBy 8 (floor time)

        ( w, h ) =
            sizeChange time

        keySize =
            if rawCurrentAct >= 4 then
                ( -w, h )

            else
                ( w, h )

        currentActNum =
            if rawCurrentAct >= 4 then
                rawCurrentAct - 4

            else
                rawCurrentAct

        currentAct =
            String.fromInt currentActNum

        keyAlpha =
            decideAlpha time
    in
    [ P.centeredTextureWithAlpha
        floatKeyPos
        keySize
        0
        keyAlpha
        ("Key" ++ currentAct)
    ]
