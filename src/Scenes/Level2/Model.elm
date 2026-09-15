module Scenes.Level2.Model exposing (scene)

{-|


# Model

This module defines the scene model for Level 2 of the game.

@docs scene

-}

import Array exposing (Array)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env)
import Messenger.Scene.LayeredScene exposing (LayeredSceneLevelInit)
import Messenger.Scene.Scene exposing (SceneStorage)
import Random
import SceneProtos.Game.Components.Background.BGUpdateHelp exposing (BGType(..))
import SceneProtos.Game.Components.Background.Init as BGInit
import SceneProtos.Game.Components.Background.Model as BG
import SceneProtos.Game.Components.Bullet.Init as BulletInit exposing (BulletType(..))
import SceneProtos.Game.Components.Bullet.Model as Bullet
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.DW.Init as DWInit
import SceneProtos.Game.Components.DW.Model as DW
import SceneProtos.Game.Components.Drop.Init as DropInit exposing (Droptype(..), Singledrop)
import SceneProtos.Game.Components.Drop.Model as Drop
import SceneProtos.Game.Components.Enemy.Init as EnemyInit exposing (Enemy)
import SceneProtos.Game.Components.Enemy.Model as Enemy
import SceneProtos.Game.Components.Guidance.Init as GuideInit
import SceneProtos.Game.Components.Guidance.Model as Guidance
import SceneProtos.Game.Components.Interface.Init as InterfaceInit
import SceneProtos.Game.Components.Interface.Model as Interface
import SceneProtos.Game.Components.Map.CollisionLogic exposing (getmapinformation)
import SceneProtos.Game.Components.Map.Init as MapInit
import SceneProtos.Game.Components.Map.Model as Map
import SceneProtos.Game.Components.Particle.Init as ParticleInit exposing (Particle)
import SceneProtos.Game.Components.Particle.Model as Particle
import SceneProtos.Game.Components.Player.Init as PlayerInit
import SceneProtos.Game.Components.Player.Model as Player
import SceneProtos.Game.Components.Survcamera.Init as SurvcameraInit
import SceneProtos.Game.Components.Survcamera.Model as Survcamera
import SceneProtos.Game.Components.Weapon.Init as WeaponInit exposing (MechanicalArmState(..), Scatter, ShieldState(..), SwingMode(..))
import SceneProtos.Game.Components.Weapon.Model as Weapon
import SceneProtos.Game.Init exposing (InitData)
import SceneProtos.Game.Model exposing (genScene)
import Scenes.Level1.Generateenemy exposing (generatecameras, generateenemies)
import Scenes.Level1.Getbound exposing (getboundpoints, tilebounds, tiles)
import Scenes.Level2.MakeMap2 exposing (map2, temptiles2)



--import Scenes.Level2.MakeMap2 exposing (testTileMap)


init : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg)
init env msg =
    Just (initData env msg)


initData : Env () UserData -> Maybe SceneMsg -> InitData SceneMsg
initData env msg =
    { objects =
        [ Map.component (MapInitMsg <| MapInit.InitData 9 "Map" map2 60 60)
        , Interface.component (InterfaceInitMsg <| InterfaceInit.InitData 10 "Interface" env.globalData.camera)
        , BG.component (BGInitMsg <| BGInit.InitData 0 "Background" ( ( BG1, BG2 ), ( BG3, BG4 ) ) 0 ( 220, 540 ) ( 220, 540 ) ( 220, 540 ) ( 220, 540 ) ( 220, 540 ))

        --, Player.component (PlayerInitMsg <| PlayerInit.InitData 1 "Player" { position = ( 250, 2300 ), vx = 0, vy = 0, direction = 1, alive = True, hp = 100, a_pressed = False, d_pressed = False, s_pressed = False, canjump = 1, weaponDir = 1, keyNum = 0 } False { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) } [] tiles { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 } False 0)
        , Player.component (PlayerInitMsg <| PlayerInit.InitData 1 "Player" { position = ( 4620, 900 ), vx = 0, vy = 0, direction = 1, alive = True, hp = 100, a_pressed = False, d_pressed = False, s_pressed = False, canjump = 1, weaponDir = 1, keyNum = 0 } False { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) } [] tiles { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 } False 0)
        , Weapon.component (WeaponInitMsg <| WeaponInit.InitData 2 "Weapon" { position = ( 150, 700 ), direction = 1, angle = 0, weaponType = 1, energy = 100 } { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 } { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) } 0 0 False False tiles (Scatter 0 False))
        , Bullet.component (BulletInitMsg <| BulletInit.InitData 3 "Bullet" [] ( { position = ( 0, 0 ), direction = 0, shape = ( 10, 5 ), angle = 0, bulletType = Laser, attack = 20 }, False ) 0 tiles)
        , Enemy.component (EnemyInitMsg <| EnemyInit.InitData 4 "Enemy" (enemy2 env) [] 0 ( 250, 2300 ))
        , DW.component (DWInitMsg <| DWInit.InitData 100 "DW" { position = ( -5000, -5000 ), vx = 0, vy = 0, direction = 1, hp = 100, alive = True, a_pressed = False, d_pressed = False, s_pressed = False, canjump = 1, weaponDir = 1, keyNum = 0 } [])
        , Guidance.component (GuideInitMsg <| GuideInit.InitData 8 "Guidance")
        , Survcamera.component (SurCameraInitMsg <| SurvcameraInit.InitData 6 "Survcamera" camera2 [] tiles 0)
        , Particle.component (ParticleInitMsg <| ParticleInit.InitData 10 "Particle" { particles = [], bulletpos = [], seed = Random.initialSeed 12345 } ( 0, 0 ) False 0 100)
        , Drop.component (DropInitMsg <| DropInit.InitData testdrops ( 0, 0 ) 100 100 100)
        ]

    -- , objects2 = []
    }


