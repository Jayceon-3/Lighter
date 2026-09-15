module SceneProtos.Game.Components.Ceo.Init exposing
    ( InitData
    , BulletSkill, Bulletstate(..), CeoBullet
    , Punchstate(..), PunchSkill
    , BombSkill, Bombstate(..), Bomb, Atom
    , DefendSkill, HitSkill
    )

{-|


# Init module

@docs InitData
@docs BulletSkill, Bulletstate, CeoBullet
@docs Punchstate, PunchSkill
@docs BombSkill, Bombstate, Bomb, Atom
@docs DefendSkill, HitSkill

-}

import REGL.Common exposing (Camera)


{-| The states of the ceo's bullet skill
`Default`: not activated
`Buffer`: the ceo is switching the state between default and attack
`Attack`: the ceo is attacking
-}
type Bulletstate
    = Default
    | Buffer
    | Attack


{-| The skill of shooting bullet of the ceo
`ifon`: whether this skill is on
`activatetime`: the last activating time
`shoottime`: last shoot time
`shootangle`: the angle of shooting image
`bullets`: all the existing ceo bullets
`state`: the state of this skill
`angle`: angle of shooting
`direction`: boss current shooting direction

Example:

    { ifon = True
    , activatetime = 1.2
    , shoottime = 0.5
    , shootangle = 0.0
    , bullets = []
    , state = Default
    , angle = 0.0
    , direction = 0.0
    }

-}
type alias BulletSkill =
    { ifon : Bool
    , activatetime : Float -- when close and open, this value need to be used twice
    , shoottime : Float
    , shootangle : Float
    , bullets : List CeoBullet
    , state : Bulletstate
    , angle : Float
    , direction : Float
    }


{-| The bullets ceo release

`position`: x and y coordinates of the bullet center.
`direction`: travel direction of the bullet in radians.
`attack`: damage value of the bullet.

Example:

    { position = ( 100, 200 )
    , direction = 1.57
    , attack = 10
    }

-}
type alias CeoBullet =
    { position : ( Float, Float )
    , direction : Float
    , attack : Float
    }


{-| Punchskill state

`Hand`: punch with the hand.
`Foot`: kick with the foot.

-}
type Punchstate
    = Hand
    | Foot


{-| The structure of punching

`ifon` : whether the punch skill is active.
`direction`: facing direction in radians.
`state`: type of punch (Hand or Foot).
`time`: time elapsed since activation.

Example:

    { ifon = False
    , direction = 0.0
    , state = Hand
    , time = 0.0
    }

-}
type alias PunchSkill =
    { ifon : Bool
    , direction : Float
    , state : Punchstate
    , time : Float
    }


{-| The state of bomb skill state

`Prepare`: bomb is charging.
`Ready`: bomb is ready to release.

-}
type Bombstate
    = Prepare
    | Ready


{-| The structure of bombs

`position`: center coordinates of the bomb.
`direction`: initial release direction in radians.
`attack`: damage value per atom.
`time`: release timestamp.
`bombstate`: current state of the bomb.
`radius`: explosion radius.
`atoms`: list of released atoms.

Example:

    { position = ( 300, 400 )
    , direction = 0.0
    , attack = 5
    , time = 1.0
    , bombstate = Ready
    , radius = 50
    , atoms = []
    }

-}
type alias Bomb =
    { position : ( Float, Float )
    , direction : Float
    , attack : Float
    , time : Float -- release time
    , bombstate : Bombstate
    , radius : Float
    , atoms : List Atom

    -- the angle will be just proportional to the radius
    }


{-| The atoms of visual effects

`position`: x and y coordinates of the atom.
`v`: velocity vector (vx, vy).
`color` RGB color triple, values between 0.0 and 1.0.
`releasetime`: timestamp when the atom was spawned.
`targettime`: lifespan duration of the atom.

Example:

    { position = ( 310, 410 )
    , v = ( 1.0, -1.0 )
    , color = ( 1.0, 0.0, 0.0 )
    , releasetime = 1.0
    , targettime = 0.5
    }

-}
type alias Atom =
    { position : ( Float, Float )
    , v : ( Float, Float )
    , color : ( Float, Float, Float )
    , releasetime : Float
    , targettime : Float
    }


{-| The structure of bomb skill

`ifon`: whether the bomb skill is active.
`bombs`: list of active Bomb instances.
`time`: current global scene time.

Example:

    { ifon = True
    , bombs = []
    , time = 0.0
    }

-}
type alias BombSkill =
    { ifon : Bool
    , bombs : List Bomb
    , time : Float
    }


{-| The structure of defend skill

`ifon`: whether the defend skill is active.
`activatetime`: timestamp when defense started.
`cd`: cooldown duration.
`v`: shield movement velocity.

Example:

    { ifon = False
    , activatetime = 0.0
    , cd = 2.0
    , v = 0.0
    }

-}
type alias DefendSkill =
    { ifon : Bool
    , activatetime : Float
    , cd : Float
    , v : Float
    }


{-| The structure of the hitting skill

`ifon`: whether the hit skill is active.
`activatetime`: timestamp when triggered.
`camera`: Camera settings for shake effect.

Example:

    { ifon = False
    , activatetime = 0.0
    , camera = Camera 0 0 1 0
    }

-}
type alias HitSkill =
    { ifon : Bool
    , activatetime : Float
    , camera : Camera
    }


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , ty : String
    , position : ( Float, Float )
    , hp : Float
    , bullet : BulletSkill
    , punch : PunchSkill
    , bomb : BombSkill
    , defend : DefendSkill
    , hit : HitSkill -- this is actually a remote attack
    , periodtime : Float
    , player : ( Float, Float )
    , dt : Float
    , msg : Bool
    }
