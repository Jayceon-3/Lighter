module Scenes.Level1.Model exposing (scene)

{-|


# Model

This module defines the scene model for Level 1 of the game.

@docs scene

-}

import Array exposing (Array)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env)
import Messenger.Component.Component exposing (LevelComponentStorage)
import Messenger.Scene.LayeredScene exposing (LayeredSceneLevelInit)
import Messenger.Scene.Scene exposing (SceneStorage)
import Random
import SceneProtos.Game.Components.Background.BGUpdateHelp exposing (BGType(..))
import SceneProtos.Game.Components.Background.Init as BGInit
import SceneProtos.Game.Components.Background.Model as BG
import SceneProtos.Game.Components.Bullet.Init as BulletInit exposing (BulletType(..))
import SceneProtos.Game.Components.Bullet.Model as Bullet
import SceneProtos.Game.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
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
import SceneProtos.Game.Components.Map.Init as MapInit exposing (Tile)
import SceneProtos.Game.Components.Map.Model as Map
import SceneProtos.Game.Components.Particle.Init as ParticleInit exposing (Particle)
import SceneProtos.Game.Components.Particle.Model as Particle
import SceneProtos.Game.Components.Player.Init as PlayerInit
import SceneProtos.Game.Components.Player.Model as Player
import SceneProtos.Game.Components.Survcamera.Init as SurvcameraInit exposing (Survcamera)
import SceneProtos.Game.Components.Survcamera.Model as Survcamera
import SceneProtos.Game.Components.Weapon.Init as WeaponInit exposing (MechanicalArmState(..), Scatter, ShieldState(..), SwingMode(..))
import SceneProtos.Game.Components.Weapon.Model as Weapon
import SceneProtos.Game.Init exposing (InitData)
import SceneProtos.Game.Model exposing (genScene)
import SceneProtos.Game.SceneBase exposing (SceneCommonData)
import Scenes.Level1.Generateenemy exposing (..)
import Scenes.Level1.Getbound exposing (getboundpoints, temptiles, tilebounds, tiles)
import Scenes.Level1.MakeMap exposing (testTileMap)


init : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg)
init env msg =
    Just (initData env msg)


initData : Env () UserData -> Maybe SceneMsg -> InitData SceneMsg
initData env msg =
    { objects =
        [ Map.component (MapInitMsg <| MapInit.InitData 9 "Map" testTileMap 60 60)
        , Interface.component (InterfaceInitMsg <| InterfaceInit.InitData 10 "Interface" env.globalData.camera)
        , BG.component (BGInitMsg <| BGInit.InitData 0 "Background" ( ( BG1, BG2 ), ( BG3, BG4 ) ) 0 ( 220, 540 ) ( 220, 540 ) ( 220, 540 ) ( 220, 540 ) ( 220, 540 ))
        , Player.component (PlayerInitMsg <| PlayerInit.InitData 1 "Player" { position = ( 250, 2300 ), vx = 0, vy = 0, direction = 1, alive = True, hp = 100, a_pressed = False, d_pressed = False, s_pressed = False, canjump = 1, weaponDir = 1, keyNum = 0 } False { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) } [] tiles { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 } False 0)
        , Weapon.component (WeaponInitMsg <| WeaponInit.InitData 2 "Weapon" { position = ( 150, 700 ), direction = 1, angle = 0, weaponType = 1, energy = 100 } { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 } { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) } 0 0 False False tiles (Scatter 0 False))
        , Bullet.component (BulletInitMsg <| BulletInit.InitData 3 "Bullet" [] ( { position = ( 0, 0 ), direction = 0, shape = ( 10, 5 ), angle = 0, bulletType = Laser, attack = 20 }, False ) 0 tiles)
        , Enemy.component (EnemyInitMsg <| EnemyInit.InitData 4 "Enemy" (enemy1 env) [] 0 ( 250, 2300 ))
        , DW.component (DWInitMsg <| DWInit.InitData 100 "DW" { position = ( -5000, -5000 ), vx = 0, vy = 0, direction = 1, hp = 100, alive = True, a_pressed = False, d_pressed = False, s_pressed = False, canjump = 1, weaponDir = 1, keyNum = 0 } [])
        , Guidance.component (GuideInitMsg <| GuideInit.InitData 8 "Guidance")
        , Survcamera.component (SurCameraInitMsg <| SurvcameraInit.InitData 6 "Survcamera" camera1 [] tiles 0)
        , Particle.component (ParticleInitMsg <| ParticleInit.InitData 10 "Particle" { particles = [], bulletpos = [], seed = Random.initialSeed 12345 } ( 0, 0 ) False 0 100)
        , Drop.component (DropInitMsg <| DropInit.InitData testdrops ( 0, 0 ) 100 100 100)
        ]

    -- , objects2 =
    --     [ Bullet.component (BulletInitMsg <| BulletInit.InitData 3 "Bullet" [] ( { position = ( 0, 0 ), direction = 0, shape = ( 10, 5 ), angle = 0, bulletType = Laser, attack = 20 }, False ) 0 tiles)
    --     , Particle.component (ParticleInitMsg <| ParticleInit.InitData { particles = [], bulletpos = [], seed = Random.initialSeed 12345 } ( 0, 0 ) False 0 100)
    --     ]
    }


