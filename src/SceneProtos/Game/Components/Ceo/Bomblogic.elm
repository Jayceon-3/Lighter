module SceneProtos.Game.Components.Ceo.Bomblogic exposing (refreshbombskill)

{-|


# Bomblogic

Functions to handle the bomb logic in the game.

@docs refreshbombskill

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Ceo.Init exposing (..)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (distance, move)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)



-- the rotate function is already done in the judgeactivate function of bullet, now only the release function need to be done


{-| Checks if the bomb skill should be activated based on the current time and state.
-}
judgeactivate : InitData -> Env SceneCommonData UserData -> InitData
judgeactivate skill env =
    let
        position =
            skill.position

        time =
            env.globalData.sceneStartTime / 1000

        roundtime =
            time - toFloat (floor (time / 13)) * 13

        judge =
            modBy 4 (floor (time / 13)) == 3 && roundtime >= 0 && roundtime <= 5

        condition =
            skill.hit.ifon || skill.punch.ifon || skill.defend.ifon || skill.bullet.ifon

        bombskill =
            skill.bomb

        ( tempbombskill, newbomb ) =
            if judge && bombskill.ifon == False && not condition then
                ( { bombskill | ifon = True, time = env.globalData.sceneStartTime / 1000 }, [ addbomb position time ] )

            else if not judge && bombskill.ifon == True then
                ( { bombskill | ifon = False }, [] )

            else
                ( bombskill, [] )

        newbombskill =
            { tempbombskill | bombs = tempbombskill.bombs ++ newbomb }
    in
    { skill | bomb = newbombskill }


{-| Creates a new bomb at the specified position with the current time.
-}
addbomb : ( Float, Float ) -> Float -> Bomb
addbomb cposition nowtime =
    { position = move cposition ( -385, 5 )
    , direction = -1
    , attack = 50
    , time = nowtime
    , bombstate = Prepare
    , radius = 0
    , atoms = []
    }



-- this will be used every tick, so just add the radius would be enough


{-| Prepares the bomb for movement by increasing its radius until it reaches a maximum value.
-}
preparemove : Bomb -> Float -> Bomb
preparemove bomb time =
    if time - bomb.time <= 0.5 then
        bomb

    else if bomb.radius < 1 then
        let
            newradius =
                bomb.radius + 0.02

            newbomb =
                { bomb | radius = newradius }
        in
        newbomb

    else
        let
            newbomb =
                { bomb | radius = 1, bombstate = Ready }
        in
        newbomb



-- first change direction, then position


{-| Sets the direction of the bomb towards the specified position.
-}
readydir : Bomb -> ( Float, Float ) -> Bomb
readydir bomb position =
    let
        ( x1, y1 ) =
            bomb.position

        ( x2, y2 ) =
            position

        newdir =
            atan2 (y2 - y1) (x2 - x1)

        newbomb =
            { bomb | direction = newdir }
    in
    newbomb


{-| Moves the bomb in the direction it is facing.
-}
bombattack : Bomb -> Float -> Bomb
bombattack bomb dt =
    let
        old =
            bomb.position

        dir =
            bomb.direction

        newposition =
            move old ( 0.1 * cos dir * dt, 0.1 * sin dir * dt )

        newbomb =
            { bomb | position = newposition }
    in
    newbomb


{-| Moves the bomb to its new position based on its current state and the player's position.
-}
readymove : Bomb -> ( Float, Float ) -> Float -> Bomb
readymove bomb player dt =
    let
        tempbomb =
            readydir bomb player

        newbomb =
            bombattack tempbomb dt
    in
    newbomb


{-| Cleans the bombs by removing those that are too old or too close to the player.
-}
subclean1 : List Bomb -> Env SceneCommonData UserData -> List Bomb
subclean1 bombs env =
    let
        time =
            env.globalData.sceneStartTime / 1000

        newbombs =
            List.filter
                (\b ->
                    let
                        releasetime =
                            time - b.time

                        judge =
                            -- releasetime >= 0
                            releasetime <= 20
                    in
                    judge
                )
                bombs
    in
    newbombs


{-| Cleans the bombs by removing those that are too close to the player and calculates the damage.
-}
subclean2 : List Bomb -> ( Float, Float ) -> ( List Bomb, Float )
subclean2 bombs player =
    let
        oldlength =
            List.length bombs

        ( x, y ) =
            player

        remain =
            List.filter
                (\b ->
                    let
                        ( m, n ) =
                            b.position

                        judge =
                            distance ( m, n ) ( x, y ) <= 60

                        -- not that bomb center don't need to touch the player
                    in
                    not judge
                )
                bombs

        newlength =
            List.length remain

        hurt =
            toFloat (20 * (oldlength - newlength))
    in
    ( remain, hurt )


{-| Cleans the bombs that are too close to the player and returns the remaining bombs and the total damage.
-}
cleanbombs : List Bomb -> ( Float, Float ) -> Env SceneCommonData UserData -> ( List Bomb, Float )
cleanbombs bombs player env =
    let
        tempbombs =
            subclean1 bombs env

        newbombs =
            subclean2 tempbombs player
    in
    newbombs


{-| Refreshes the bombs by moving them and cleaning up those that are too close to the player.
-}
bombrefresh : List Bomb -> ( Float, Float ) -> Env SceneCommonData UserData -> Float -> ( List Bomb, Float )
bombrefresh bombs player env dt =
    let
        tempbombs =
            List.map
                (\b ->
                    if b.bombstate == Prepare then
                        preparemove b (env.globalData.sceneStartTime / 1000)

                    else
                        readymove b player dt
                )
                bombs

        ( newbombs, hurt ) =
            cleanbombs tempbombs player env
    in
    ( newbombs, hurt )


{-| Refreshes the bomb skill by checking if it should be activated and updating the bombs accordingly.
-}
refreshbombskill : InitData -> ( Float, Float ) -> Env SceneCommonData UserData -> Float -> ( InitData, Float )
refreshbombskill data player env dt =
    let
        tempdata =
            judgeactivate data env

        oldskill =
            tempdata.bomb

        oldbombs =
            oldskill.bombs

        ( newbombs, hurt ) =
            bombrefresh oldbombs player env dt

        newdata =
            { tempdata | bomb = { oldskill | bombs = newbombs } }
    in
    ( newdata, hurt )



-- the update will return player's position and hurt
-- only rely on player, have to rely on stored player position
-- TODO: get alpha for the preparemove
