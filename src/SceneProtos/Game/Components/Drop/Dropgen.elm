module SceneProtos.Game.Components.Drop.Dropgen exposing (add_drops, deleted_drops, addallcount, remained_drops, move_drops)

{-|


# Dropgen

Functions for generating and managing drops in the game.

@docs add_drops, deleted_drops, addallcount, remained_drops, move_drops

-}

import Messenger.Base exposing (..)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import Random
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..), Singledrop)


{-| The drop component data structure.
`drops`: List of drops in the game.
`playerpos`: Position of the player.
`lifedrop`: Count of life drops.
`energydrop`: Count of energy drops.
`scatterdrop`: Count of scatter bullet drops.

Example:

    { drops = []
    , playerpos = ( 0, 0 )
    , lifedrop = 0
    , energydrop = 0
    , scatterdrop = 0
    }

-}
type alias Data =
    { drops : List Singledrop
    , playerpos : ( Float, Float )
    , lifedrop : Int
    , energydrop : Int
    , scatterdrop : Int
    }


{-| Calculates the distance between a drop and a position.
-}
distance : Singledrop -> ( Float, Float ) -> Float
distance drop ( x, y ) =
    let
        ( dropX, dropY ) =
            drop.position
    in
    sqrt ((dropX - x) ^ 2 + (dropY - y) ^ 2)


{-| The size of the drops.
-}
dropsize : Float
dropsize =
    25


{-| Generates a random integer between 1 and 4.
-}
randomGenerator : Random.Generator Int
randomGenerator =
    Random.int 1 4


{-| Generates a random drop type based on the random integer.
-}
droptypeGenerator : Random.Generator Droptype
droptypeGenerator =
    Random.map
        (\n ->
            if n == 1 then
                Life

            else if n == 2 then
                Energy

            else
                Scatterbullet
        )
        randomGenerator


{-| Generates a random drop with a position and size.
-}
dropGenerator : ( Float, Float ) -> Random.Generator Singledrop
dropGenerator ( x, y ) =
    Random.map
        (\droptype ->
            { position = ( x, y )
            , size = dropsize
            , droptype = droptype
            , dir = 1
            , viewpos = ( x, y )
            , v = 10
            }
        )
        droptypeGenerator


{-| Generates a drop based on the current time and position.
-}
gendrop : Float -> ( Float, Float ) -> Singledrop
gendrop time pos =
    let
        randomSeed =
            Random.initialSeed (floor time * 99)

        ( drop, _ ) =
            Random.step (dropGenerator pos) randomSeed
    in
    drop


{-| Adds a new drop to the list of drops at the specified position and time.
-}
add_drops : Float -> ( Float, Float ) -> List Singledrop -> List Singledrop
add_drops time pos drops =
    let
        newDrop =
            gendrop time pos
    in
    newDrop :: drops


{-| Checks if a drop is within the specified position.
-}
if_get_drop : Singledrop -> ( Float, Float ) -> Bool
if_get_drop drop pos =
    distance drop pos <= drop.size


{-| Filters out drops that are within the specified position.
-}
deleted_drops : ( Float, Float ) -> List Singledrop -> List Singledrop
deleted_drops pos drops =
    List.filter
        (\drop -> if_get_drop drop pos)
        drops


{-| Increases the count of a specific drop type in the data structure.
-}
addcount : Singledrop -> Data -> Data
addcount drop data =
    let
        life =
            data.lifedrop

        energy =
            data.energydrop

        scatter =
            data.scatterdrop
    in
    case drop.droptype of
        Life ->
            { data | lifedrop = life + 1 }

        Energy ->
            { data | energydrop = energy + 1 }

        Scatterbullet ->
            { data | scatterdrop = scatter + 1 }


{-| Adds all drops to the data structure, increasing the respective counts.
-}
addallcount : List Singledrop -> Data -> Data
addallcount drops data =
    List.foldl
        addcount
        data
        drops


{-| Filters out drops that are not within the specified position.
-}
remained_drops : ( Float, Float ) -> List Singledrop -> List Singledrop
remained_drops pos drops =
    List.filter
        (\drop -> if_get_drop drop pos |> not)
        drops


{-| Generates a message for a specific drop based on its type.
-}
drop_msg : Singledrop -> Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)
drop_msg drop =
    case drop.droptype of
        Life ->
            Other ( "Player", DropMsg Life )

        Energy ->
            Other ( "Weapon", DropMsg Energy )

        Scatterbullet ->
            Other ( "Weapon", DropMsg Scatterbullet )


{-| Generates a list of messages for a list of drops.
-}
msglist : List Singledrop -> List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata))
msglist drops =
    List.map drop_msg drops


{-| The range within which the drop can change direction.
-}
float_range : Float
float_range =
    5


{-| Changes the direction of a drop based on its position and view position.
-}
change_dir : Singledrop -> Singledrop
change_dir drop =
    let
        ( _, y1 ) =
            drop.position

        ( _, y2 ) =
            drop.viewpos

        newDir =
            if y2 >= y1 + float_range && drop.dir == 1 then
                -1

            else if y2 <= y1 - float_range && drop.dir == -1 then
                1

            else
                drop.dir
    in
    { drop | dir = newDir }


{-| Moves a drop based on the time delta and its current position.
-}
move_drop : Float -> Singledrop -> Singledrop
move_drop dt drop =
    let
        ( x, y ) =
            drop.viewpos

        v =
            drop.v

        dir =
            change_dir drop
                |> .dir

        newY =
            y + dt / 1000 * v * dir
    in
    { drop | viewpos = ( x, newY ), dir = dir }


{-| Moves all drops based on the time delta.
-}
move_drops : Float -> List Singledrop -> List Singledrop
move_drops dt drops =
    List.map
        (move_drop dt)
        drops
