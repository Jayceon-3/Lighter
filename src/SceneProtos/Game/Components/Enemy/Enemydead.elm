module SceneProtos.Game.Components.Enemy.Enemydead exposing (msg_list)

{-|


# Enemydead

Handles logic for dead enemies and their death effects.

@docs msg_list

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (..)
import Messenger.Scene.Scene exposing (..)
import Random
import SceneProtos.Game.Components.ComponentBase exposing (..)
import SceneProtos.Game.Components.Drop.Init exposing (Droptype(..), Singledrop)
import SceneProtos.Game.Components.Enemy.Enemybulletlogic exposing (..)
import SceneProtos.Game.Components.Enemy.Init exposing (..)
import SceneProtos.Game.Components.Map.Init exposing (Tile)
import SceneProtos.Game.Components.Weapon.Init exposing (ShieldState(..))
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Generate messages for dead enemies and update their state

Processes all dead enemies to:

1.  Generate drop messages for enemies that haven't dropped items yet
2.  Mark enemies as having dropped items
3.  Return updated enemy list with processed dead enemies

`data`: Current component data containing enemy list

Returns tuple containing:

1.  List of messages to spawn drops
2.  Updated component data with processed enemies

Example:
msg\_list gameData
-- Returns (dropMessages, updatedGameData)

-}
msg_list : Data -> ( List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), Data )
msg_list data =
    let
        alive_enemies =
            get_alive_enemy data

        dead_enemies =
            get_dead_enemy data

        ( msgs, new_dead_enemies ) =
            List.map dead_msg dead_enemies
                |> List.unzip

        new_data =
            { data | enemy = new_dead_enemies ++ alive_enemies }
    in
    ( List.concat msgs, new_data )



-- Internal helper functions (not exposed, no docs needed)


type alias Data =
    { id : Int
    , ty : String
    , enemy : List Enemy
    , enemybullet : List EnemyBullet
    , dt : Float
    , real : ( Float, Float )
    }


get_dead_enemy : Data -> List Enemy
get_dead_enemy data =
    List.filter (\e -> e.enemytype == Dead) data.enemy


get_alive_enemy : Data -> List Enemy
get_alive_enemy data =
    List.filter (\e -> e.enemytype /= Dead) data.enemy


get_dead_position : Data -> List ( Float, Float )
get_dead_position data =
    List.map (\e -> e.position) (get_dead_enemy data)


dead_msg : Enemy -> ( List (Msg String ComponentMsg (SceneOutputMsg scenemsg userdata)), Enemy )
dead_msg enemy =
    if enemy.have_droped_or_not then
        ( [], enemy )

    else
        ( [ Other ( "Drop", EnemyDieMsg enemy.position ) ], { enemy | have_droped_or_not = True } )
