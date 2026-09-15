module SceneProtos.Game.Components.Survcamera.Scamattack exposing (boundpoint, getangle, getonebound, playerbounds)

{-|


# Scamattack

Functions for arranging survcamera attacks

@docs boundpoint, getangle, getonebound, playerbounds

-}

import SceneProtos.Game.Components.Enemy.Enemylogic exposing (move)
import SceneProtos.Game.Components.Map.Init exposing (Tile)
import SceneProtos.Game.Components.Player.Init exposing (State)
import SceneProtos.Game.Components.Survcamera.Init exposing (..)


{-| get the angle of a line from x+ axis
-}
getangle : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> Float
getangle ( x1, y1 ) ( x2, y2 ) ( x3, y3 ) =
    let
        ux =
            x2 - x1

        uy =
            y2 - y1

        vx =
            x3 - x1

        vy =
            y3 - y1

        dotprod =
            ux * vx + uy * vy

        du =
            sqrt (ux * ux + uy * uy)

        dv =
            sqrt (vx * vx + vy * vy)

        lengthprod =
            if du == 0 || dv == 0 then
                1

            else
                du * dv

        cosTheta =
            dotprod
                / lengthprod
                |> clamp -1 1
    in
    acos cosTheta


rotateline : ( Float, Float ) -> ( Float, Float ) -> Float -> ( Float, Float )
rotateline p1 p2 angle =
    let
        ( x1, y1 ) =
            p1

        ( x2, y2 ) =
            p2

        dx =
            x2 - x1

        dy =
            y2 - y1

        cosA =
            cos angle

        sinA =
            sin angle

        newdx =
            dx * cosA - dy * sinA

        newdy =
            dx * sinA + dy * cosA

        newx =
            x1 + newdx

        newy =
            y1 + newdy
    in
    ( newx, newy )


getsolidmap : List ( Int, Int, Tile ) -> List ( Int, Int, Tile )
getsolidmap tiles =
    List.filter
        (\t ->
            let
                ( _, _, tile ) =
                    t
            in
            tile.solid
        )
        tiles


normalize : ( Float, Float ) -> ( Float, Float )
normalize ( dx, dy ) =
    let
        dis =
            sqrt (dx * dx + dy * dy)
    in
    if dis == 0 then
        ( 0, 0 )

    else
        ( dx / dis, dy / dis )


lineonetile : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float ) -> Maybe Float
lineonetile ( ox, oy ) ( dx, dy ) ( cx, cy ) =
    let
        halfSize =
            30

        minX =
            cx - halfSize

        maxX =
            cx + halfSize

        minY =
            cy - halfSize

        maxY =
            cy + halfSize

        slab origin dir minB maxB =
            if dir == 0 then
                if origin >= minB && origin <= maxB then
                    Just ( -10000, 10000 )

                else
                    Nothing

            else
                let
                    t1 =
                        (minB - origin) / dir

                    t2 =
                        (maxB - origin) / dir
                in
                Just ( min t1 t2, max t1 t2 )
    in
    case ( slab ox dx minX maxX, slab oy dy minY maxY ) of
        ( Just ( tMinX, tMaxX ), Just ( tMinY, tMaxY ) ) ->
            let
                tMin =
                    max tMinX tMinY

                tMax =
                    min tMaxX tMaxY
            in
            if tMax >= tMin && tMax > 0 then
                if tMin > 0 then
                    Just tMin

                else
                    Nothing

            else
                Nothing

        _ ->
            Nothing


{-| get the bound point of a ray
-}
boundpoint : ( Float, Float ) -> ( Float, Float ) -> List ( Int, Int, Tile ) -> ( Float, Float )
boundpoint p1 p2 temptile =
    let
        ( x1, y1 ) =
            p1

        tiles =
            getsolidmap temptile

        dir =
            normalize
                (move ( -x1, -y1 ) p2)

        ( dx, dy ) =
            dir

        ts =
            tiles
                |> List.filterMap
                    (\( ix, iy, _ ) ->
                        lineonetile
                            p1
                            dir
                            ( toFloat ix, toFloat iy )
                    )

        tMin =
            Maybe.withDefault 10000 (List.minimum ts)
    in
    ( x1 + dx * tMin
    , y1 + dy * tMin
    )


{-| get the left bound point according to the right
-}
getonebound : ( Float, Float ) -> ( Float, Float ) -> Float -> List ( Int, Int, Tile ) -> ( Float, Float )
getonebound pt pbmid angle tiles =
    let
        ptemp =
            rotateline pt pbmid angle

        newpb =
            boundpoint pt ptemp tiles
    in
    newpb


{-| get two bounds under attack mode
-}
playerbounds : ( Float, Float ) -> ( ( Float, Float ), ( Float, Float ) ) -> ( Float, Float ) -> State -> List ( Int, Int, Tile ) -> ( Float, Float, ( ( Float, Float ), ( Float, Float ) ) )
playerbounds tp ( pl, pr ) defaultpoint player tiles =
    let
        ( x1, y1 ) =
            pr

        ( x2, y2 ) =
            pl

        ( x, y ) =
            tp

        ( xp, yp ) =
            player.position

        stan =
            move tp ( 1, 0 )

        angle =
            (getangle tp stan pl + getangle tp stan pr) / 2

        targetangle =
            getangle tp stan player.position

        ( rotateangle, newdirection ) =
            if angle >= targetangle then
                ( max -(pi / 36) (targetangle - angle) + angle, 1 )

            else
                ( min (pi / 36) (targetangle - angle) + angle, -1 )

        ( lx, ly ) =
            getonebound tp stan (rotateangle + pi / 6) tiles

        ( rx, ry ) =
            getonebound tp stan (rotateangle - pi / 6) tiles

        ( newpl, newpr ) =
            if lx < x - 180 then
                let
                    left =
                        move defaultpoint ( -180, 0 )

                    right =
                        getonebound tp left (-pi / 3) tiles
                in
                ( left, right )

            else if rx > x + 180 then
                let
                    right =
                        move defaultpoint ( 180, 0 )

                    left =
                        getonebound tp right (pi / 3) tiles
                in
                ( left, right )

            else
                ( ( lx, ly ), ( rx, ry ) )

        newangle =
            (getangle tp stan newpl + getangle tp stan newpr) / 2
    in
    ( newdirection, newangle, ( newpl, newpr ) )
