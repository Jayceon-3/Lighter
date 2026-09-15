module SceneProtos.Game.Components.Map.CollisionLogic exposing (isSolidAt, detectCollisionDirection, bulletCollisionJudge, getmapinformation)

{-|


# CollisionLogic

Functions for collision detection in a tile-based map.

@docs isSolidAt, detectCollisionDirection, bulletCollisionJudge, getmapinformation

-}

import Array exposing (Array)
import Messenger.GeneralModel exposing (Msg(..))
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Map.Collisionhelp exposing (Context, Data, DirectionSpec)
import SceneProtos.Game.Components.Map.Init exposing (CollisionDirection(..), Tile, TileKind(..))


{-| Judge whether the block at the position is solid.
-}
isSolidAt : Float -> Float -> Data -> Bool
isSolidAt x y mapData =
    let
        tileX =
            floor (x / toFloat mapData.tileWidth)

        tileY =
            floor (y / toFloat mapData.tileHeight)
    in
    case Array.get tileY mapData.tiles of
        Just row ->
            case Array.get tileX row of
                Just tile ->
                    tile.solid

                Nothing ->
                    False

        Nothing ->
            False


sampleCollisionCheck : Float -> Float -> Float -> (Float -> ( Float, Float )) -> Int -> Data -> Bool
sampleCollisionCheck startX startY span ckPoint sampleCount mapData =
    let
        step =
            span / toFloat (sampleCount - 1)

        indices =
            List.range 0 (sampleCount - 1)

        checkPoints =
            List.map (\i -> ckPoint (step * toFloat i)) indices
    in
    List.any (\( xx, yy ) -> isSolidAt xx yy mapData) checkPoints


directionSpecs : List DirectionSpec
directionSpecs =
    [ -- Bottom
      { dir = Bottom
      , tileIndex = \ctx -> floor ((ctx.y1 + ctx.h / 2) / ctx.tileHf)
      , boundary = \ctx i -> toFloat i * ctx.tileHf
      , cross = \ctx b -> (ctx.y1 + ctx.h / 2) >= b && (ctx.y + ctx.h / 2) <= b
      , sampleStart = \ctx -> ( ctx.x1 - ctx.w / 2, 0 )
      , sampleSpan = \ctx -> ctx.w
      , samplePoint = \ctx dx -> ( ctx.x1 - ctx.w / 2 + dx, ctx.y1 + ctx.h / 2 + 1 )
      }
    , -- Top
      { dir = Top
      , tileIndex = \ctx -> floor ((ctx.y1 - ctx.h / 2) / ctx.tileHf)
      , boundary = \ctx i -> toFloat (i + 1) * ctx.tileHf
      , cross = \ctx b -> (ctx.y1 - ctx.h / 2) <= b && (ctx.y - ctx.h / 2) >= b
      , sampleStart = \ctx -> ( ctx.x1 - ctx.w / 2, 0 )
      , sampleSpan = \ctx -> ctx.w
      , samplePoint = \ctx dx -> ( ctx.x1 - ctx.w / 2 + dx, ctx.y1 - ctx.h / 2 - 1 )
      }
    , -- Left
      { dir = Left
      , tileIndex = \ctx -> floor ((ctx.x1 - ctx.w / 2) / ctx.tileWf)
      , boundary = \ctx i -> toFloat (i + 1) * ctx.tileWf
      , cross = \ctx b -> (ctx.x1 - ctx.w / 2) <= b && (ctx.x - ctx.w / 2) >= b
      , sampleStart =
            \ctx ->
                let
                    middleH =
                        ctx.h * 0.98
                in
                ( ctx.y1 - middleH / 2, 0 )
      , sampleSpan = \ctx -> ctx.h * 0.98
      , samplePoint =
            \ctx dy ->
                let
                    middleH =
                        ctx.h * 0.98

                    middleY =
                        ctx.y1 - middleH / 2
                in
                ( ctx.x1 - ctx.w / 2 - 1, middleY + dy )
      }
    , -- Right
      { dir = Right
      , tileIndex = \ctx -> floor ((ctx.x1 + ctx.w / 2) / ctx.tileWf)
      , boundary = \ctx i -> toFloat i * ctx.tileWf
      , cross = \ctx b -> (ctx.x1 + ctx.w / 2) >= b && (ctx.x + ctx.w / 2) <= b
      , sampleStart =
            \ctx ->
                let
                    middleH =
                        ctx.h * 0.98
                in
                ( ctx.y1 - middleH / 2, 0 )
      , sampleSpan = \ctx -> ctx.h * 0.98
      , samplePoint =
            \ctx dy ->
                let
                    middleH =
                        ctx.h * 0.98

                    middleY =
                        ctx.y1 - middleH / 2
                in
                ( ctx.x1 + ctx.w / 2 + 1, middleY + dy )
      }
    ]


