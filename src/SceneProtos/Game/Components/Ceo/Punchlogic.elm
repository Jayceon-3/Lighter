module SceneProtos.Game.Components.Ceo.Punchlogic exposing (judgeLaser, normalskills, playerbullet)

{-|


# Punchlogic

Logic for punching

@docs judgeLaser, normalskills, playerbullet

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Bullet.Init exposing (SingleBullet)
import SceneProtos.Game.Components.Ceo.Init exposing (..)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (move)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


changestate : InitData -> ( Float, Float ) -> List SingleBullet -> Env SceneCommonData UserData -> InitData
changestate data player bullets env =
    let
        skill1 =
            data.punch

        skill2 =
            data.hit

        skill3 =
            data.defend

        ( x, _ ) =
            player

        ( m, _ ) =
            data.position

        nowtime =
            env.globalData.sceneStartTime / 1000

        judge =
            data.bullet.ifon || data.bomb.ifon

        tempdata =
            if m - x >= 600 && skill2.ifon == False && not judge && nowtime - skill2.activatetime > 5 || nowtime < 5 then
                { data | hit = { skill2 | ifon = True, activatetime = nowtime } }

            else if m - x <= 265 && skill1.ifon == False && not judge && nowtime - skill1.time > 5 then
                { data | punch = { skill1 | ifon = True, time = nowtime } }

            else if m - x <= 950 && m - x >= 265 && skill2.ifon == False && skill1.ifon == False && env.globalData.sceneStartTime / 1000 - skill3.activatetime >= skill3.cd + 3 && not judge then
                judgedefend data bullets nowtime

            else
                data

        newdata =
            if (skill2.ifon && nowtime - skill2.activatetime >= 4) || (m - x) < 800 then
                { tempdata | hit = { skill2 | ifon = False } }

            else if skill1.ifon && nowtime - skill1.time >= 4 then
                { tempdata | punch = { skill1 | ifon = False } }

            else if skill3.ifon && nowtime - skill3.activatetime >= 3 then
                { tempdata | defend = { skill3 | ifon = False } }

            else
                tempdata
    in
    newdata


judgedefend : InitData -> List SingleBullet -> Float -> InitData
judgedefend data bullets nowtime =
    let
        ( x, y ) =
            data.position

        valid =
            List.filter
                (\b ->
                    let
                        ( m, n ) =
                            b.position

                        judge =
                            abs (m - x) <= 70 && abs (n - y) <= 60
                    in
                    judge
                )
                bullets

        acjudge =
            not (List.isEmpty valid)

        newdata =
            if acjudge then
                let
                    defendskill =
                        data.defend

                    tempdata =
                        { data | defend = { defendskill | ifon = True, activatetime = nowtime } }
                in
                tempdata

            else
                data
    in
    newdata


attackplayer : InitData -> ( Float, Float ) -> Float -> Float
attackplayer data player dt =
    let
        ( x, y ) =
            player

        ( m, n ) =
            data.position

        ifhit =
            data.hit.ifon

        ifpunch =
            data.punch.ifon

        hurt1 =
            if (abs (y - 1020) <= 90 || (x <= 510 && y - 720 <= 90)) && ifhit && (m - x) >= 600 then
                2 * dt / 1000

            else
                0

        hurt2 =
            if abs (y - n) <= 300 && (m - x) <= 200 && ifpunch then
                2 * dt / 1000

            else
                0

        hurt =
            hurt1 + hurt2
    in
    hurt



-- this must be called every tick


defendmove : InitData -> InitData
defendmove data =
    if data.defend.ifon then
        let
            newposition =
                move data.position ( data.defend.v, 0 )

            olddefend =
                data.defend

            v =
                olddefend.v

            newv =
                if v /= -10 then
                    v - 1

                else
                    v

            newdata =
                { data | position = newposition, defend = { olddefend | v = newv } }
        in
        newdata

    else
        data


{-| refresh the punch, defend and hit skills
-}
normalskills : InitData -> ( Float, Float ) -> List SingleBullet -> Env SceneCommonData UserData -> Float -> ( InitData, Float )
normalskills data player bullets env dt =
    let
        tempdata =
            changestate data player bullets env

        newdata =
            defendmove tempdata

        hurt =
            attackplayer data player dt
    in
    ( newdata, hurt )


{-| judge the attack from the bullets released by the player
-}
playerbullet : InitData -> List SingleBullet -> ( InitData, List SingleBullet )
playerbullet data bullets =
    let
        ( m, n ) =
            data.position

        remain =
            List.filter
                (\b ->
                    let
                        ( x, y ) =
                            b.position

                        judge =
                            abs (x - m) <= 200 && abs (y - n) <= 350
                    in
                    not judge
                )
                bullets

        olddamage =
            List.foldl (\b acc -> b.attack + acc) 0 bullets

        remaindamage =
            List.foldl (\b acc -> b.attack + acc) 0 remain

        damage =
            olddamage - remaindamage

        newhp =
            if data.defend.ifon then
                data.hp

            else
                data.hp - damage
    in
    ( { data | hp = newhp }, remain )


laserDecreaseBlood : InitData -> InitData
laserDecreaseBlood data =
    let
        damage =
            1
    in
    { data | hp = data.hp - damage }


judgeattack : ( Float, Float ) -> SingleBullet -> Bool
judgeattack ( px, py ) bullet =
    let
        left =
            px - 200

        horiz =
            left - px

        real =
            150 * cos bullet.angle

        judge =
            real > horiz
    in
    judge


{-| judge the laser attack to the ceo
-}
judgeLaser : ( SingleBullet, Bool ) -> InitData -> InitData
judgeLaser laserMsg data =
    let
        laser =
            Tuple.first laserMsg

        ifon =
            Tuple.second laserMsg

        position =
            data.position

        judge =
            judgeattack position laser

        newdata =
            if judge && ifon then
                laserDecreaseBlood data

            else
                data
    in
    newdata
