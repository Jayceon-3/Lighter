module SceneProtos.Game.Components.ComponentBase exposing (..)

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData

-}

import SceneProtos.Game.Components.Bullet.Init as BulletInit
import SceneProtos.Game.Components.Enemy.Init as EnemyInit exposing (..)
import SceneProtos.Game.Components.Player.Init as PlayerInit
import SceneProtos.Game.Components.Weapon.Init as WeaponInit


{-| Component message
-}
type ComponentMsg
    = NullComponentMsg
    | BulletInitMsg BulletInit.InitData
    | EnemyInitMsg EnemyInit.InitData
    | PlayerInitMsg PlayerInit.InitData
    | WeaponInitMsg WeaponInit.InitData
    | Bullets (List BulletInit.SingleBullet)
    | EnemyBullets (List EnemyInit.EnemyBullet)
    | PlayerStateMsg PlayerInit.State
    | WeaponDir Float
    | FireMsg BulletInit.SingleBullet


{-| Component target
-}
type alias ComponentTarget =
    String


{-| Component base data
-}
type alias BaseData =
    ()
