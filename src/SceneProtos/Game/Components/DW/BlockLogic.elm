module SceneProtos.Game.Components.DW.BlockLogic exposing (UpdateKind(..), specialBlockEffect)

{-|


# BlockLogic

Functions for special blocks in digital world.

@docs UpdateKind, specialBlockEffect

-}

import SceneProtos.Game.Components.Map.Init exposing (Tile, TileKind(..))


{-| The kind of update effect.

`HP` means hp of player will change because of special blocks

`Key` means the key number will change.

`None` means no update.

-}
type UpdateKind
    = HP
    | Key
    | None


{-| The function to implement the update logic.
-}
specialBlockEffect : Maybe Tile -> Float -> Float -> ( Float, UpdateKind )
specialBlockEffect maybeTile keyNum hp =
    case maybeTile of
        Nothing ->
            ( 0, None )

        Just tile ->
            case tile.kind of
                DamageBlock ->
                    updateHP (Just DamageBlock) hp

                RecoverBlock ->
                    updateHP (Just RecoverBlock) hp

                KeyBlock ->
                    updateKey (Just tile) keyNum

                _ ->
                    ( 0, None )



-- let
--     { kind, isSolid } =
--         tile
--     updateKind =
--         case kind of
--             Just k ->
--                 case k of
--                     DamageBlock ->
--                         HP
--                     RecoverBlock ->
--                         HP
--                     KeyBlock ->
--                         Key
--                     _ ->
--                         None
--             Nothing ->
--                 None
-- in
-- if updateKind == HP then
--     updateHP kind hp
-- else if updateKind == Key then
--     updateKey tile keyNum
-- else
--     ( 0, None )


updateHP : Maybe TileKind -> Float -> ( Float, UpdateKind )
updateHP kind hp =
    let
        ( newHp, judge ) =
            case kind of
                Just k ->
                    case k of
                        DamageBlock ->
                            let
                                newhp =
                                    max (hp - 0.1) 0
                            in
                            ( newhp, HP )

                        RecoverBlock ->
                            let
                                newhp =
                                    min (hp + 0.05) 100
                            in
                            ( newhp, HP )

                        _ ->
                            ( hp, None )

                Nothing ->
                    ( hp, None )
    in
    ( newHp, judge )


updateKey : Maybe Tile -> Float -> ( Float, UpdateKind )
updateKey tile keyNum =
    case tile of
        Nothing ->
            ( 0, None )

        Just t ->
            if t.solid then
                case t.kind of
                    KeyBlock ->
                        let
                            newNum =
                                min (keyNum + 1) 3
                        in
                        ( newNum, Key )

                    _ ->
                        ( 0, None )

            else
                ( 0, None )
