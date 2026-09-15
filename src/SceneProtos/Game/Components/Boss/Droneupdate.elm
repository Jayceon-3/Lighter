module SceneProtos.Game.Components.Boss.Droneupdate exposing (movedrones, otherlist, refreshdrones)

{-|


# Droneupdate

Logic of updating drones.

@docs movedrones, otherlist, refreshdrones

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Boss.Init exposing (..)
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance, move)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


{-| Refreshes the drone formation when drones are destroyed.

Maintains a minimum number of drones (at least 2) by recreating them in a circular formation
around the boss. Each new drone will have:

  - Starting position at boss's location
  - Target position in a 450px radius circle
  - 500 HP
  - Proper angular spacing

-}
refreshdrones : InitData -> InitData
refreshdrones data =
    if List.length data.drone > 1 then
        data

    else
        let
            newdronenumber =
                data.dronenumber + 1

            olddrone =
                Maybe.withDefault
                    { position = ( 600, 810 )
                    , target = ( 600, 810 )
                    , hp = 500
                    , direction = 0
                    , angle = pi / 2
                    , lasttime = 0
                    }
                    (List.head
                        data.drone
                    )

            radius =
                450

            tempdrones =
                List.map
                    (\i ->
                        let
                            newdirection =
                                2 * pi * toFloat i / toFloat data.dronenumber + olddrone.direction
                        in
                        { position = data.position
                        , target = move data.position ( radius * cos newdirection, radius * sin newdirection )
                        , hp = 500
                        , direction = newdirection
                        , angle = 0 -- the angle will be adjusted when the newdrone reaches the target point
                        , lasttime = 0
                        }
                    )
                    (List.range 1 (data.dronenumber - 1))

            newdrones =
                olddrone :: tempdrones
        in
        { data | drone = newdrones, dronenumber = newdronenumber }


{-| Updates drone positions based on their movement logic.

Drones will:

  - Move toward their target positions at 0.5 units per millisecond
  - Snap to target when within close range
  - Synchronize their angles and timers when reaching target

-}
movedrones : List Drone -> Float -> List Drone
movedrones drone dt =
    let
        temp =
            List.filter (\d -> d.lasttime >= -1) drone

        ( newangle, newlasttime ) =
            if List.isEmpty temp then
                ( 0, 0 )

            else
                let
                    example =
                        Maybe.withDefault
                            { position = ( 0, 0 )
                            , target = ( 0, 0 )
                            , hp = 500
                            , direction = 0
                            , angle = 0
                            , lasttime = 0
                            }
                            (List.head
                                temp
                            )
                in
                ( example.angle, example.lasttime )

        newdrone =
            List.map
                (\d ->
                    if d.position == d.target then
                        d

                    else if distance d.position d.target <= 0.5 * dt then
                        { d | position = d.target, angle = newangle, lasttime = newlasttime }

                    else
                        { d | position = move d.position ( 0.5 * cos d.direction * dt, 0.5 * sin d.direction * dt ) }
                )
                drone
    in
    newdrone


{-| Calculates visual effect parameters based on atom state progression.

Returns RGB color multipliers that change over the atom's lifetime,
creating a pulsing effect with four distinct phases.

-}
otherlist : Float -> Atom -> ( Float, Float, Float )
otherlist now atom =
    if now - atom.releasetime <= 0.25 * atom.targettime then
        ( 0.65, 0.4, 0.3 )

    else if now - atom.releasetime <= 0.5 * atom.targettime then
        ( 0.85, 0.6, 0.4 )

    else if now - atom.releasetime <= 0.75 * atom.targettime then
        ( 1.0, 0.6, 0.2 )

    else
        ( 1.0, 0.85, 0.5 )
