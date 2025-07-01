module Scenes.Level1.Model exposing (scene)

{-|


# Level configuration module

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env)
import Messenger.Scene.LayeredScene exposing (LayeredSceneLevelInit)
import Messenger.Scene.Scene exposing (SceneStorage)
import SceneProtos.Game.Components.Bullet.Init as BulletInit
import SceneProtos.Game.Components.Bullet.Model as Bullet
import SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Game.Components.Player.Init as PlayerInit
import SceneProtos.Game.Components.Player.Model as Player
import SceneProtos.Game.Components.Weapon.Init as WeaponInit
import SceneProtos.Game.Components.Weapon.Model as Weapon
import SceneProtos.Game.Init exposing (InitData)
import SceneProtos.Game.Model exposing (genScene)


init : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg)
init env msg =
    Just (initData env msg)


initData : Env () UserData -> Maybe SceneMsg -> InitData SceneMsg
initData env msg =
    { objects =
        [ Player.component (PlayerInitMsg <| PlayerInit.InitData 1 "Player" { position = ( 100, 700 ), vx = 0, vy = 0, direction = 1, alive = True, hp = 100, a_pressed = False, d_pressed = False, canjump = 1 })
        , Weapon.component (WeaponInitMsg <| WeaponInit.InitData 2 "Weapon" { position = ( 150, 700 ), direction = 1, angle = 0, weaponType = 1, energy = 100 })
        , Bullet.component (BulletInitMsg <| BulletInit.InitData 3 "Bullet" [])
        ]
    }


{-| Scene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genScene init
