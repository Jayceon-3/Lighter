module SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..), ComponentTarget, BaseData)

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData

-}

import SceneProtos.Game.Components.Bullet.Init as BulletInit
import SceneProtos.Game.Components.Enemy.Init as EnemyInit
import SceneProtos.Game.Components.Player.Init as PlayerInit
import SceneProtos.Game.Components.Weapon.Init as WeaponInit


{-| Component message
-}
type ComponentMsg
    = NullComponentMsg
    | PlayerInitMsg PlayerInit.InitData
    | WeaponInitMsg WeaponInit.InitData
    | BulletInitMsg BulletInit.InitData
    | PlayerStateMsg PlayerInit.State
    | WeaponDir Float
    | FireMsg BulletInit.SingleBullet
    | EnemyInitMsg EnemyInit.InitData
    | Bullets (List Bullet)


{-| Component target
-}
type alias ComponentTarget =
    String


{-| Component base data
-}
type alias BaseData =
    ()


type alias Bullet =
    { position : ( Float, Float )
    , attack : Float
    , side : Bool --here true means this bullet is from player, false means this bullet is from enemy
    }