enemyList2 : List ( ( Float, Float ), Int )
enemyList2 =
    enemyList21
        ++ enemyList22
        ++ enemyList23
        ++ enemyList24
        ++ enemyList25


enemyList21 : List ( ( Float, Float ), Int )
enemyList21 =
    [ ( ( 1100, 1890 ), 1 )
    , ( ( 1300, 1890 ), 2 )
    , ( ( 1500, 1890 ), 3 )
    , ( ( 1050, 1290 ), 2 )
    , ( ( 500, 870 ), 1 )
    , ( ( 700, 870 ), 2 )
    , ( ( 800, 870 ), 3 )
    , ( ( 1300, 690 ), 2 )
    , ( ( 1400, 690 ), 1 )
    , ( ( 1500, 690 ), 3 )
    ]


enemyList22 : List ( ( Float, Float ), Int )
enemyList22 =
    [ ( ( 1600, 690 ), 2 )
    , ( ( 2100, 570 ), 3 )
    , ( ( 2200, 510 ), 1 )
    , ( ( 1200, 2310 ), 3 )
    , ( ( 2600, 1890 ), 1 )
    , ( ( 2650, 1890 ), 2 )
    , ( ( 3000, 2250 ), 1 )
    , ( ( 3200, 2250 ), 2 )
    ]


enemyList23 : List ( ( Float, Float ), Int )
enemyList23 =
    [ ( ( 4200, 1770 ), 2 )
    , ( ( 4100, 1770 ), 1 )
    , ( ( 4150, 1470 ), 3 )
    , ( ( 3500, 1290 ), 1 )
    , ( ( 3700, 1290 ), 2 )
    , ( ( 4700, 1230 ), 3 )
    , ( ( 3000, 1410 ), 1 )
    , ( ( 2800, 1410 ), 2 )
    , ( ( 2600, 1410 ), 3 )
    ]


enemyList24 : List ( ( Float, Float ), Int )
enemyList24 =
    [ ( ( 2600, 1170 ), 2 )
    , ( ( 3600, 870 ), 1 )
    , ( ( 3400, 870 ), 2 )
    , ( ( 3500, 870 ), 3 )
    , ( ( 4400, 870 ), 2 )
    , ( ( 4500, 870 ), 1 )
    , ( ( 4100, 810 ), 3 )
    , ( ( 4500, 870 ), 1 )
    ]


enemyList25 : List ( ( Float, Float ), Int )
enemyList25 =
    [ ( ( 3000, 390 ), 2 )
    , ( ( 2600, 330 ), 3 )
    , ( ( 3950, 510 ), 1 )
    , ( ( 4050, 510 ), 2 )
    , ( ( 3400, 2250 ), 3 )
    , ( ( 3600, 2250 ), 1 )
    , ( ( 4600, 2070 ), 3 )
    ]


camera2 : List SurvcameraInit.Survcamera
camera2 =
    generatecameras cameraList1 temptiles2


cameraList1 : List ( ( Float, Float ), Float )
cameraList1 =
    [ ( ( 4500, 660 ), 4 )
    , ( ( 2730, 60 ), 7 )
    , ( ( 1200, 2040 ), 5 )
    ]


enemy2 : Env () UserData -> List Enemy
enemy2 env =
    generateenemies env enemyList2 temptiles2


{-| Scene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genScene init


testdrops : List Singledrop
testdrops =
    let
        pos1 =
            ( 850, 2300 )

        pos2 =
            ( 950, 2300 )

        pos3 =
            ( 1050, 2300 )

        v =
            10

        size =
            25
    in
    [ Singledrop pos1 size Life 1 pos1 v
    , Singledrop pos2 size Energy 1 pos2 v
    , Singledrop pos3 size Scatterbullet 1 pos3 v
    ]
