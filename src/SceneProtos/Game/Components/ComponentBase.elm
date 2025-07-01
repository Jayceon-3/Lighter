module SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..), ComponentTarget, BaseData)

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData

-}

import SceneProtos.Game.Components.Bullet.Init as BulletInit
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
    | ChangeDir Float
    | FireMsg BulletInit.SingleBullet


{-| Component target
-}
type alias ComponentTarget =
    String


{-| Component base data
-}
type alias BaseData =
    ()
