module SceneProtos.Game.Components.Enemy.Enemyblood exposing (updateblood)

{-|


# Enemyblood

Handles enemy health updates when hit by player bullets.

@docs updateblood

-}

import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Bullet.Init exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Enemy.Init exposing (..)
import SceneProtos.Game.Components.Player.Init exposing (..)


{-| Update enemy health and bullet states after collisions

Processes all enemies and bullets to:

1.  Remove bullets that hit enemies
2.  Decrease health of enemies that were hit
3.  Return updated enemy and bullet lists

`enemys`: List of current enemies
`bullets`: List of current player bullets

Returns tuple containing:

1.  Updated enemies with decreased health
2.  Filtered bullets (hit bullets removed)

Example:
updateblood enemies bullets
-- Returns (updatedEnemies, remainingBullets)

-}
updateblood : List Enemy -> List SingleBullet -> ( List Enemy, List SingleBullet )
updateblood enemys bullets =
    let
        newbullet =
            List.filter
                (\b ->
                    not
                        (List.any
                            (\e ->
                                let
                                    ( x, y ) =
                                        b.position

                                    ( m, n ) =
                                        e.position
                                in
                                abs (x - m) <= 15 && abs (y - n) <= 30
                            )
                            enemys
                        )
                )
                bullets

        newenemy =
            List.map
                (\e ->
                    decreaseblood e bullets
                )
                enemys
    in
    ( newenemy, newbullet )



-- Internal helper function (not exposed, no docs needed)


decreaseblood : Enemy -> List SingleBullet -> Enemy
decreaseblood enemy bullets =
    let
        ( m, n ) =
            enemy.position

        valid =
            List.filter
                (\b ->
                    let
                        ( x, y ) =
                            b.position
                    in
                    abs (m - x) <= 15 && abs (n - y) <= 30
                )
                bullets

        damage =
            toFloat (List.length valid * 25) / 2
    in
    { enemy | hp = enemy.hp - damage }
