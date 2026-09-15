module SceneProtos.Game.Components.Ceo.Bulletlogic exposing (advanceskills, newplayer)

{-|


# Bulletlogic

Logic for updating the bullet.

@docs advanceskills, newplayer

-}

import Lib.UserData exposing (UserData)
import Messenger.Base exposing (..)
import SceneProtos.Game.Components.Ceo.Bomblogic exposing (..)
import SceneProtos.Game.Components.Ceo.Init exposing (..)
import SceneProtos.Game.Components.Enemy.Enemylogic exposing (move)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)


judgeactivate : BulletSkill -> Env SceneCommonData UserData -> Bool -> BulletSkill
judgeactivate bullet env condition =
    let
        time =
            env.globalData.sceneStartTime / 1000

        passtime =
            time - bullet.activatetime

        judge =
            modBy 4 (floor (time / 13)) == 3

        newbullet =
            if passtime >= 13 && bullet.ifon == False && not judge && not condition then
                { bullet | ifon = True, state = Attack, activatetime = time }

            else if passtime >= 5 && bullet.ifon == True then
                { bullet | ifon = False, state = Buffer }

            else if passtime >= 5 && passtime <= 13 && bullet.state == Buffer then
                rotategenerator bullet env

            else
                bullet
    in
    newbullet


rotategenerator : BulletSkill -> Env SceneCommonData UserData -> BulletSkill
rotategenerator bullet env =
    let
        previoustime =
            env.globalData.sceneStartTime / 1000 - bullet.activatetime

        newangle =
            if previoustime <= 2 then
                pi * previoustime / 2

            else if previoustime >= 6 && previoustime <= 8 then
                pi * (8 - previoustime) / 2

            else
                pi

        newstate =
            if previoustime >= 2 && bullet.state == Buffer then
                Default

            else if previoustime >= 6 && bullet.state == Default then
                Buffer

            else
                bullet.state

        newbullet =
            { bullet | angle = newangle, state = newstate }
    in
    newbullet


addbullet : BulletSkill -> Env SceneCommonData UserData -> ( Float, Float ) -> BulletSkill
addbullet bullet env ceoposition =
    let
        ( x, y ) =
            ceoposition

        time =
            bullet.shoottime

        current =
            env.globalData.sceneStartTime / 1000

        newbullet =
            if current - time >= 0.4 then
                let
                    newangle =
                        if current - bullet.activatetime <= 2.5 then
                            -pi * 3 / 4 - pi / 2 * (current - bullet.activatetime) / 2.5

                        else
                            -pi * 3 / 4 - pi / 2 * (5 - (current - bullet.activatetime)) / 2.5
                in
                [ { position = ( x - 325, y + 5 )
                  , direction = newangle
                  , attack = 10
                  }
                ]

            else
                []

        newskill =
            if current - time >= 0.4 then
                { bullet | shoottime = current, bullets = bullet.bullets ++ newbullet }

            else
                bullet
    in
    newskill


movebullets : List CeoBullet -> Float -> List CeoBullet
movebullets bullet dt =
    let
        newbullets =
            List.map
                (\b ->
                    { b | position = move b.position ( 0.5 * cos b.direction * dt, 0.5 * sin b.direction * dt ) }
                )
                bullet
    in
    newbullets


subclear1 : List CeoBullet -> List CeoBullet
subclear1 bullets =
    List.filter
        (\b ->
            let
                ( x, y ) =
                    b.position

                judge =
                    x >= 0 && x <= 1920 && y >= 0 && y <= 960
            in
            judge
        )
        bullets


subclear2 : List CeoBullet -> ( Float, Float ) -> ( List CeoBullet, Float )
subclear2 bullets player =
    let
        beforelength =
            List.length bullets

        ( x, y ) =
            player

        newbullets =
            List.filter
                (\b ->
                    let
                        ( m, n ) =
                            b.position

                        judge =
                            abs (x - m) <= 15 && abs (y - n) <= 30
                    in
                    not judge
                )
                bullets

        afterlength =
            List.length newbullets

        hurt =
            toFloat (10 * (beforelength - afterlength))
    in
    ( newbullets, hurt )


clearbullets : List CeoBullet -> ( Float, Float ) -> ( List CeoBullet, Float )
clearbullets bullets player =
    let
        ( tempbullets, hurt ) =
            subclear2 bullets player

        newbullets =
            subclear1 tempbullets
    in
    ( newbullets, hurt )


refreshbullets : BulletSkill -> Env SceneCommonData UserData -> ( Float, Float ) -> ( Float, Float ) -> Float -> ( BulletSkill, Float )
refreshbullets skill env ceoposition player dt =
    let
        tempskill =
            if skill.ifon then
                addbullet skill env ceoposition

            else
                skill

        beforebullets =
            tempskill.bullets

        tempbullets =
            movebullets beforebullets dt

        ( newbullets, hurt ) =
            clearbullets tempbullets player

        newskill =
            { tempskill | bullets = newbullets }
    in
    ( newskill, hurt )


updatebullet : InitData -> Env SceneCommonData UserData -> ( Float, Float ) -> Float -> ( InitData, Float )
updatebullet data env player dt =
    let
        judge =
            data.hit.ifon || data.punch.ifon || data.defend.ifon || data.bomb.ifon

        tempdata =
            { data | bullet = judgeactivate data.bullet env judge }

        ( newbullets, hurt ) =
            refreshbullets tempdata.bullet env data.position player dt

        newdata =
            { tempdata | bullet = newbullets }
    in
    ( newdata, hurt )


{-| refresh bullet and bomb skills
-}
advanceskills : InitData -> Env SceneCommonData UserData -> ( Float, Float ) -> Float -> ( InitData, Float )
advanceskills data env player dt =
    let
        ( tempdata, hurt1 ) =
            updatebullet data env player dt

        ( newdata, hurt2 ) =
            refreshbombskill tempdata player env dt
    in
    ( newdata, hurt1 + hurt2 )


{-| refresh player's position
-}
newplayer : ( Float, Float ) -> InitData -> ( Float, Float )
newplayer player data =
    let
        ( x, y ) =
            player

        ( m, _ ) =
            data.position

        judge1 =
            x >= m - 150

        judge2 =
            x <= 0

        ( p, q ) =
            if judge1 then
                ( m - 150, y )

            else if judge2 then
                ( 30, y )

            else
                player

        newpos =
            if q >= 930 then
                ( p, 930 )

            else
                ( p, q )
    in
    newpos
