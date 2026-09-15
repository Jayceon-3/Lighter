module SceneProtos.Game.Components.Enemy.Enemytarget exposing (refreshtarget)

{-|


# Enemytarget

Handles enemy target refreshing logic.

@docs refreshtarget

-}

import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance)
import SceneProtos.Game.Components.Enemy.Init exposing (..)


{-| Refresh enemy targets based on new target position

Updates enemy targets if:

1.  The new target is within 500 units distance
2.  The new target is closer than current target
3.  The new target is in the same horizontal direction as current target

`enemy`: List of enemies to potentially update
`newtarget`: The new target position (x,y) to consider

Returns updated list of enemies with potentially changed targets

Example:
refreshtarget enemies (playerX, playerY)
-- Returns enemies with updated targets if conditions are met

-}
refreshtarget : List Enemy -> ( Float, Float ) -> List Enemy
refreshtarget enemy newtarget =
    List.map
        (\e ->
            if distance e.position newtarget > 500 then
                e

            else
                let
                    dis1 =
                        distance e.position newtarget

                    dis2 =
                        distance e.position e.target

                    ( x1, _ ) =
                        e.position

                    ( x2, _ ) =
                        newtarget

                    ( x3, _ ) =
                        e.target

                    dir =
                        (x2 - x1) * (x3 - x1)

                    newe =
                        if dis1 < dis2 && dir >= 0 then
                            { e | target = newtarget }

                        else
                            e
                in
                newe
        )
        enemy
