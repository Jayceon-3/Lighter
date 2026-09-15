module SceneProtos.Game.Components.Map.Model exposing (Data, component)

{-| Component model

@docs Data, component

-}

import Array exposing (Array)
import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget, initBaseData)
import SceneProtos.Game.Components.DW.VisualDW exposing (genRandomNum, refreshSurroundedTiles)
import SceneProtos.Game.Components.Map.CollisionLogic exposing (..)
import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..), tile)
import SceneProtos.Game.Components.Map.MapHelp exposing (CollisionType(..), collisionHelp, renderKey)
import SceneProtos.Game.Components.Map.SpecialBlock exposing (getBottomTile, listToArrayTiles, updateKeyBlock)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| The component model for the Map component, which handles the map tiles and their interactions.
`id`: Unique identifier for the component.
`ty`: Type of the component.
`tiles`: A 2D array representing the map tiles.
`tileWidth`: Width of each tile.
`tileHeight`: Height of each tile.

Example:

    { id = 9
    , ty = "Map"
    , tiles = sampleTileMapWithBlocks
    , tileWidth = 60
    , tileHeight = 60
    }

-}
type alias Data =
    { id : Int
    , ty : String
    , tiles : Array (Array Tile)
    , tileWidth : Int
    , tileHeight : Int
    }


sampleTileMap : Array (Array Tile)
sampleTileMap =
    let
        cols =
            48

        rows =
            27

        row : Int -> Array Tile
        row _ =
            Array.initialize cols (\_ -> tile Empty)
    in
    Array.initialize rows row


setTileAt : Int -> Int -> Tile -> Array (Array Tile) -> Array (Array Tile)
setTileAt x y newTile map =
    map
        |> Array.get y
        |> Maybe.map
            (\row ->
                let
                    updatedRow =
                        Array.set x newTile row
                in
                Array.set y updatedRow map
            )
        |> Maybe.withDefault map


sampleTileMapWithBlocks : Array (Array Tile)
sampleTileMapWithBlocks =
    sampleTileMap
        |> setTileAt 2 19 (tile SolidTop)
        |> setTileAt 10 10 (tile KeyBlock)


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        MapInitMsg data ->
            ( { id = data.id, ty = data.ty, tiles = data.tiles, tileHeight = data.tileHeight, tileWidth = data.tileWidth }, initBaseData )

        _ ->
            ( { id = 9, ty = "Map", tiles = sampleTileMapWithBlocks, tileHeight = 60, tileWidth = 60 }, initBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        Tick _ ->
            let
                mapinfo =
                    getmapinformation data.tiles
            in
            ( ( data, basedata ), [ Other ( "Bullet", MapInfo mapinfo ), Other ( "Enemy", MapInfo mapinfo ), Other ( "Player", MapInfo mapinfo ), Other ( "Weapon", MapInfo mapinfo ), Other ( "DW", MapInfo mapinfo ) ], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    --( ( data, basedata ), [], env )
    let
        currentTiles =
            getmapinformation data.tiles
    in
    case msg of
        CheckCollisionMsg { x, y, x1, y1, w, h } ->
            let
                playerMsg =
                    collisionHelp data Player ( x, y ) ( x1, y1 ) ( w, h )
            in
            ( ( data, basedata )
            , playerMsg
            , env
            )

        DWCheckCollisionMsg { x, y, x1, y1, w, h } ->
            let
                dwMsg =
                    collisionHelp data DW ( x, y ) ( x1, y1 ) ( w, h )
            in
            ( ( data, basedata )
            , dwMsg
            , env
            )

        FindKey pos ->
            let
                updatedTiles =
                    updateKeyBlock currentTiles pos

                ( ( r, c ), arrayTiles ) =
                    listToArrayTiles updatedTiles
            in
            ( ( { data | tiles = arrayTiles }, basedata ), [], env )

        PlayerStateMsg state ->
            let
                time =
                    floor env.globalData.currentTimeStamp

                newTiles =
                    refreshSurroundedTiles currentTiles state.position time

                ( ( a, b ), newBlocks ) =
                    listToArrayTiles newTiles
            in
            ( ( { data | tiles = newBlocks }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


renderTileWithColor : ( Float, Float ) -> ( Float, Float ) -> Color.Color -> List Renderable
renderTileWithColor pos ( tw, th ) middleColor =
    [ P.rectCentered pos ( tw, th ) 0 Color.black
    , P.rectCentered pos ( 55, 55 ) 0 middleColor
    , P.rectCentered pos ( 48, 48 ) 0 Color.black
    ]


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        tileWidth =
            toFloat data.tileWidth

        tileHeight =
            toFloat data.tileHeight

        drawTile : Int -> Int -> Tile -> List Renderable
        drawTile x y tileK =
            let
                pos =
                    ( tileWidth * toFloat x + 30
                    , tileHeight * toFloat y + 30
                    )
            in
            if env.globalData.userData.dw then
                case tileK.kind of
                    SolidTop ->
                        renderTileWithColor pos ( tileWidth, tileHeight ) Color.lightBlue

                    SolidMiddle ->
                        renderTileWithColor pos ( tileWidth, tileHeight ) Color.lightBlue

                    Frame ->
                        [ P.rectCentered pos ( tileWidth, tileHeight ) 0 Color.black ]

                    KeyBlock ->
                        if tileK.solid then
                            [ P.centeredTexture pos ( tileWidth, tileHeight ) 0 "key" ]
                                ++ renderKey env pos

                        else
                            [ P.empty ]

                    DamageBlock ->
                        renderTileWithColor pos ( tileWidth, tileHeight ) Color.darkRed

                    RecoverBlock ->
                        renderTileWithColor pos ( tileWidth, tileHeight ) Color.darkGreen

                    FakeBlock ->
                        [ P.empty ]

                    DWbrick ->
                        [ P.empty ]

                    Empty ->
                        [ P.empty ]

            else
                case tileK.kind of
                    SolidTop ->
                        [ P.centeredTexture pos ( tileWidth, tileHeight ) 0 "top" ]

                    SolidMiddle ->
                        [ P.centeredTexture pos ( tileWidth, tileHeight ) 0 "middle" ]

                    Frame ->
                        [ P.centeredTexture pos ( tileWidth, tileHeight ) 0 "frame" ]

                    KeyBlock ->
                        [ P.empty ]

                    DamageBlock ->
                        [ P.centeredTexture pos ( tileWidth, tileHeight ) 0 "top" ]

                    RecoverBlock ->
                        [ P.centeredTexture pos ( tileWidth, tileHeight ) 0 "top" ]

                    FakeBlock ->
                        [ P.centeredTexture pos ( tileWidth, tileHeight ) 0 "fake" ]

                    DWbrick ->
                        renderTileWithColor pos ( tileWidth, tileHeight ) Color.lightBlue

                    Empty ->
                        [ P.empty ]
    in
    ( group []
        (Array.toList data.tiles
            |> List.indexedMap
                (\y row ->
                    Array.toList row
                        |> List.indexedMap (\x tileK -> drawTile x y tileK)
                        |> List.concat
                )
            |> List.concat
        )
    , 1
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Map"


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