{-| Scene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genScene init


enemyList1 : List ( ( Float, Float ), Int )
enemyList1 =
    enemyList11
        ++ enemyList12
        ++ enemyList13
        ++ enemyList14


enemyList11 : List ( ( Float, Float ), Int )
enemyList11 =
    [ ( ( 1100, 1770 ), 1 )
    , ( ( 1200, 1770 ), 2 )
    , ( ( 1300, 1770 ), 3 )
    , ( ( 2250, 1770 ), 1 )
    , ( ( 2350, 1770 ), 3 )
    , ( ( 1200, 1050 ), 2 )
    , ( ( 1300, 1050 ), 3 )
    , ( ( 1400, 1050 ), 2 )
    , ( ( 1600, 1170 ), 1 )
    , ( ( 1700, 1170 ), 2 )
    ]


enemyList12 : List ( ( Float, Float ), Int )
enemyList12 =
    [ ( ( 900, 1110 ), 3 )
    , ( ( 800, 1110 ), 2 )
    , ( ( 700, 1110 ), 3 )
    , ( ( 600, 870 ), 1 )
    , ( ( 700, 870 ), 2 )
    , ( ( 600, 510 ), 1 )
    , ( ( 800, 510 ), 3 )
    , ( ( 1300, 690 ), 2 )
    , ( ( 2800, 390 ), 1 )
    , ( ( 2900, 390 ), 2 )
    ]


enemyList13 : List ( ( Float, Float ), Int )
enemyList13 =
    [ ( ( 3600, 750 ), 3 )
    , ( ( 4000, 690 ), 1 )
    , ( ( 4000, 1170 ), 2 )
    , ( ( 4200, 1170 ), 3 )
    , ( ( 4300, 1170 ), 1 )
    , ( ( 4000, 1530 ), 1 )
    , ( ( 4200, 1530 ), 2 )
    ]


enemyList14 : List ( ( Float, Float ), Int )
enemyList14 =
    [ ( ( 4100, 1530 ), 1 )
    , ( ( 4300, 1530 ), 3 )
    , ( ( 3200, 1950 ), 3 )
    , ( ( 4200, 1950 ), 3 )
    , ( ( 4000, 2310 ), 2 )
    , ( ( 3900, 2310 ), 1 )
    , ( ( 4100, 2310 ), 3 )
    ]



-- testenemy : Enemy
-- testenemy =
--     egenerator ( ( 1100, 1770 ), 1 ) temptiles


enemy1 : Env () UserData -> List Enemy
enemy1 env =
    generateenemies env enemyList1 temptiles


testcamera : Survcamera
testcamera =
    cgenerator ( ( 1260, 840 ), 3 ) tiles


camera1 : List Survcamera
camera1 =
    generatecameras cameraList1 temptiles


cameraList1 : List ( ( Float, Float ), Float )
cameraList1 =
    [ ( ( 1320, 840 ), 4 )
    , ( ( 4080, 1320 ), 4 )
    , ( ( 1020, 1920 ), 3 )
    ]


testdrops : List Singledrop
testdrops =
    let
        pos1 =
            ( 1700, 2300 )

        pos2 =
            ( 1800, 2300 )

        pos3 =
            ( 1900, 2300 )

        v =
            10

        size =
            25
    in
    [ Singledrop pos1 size Life 1 pos1 v
    , Singledrop pos2 size Energy 1 pos2 v
    , Singledrop pos3 size Scatterbullet 1 pos3 v
    ]
