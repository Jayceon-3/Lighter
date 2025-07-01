module SceneProtos.Game.Components.ComponentBase exposing (..)

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData

-}

import SceneProtos.Game.Components.Bullet.Init as BulletInit
<<<<<<< HEAD
import SceneProtos.Game.Components.Enemy.Init as EnemyInit
=======
import SceneProtos.Game.Components.Enemy.Init as EnemyInit exposing (..)
>>>>>>> caf196d (feat: side changes of decrease blood logic of enemies)
import SceneProtos.Game.Components.Player.Init as PlayerInit
import SceneProtos.Game.Components.Weapon.Init as WeaponInit


{-| Component message
-}
type ComponentMsg
    = NullComponentMsg
<<<<<<< HEAD
    | PlayerInitMsg PlayerInit.InitData
    | WeaponInitMsg WeaponInit.InitData
    | BulletInitMsg BulletInit.InitData
    | PlayerStateMsg PlayerInit.State
    | WeaponDir Float
    | FireMsg BulletInit.SingleBullet
=======
    | BulletInitMsg BulletInit.InitData
>>>>>>> 0ee66e7 (feat(bullet and enemy): update the player bullet that can hurt the enemies)
    | EnemyInitMsg EnemyInit.InitData
    | PlayerInitMsg PlayerInit.InitData
    | Bullets (List BulletInit.Bullet)
    | EnemyBullets (List EnemyInit.EnemyBullet)
    | PlayerMsg PlayerInit.State


{-| Component target
-}
type alias ComponentTarget =
    String


{-| Component base data
-}
type alias BaseData =
    ()
