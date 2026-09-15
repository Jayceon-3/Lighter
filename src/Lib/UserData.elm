module Lib.UserData exposing (UserData, decodeUserData, encodeUserData)

{-|


# User data

@docs UserData, decodeUserData, encodeUserData

-}

import Json.Decode as Decode exposing (at, decodeString)
import Json.Encode as Encode


{-| User defined data
-}
type alias UserData =
    { canvas_mouse_pos : ( Float, Float )
    , dw : Bool
    , currentlevel : Int
    , displayLogo : Bool
    }


{-| Encoder for the UserData.
-}
encodeUserData : UserData -> String
encodeUserData storage =
    Encode.encode 0
        (Encode.object
            [ --Aadd your data here
              -- Example:
              -- ( "volume", Encode.float storage.volume )
              ( "canvas_mouse_pos"
              , Encode.list
                    Encode.float
                    [ Tuple.first storage.canvas_mouse_pos
                    , Tuple.second storage.canvas_mouse_pos
                    ]
              )
            , ( "dw", Encode.bool storage.dw )
            , ( "currentlevel", Encode.int storage.currentlevel )
            ]
        )


{-| Decoder for the UserData.
-}
decodeUserData : String -> UserData
decodeUserData ls =
    -- Example:
    -- let
    --     vol =
    --         Result.withDefault 0.5 (decodeString (at [ "volume" ] Decode.float) ls)
    -- in
    -- UserData
    let
        canvas_mouse_pos =
            Result.withDefault ( 0, 0 )
                (decodeString
                    (at [ "canvas_mouse_pos" ]
                        (Decode.list Decode.float
                            |> Decode.andThen
                                (\lst ->
                                    case lst of
                                        [ x, y ] ->
                                            Decode.succeed ( x, y )

                                        _ ->
                                            Decode.fail "Expected a list with exactly two floats"
                                )
                        )
                    )
                    ls
                )

        dw =
            Result.withDefault False (decodeString (at [ "dw" ] Decode.bool) ls)

        current =
            Result.withDefault 1 (decodeString (at [ "currentlevel" ] Decode.int) ls)
    in
    { canvas_mouse_pos =
        ( Tuple.first canvas_mouse_pos
        , Tuple.second canvas_mouse_pos
        )
    , dw = dw
    , currentlevel = current
    , displayLogo = False
    }