detectOne : DirectionSpec -> Context -> Maybe CollisionDirection
detectOne spec ctx =
    let
        idx =
            spec.tileIndex ctx

        bnd =
            spec.boundary ctx idx

        ( startX, _ ) =
            spec.sampleStart ctx

        ( _, startY ) =
            spec.sampleStart ctx
    in
    if spec.cross ctx bnd then
        if
            sampleCollisionCheck
                startX
                startY
                (spec.sampleSpan ctx)
                (\delta -> spec.samplePoint ctx delta)
                ctx.sampleCount
                ctx.mapData
        then
            Just spec.dir

        else
            Nothing

    else
        Nothing


{-| Return collision direction based on player's old position and possible new position.
-}
detectCollisionDirection : Float -> Float -> Float -> Float -> Float -> Float -> Data -> List CollisionDirection
detectCollisionDirection x y x1 y1 w h mapData =
    let
        ctx =
            { x = x
            , y = y
            , x1 = x1
            , y1 = y1
            , w = w
            , h = h
            , tileHf = toFloat mapData.tileHeight
            , tileWf = toFloat mapData.tileWidth
            , sampleCount = 10
            , mapData = mapData
            }
    in
    directionSpecs
        |> List.filterMap (\spec -> detectOne spec ctx)


getSolidPos : ( Float, Float ) -> ( Int, Int ) -> Tile -> Maybe ( Float, Float )
getSolidPos ( w, h ) ( x, y ) tile =
    let
        isEmpty t =
            t.kind == Empty
    in
    if isEmpty tile then
        Nothing

    else
        Just
            ( w * toFloat x + w / 2
            , h * toFloat y + h / 2
            )


{-| Check if the bullet position collides with any solid tile in the map.
-}
bulletCollisionJudge : ( Float, Float ) -> Data -> ( ( Float, Float ), Bool )
bulletCollisionJudge ( x, y ) data =
    let
        tileWidth =
            toFloat data.tileWidth

        tileHeight =
            toFloat data.tileHeight

        posList =
            Array.toList data.tiles
                |> List.indexedMap
                    (\y1 row ->
                        Array.toList row
                            |> List.indexedMap (\x1 tileK -> getSolidPos ( tileWidth, tileHeight ) ( x1, y1 ) tileK)
                            |> List.filterMap identity
                    )
                |> List.concat

        judgeOne ( x1, y1 ) ( x2, y2 ) =
            (abs (x1 - x2) <= tileWidth) && (abs (y1 - y2) <= tileHeight)

        judge =
            ( ( x, y ), List.any (\( x1, y1 ) -> judgeOne ( x1, y1 ) ( x, y )) posList )
    in
    judge


mapinformation : Array (Array Tile) -> Array (Array ( Int, Int, Tile ))
mapinformation tiles =
    Array.indexedMap
        (\row rowarray ->
            Array.indexedMap
                (\col tile ->
                    ( col * 60 + 30, row * 60 + 30, tile )
                )
                rowarray
        )
        tiles



-- column first, then row


getmaplist : Array (Array ( Int, Int, Tile )) -> List ( Int, Int, Tile )
getmaplist tiles =
    List.concatMap Array.toList (Array.toList tiles)


{-| Get the map information in a list format.
-}
getmapinformation : Array (Array Tile) -> List ( Int, Int, Tile )
getmapinformation tiles =
    let
        temptiles =
            getmaplist (mapinformation tiles)

        finaltiles =
            List.filter
                (\t ->
                    let
                        ( _, _, tile ) =
                            t

                        judge =
                            1 > 0
                    in
                    judge
                )
                temptiles
    in
    finaltiles
