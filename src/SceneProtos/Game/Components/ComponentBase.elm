module SceneProtos.Game.Components.ComponentBase exposing (ComponentMsg(..), ComponentTarget, BaseData, initBaseData)

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData, initBaseData

-}

import SceneProtos.Game.Components.Background.Init as BGInit
import SceneProtos.Game.Components.Boss.Init as BossInit
import SceneProtos.Game.Components.Bullet.Init as BulletInit
import SceneProtos.Game.Components.Ceo.Init as CeoInit
import SceneProtos.Game.Components.DW.Init as DWInit
import SceneProtos.Game.Components.Drop.Init as DropInit exposing (Droptype(..))
import SceneProtos.Game.Components.Enemy.Init as EnemyInit exposing (..)
import SceneProtos.Game.Components.Guidance.Init as GuideInit
import SceneProtos.Game.Components.Interface.Init as InterfaceInit
import SceneProtos.Game.Components.Map.Init as MapInit
import SceneProtos.Game.Components.Particle.Init as ParticleInit
import SceneProtos.Game.Components.Player.Init as PlayerInit
import SceneProtos.Game.Components.Survcamera.Init as SurCameraInit
import SceneProtos.Game.Components.Weapon.Init as WeaponInit



--import SceneProtos.Game.Components.Map.Model exposing (detectCollisionDirection)


{-| Component message
-}
type ComponentMsg
    = NullComponentMsg
    | BulletInitMsg BulletInit.InitData
    | EnemyInitMsg EnemyInit.InitData
    | PlayerInitMsg PlayerInit.InitData
    | WeaponInitMsg WeaponInit.InitData
    | BossInitMsg BossInit.InitData
    | SurCameraInitMsg SurCameraInit.InitData
    | CeoInitMsg CeoInit.InitData
    | SurCameraBullets (List SurCameraInit.CameraBullet)
    | NewCameraBullet (List SurCameraInit.CameraBullet)
    | Bullets (List BulletInit.SingleBullet)
    | LaserMsg ( BulletInit.SingleBullet, Bool )
    | NewBullets (List BulletInit.SingleBullet)
      -- I don't know why it doesn't work using the same bullet message, but it seems that three bullet message type is needed.
      -- No, it isn't this problem. Why it doesn't work????
      -- I think I know what's going wrong. Anyway, let's keep these three bullet message type, or we may have to deal with complicated message order problems, that will waste quite much time.
    | EnemyBullets (List EnemyInit.EnemyBullet)
    | PlayerStateMsg PlayerInit.State
    | InitPlayerStateMsg PlayerInit.State
    | WeaponStateMsg WeaponInit.State
    | EnemyStateMsg (List EnemyInit.Enemy)
    | WeaponDir Float
    | ShieldState WeaponInit.ShieldState
    | ShieldMsg WeaponInit.Shield
    | FireMsg BulletInit.SingleBullet
    | MapInitMsg MapInit.InitData
    | MechanicalArmMsg WeaponInit.MechanicalArm
    | CheckCollisionMsg { x : Float, y : Float, x1 : Float, y1 : Float, w : Float, h : Float }
    | DWCheckCollisionMsg { x : Float, y : Float, x1 : Float, y1 : Float, w : Float, h : Float }
    | BulletCheckCollisionMsg { x : Float, y : Float, x1 : Float, y1 : Float, w : Float, h : Float }
    | CollisionResultDirMsg (List MapInit.CollisionDirection)
    | CollisionResultMsg (Maybe MapInit.Tile)
    | FindKey ( Float, Float )
    | KeyAnimationMsg Bool
    | UpdateBlock (List ( Int, Int, MapInit.Tile ))
    | BulletCollisionResultMsg ( Float, Float )
    | MapMsg MapInit.InitData
    | InterfaceInitMsg InterfaceInit.InitData
    | MapInfo (List ( Int, Int, MapInit.Tile ))
    | DWInitMsg DWInit.InitData
    | ChangePause
    | GuideInitMsg GuideInit.InitData
    | PlayerDeadMsg
    | WinMsg
    | BGInitMsg BGInit.InitData
    | ParticleInitMsg ParticleInit.InitData
    | DoublejumpMsg ( Float, Float )
    | Hurt Float
    | NewPlayerPos ( Float, Float )
    | DropInitMsg DropInit.InitData
    | EnemyDieMsg ( Float, Float )
    | DropMsg Droptype
    | Rightbound Float


{-| Component target
-}
type alias ComponentTarget =
    String


{-| Component base data
-}
type alias BaseData =
    { isPaused : Bool }


{-| Initialize base data
-}
initBaseData : BaseData
initBaseData =
    { isPaused = False }
