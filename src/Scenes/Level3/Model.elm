module Scenes.Level3.Model exposing (scene)

{-|


# Model

This module defines the scene model for Level 3 of the game.

@docs scene

-}

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
import SceneProtos.Game.Components.Ceo.Init as CeoInit
import SceneProtos.Game.Components.Ceo.Model as Ceo
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.DW.Init as DWInit
import SceneProtos.Game.Components.DW.Model as DW
import SceneProtos.Game.Components.Drop.Init as DropInit exposing (Droptype(..), Singledrop)
import SceneProtos.Game.Components.Drop.Model as Drop
import SceneProtos.Game.Components.Enemy.Init as EnemyInit
import SceneProtos.Game.Components.Enemy.Model as Enemy
import SceneProtos.Game.Components.Guidance.Init as GuideInit
import SceneProtos.Game.Components.Guidance.Model as Guidance
import SceneProtos.Game.Components.Interface.Init as InterfaceInit
import SceneProtos.Game.Components.Interface.Model as Interface
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
import Scenes.Level1.Getbound exposing (getboundpoints, tilebounds, tiles)
import Scenes.Level3.MakeMap3 exposing (map3)


init : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg)
init env msg =
    Just (initData env msg)


initData : Env () UserData -> Maybe SceneMsg -> InitData SceneMsg
initData env msg =
    { objects =
        [ Map.component (MapInitMsg <| MapInit.InitData 9 "Map" map3 60 60)
        , Interface.component (InterfaceInitMsg <| InterfaceInit.InitData 10 "Interface" env.globalData.camera)
        , BG.component (BGInitMsg <| BGInit.InitData 0 "Background" ( ( BG1, BG2 ), ( BG3, BG4 ) ) 0 ( 980, 540 ) ( 980, 540 ) ( 980, 540 ) ( 980, 540 ) ( 980, 540 ))
        , Player.component (PlayerInitMsg <| PlayerInit.InitData 1 "Player" { position = ( 150, 990 ), vx = 0, vy = 0, direction = 1, alive = True, hp = 100, a_pressed = False, d_pressed = False, s_pressed = False, canjump = 1, weaponDir = 1, keyNum = 0 } False { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) } [] tiles { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 } False 0)
        , Weapon.component (WeaponInitMsg <| WeaponInit.InitData 2 "Weapon" { position = ( 150, 700 ), direction = 1, angle = 0, weaponType = 1, energy = 100 } { position = ( 150, 700 ), direction = 1, angle = 0, shieldState = Unused, initTime = 0, initHandTime = 0 } { position = ( 150, 700 ), speed = ( 0, 0 ), angle = 0, state = Closed, length = 0, anchor = ( 0, 0 ), initSpringTime = 0, initSpringPos = ( 0, 0 ), swingMode = ( Short, 0 ) } 0 0 False False tiles (Scatter 0 False))
        , Bullet.component (BulletInitMsg <| BulletInit.InitData 3 "Bullet" [] ( { position = ( 0, 0 ), direction = 0, shape = ( 10, 5 ), angle = 0, bulletType = Laser, attack = 20 }, False ) 0 tiles)

        --, Enemy.component (EnemyInitMsg <| EnemyInit.InitData 4 "Enemy" [ testenemy ] [] tiles)
        --, DW.component (DWInitMsg <| DWInit.InitData 100 "DW" { position = ( -5000, -5000 ), vx = 0, vy = 0, direction = 1, hp = 100, alive = True, a_pressed = False, d_pressed = False, s_pressed = False, canjump = 1, weaponDir = 1, keyNum = 0 } [])
        --, Guidance.component (GuideInitMsg <| GuideInit.InitData 8 "Guidance")
        --, Survcamera.component (SurCameraInitMsg <| SurvcameraInit.InitData 6 "Survcamera" [ testcamera ] [] tiles tilebounds)
        , Particle.component (ParticleInitMsg <| ParticleInit.InitData 10 "Particle" { particles = [], bulletpos = [], seed = Random.initialSeed 12345 } ( 0, 0 ) False 0 100)
        , Ceo.component (CeoInitMsg defaultceo)
        , Drop.component (DropInitMsg <| DropInit.InitData [] ( 0, 0 ) 100 100 100)
        ]
    }


{-| Scene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genScene init


defaultceo : CeoInit.InitData
defaultceo =
    { id = 7
    , ty = "Ceo"
    , position = ( 1400, 670 ) -- 400*700
    , hp = 3000
    , bullet =
        { ifon = False
        , activatetime = 0
        , shoottime = -pi * 3 / 4
        , shootangle = -pi
        , bullets = []
        , state = CeoInit.Default
        , angle = 0
        , direction = -1
        }
    , punch =
        { ifon = False
        , direction = -1
        , state = CeoInit.Hand
        , time = 0
        }
    , bomb =
        { ifon = False
        , bombs = []
        , time = 0
        }
    , defend =
        { ifon = False
        , activatetime = 0
        , cd = 2.5
        , v = -10
        }
    , hit =
        { ifon = False
        , activatetime = 0
        , camera =
            { x = 1400
            , y = 640
            , zoom = 1
            , rotation = 0
            }
        }
    , periodtime = 0
    , player = ( 300, 960 )
    , dt = 0
    , msg = False
    }
