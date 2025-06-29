module Scenes.Level1.Model exposing (scene)

{-|


# Level configuration module

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Scene.LayeredScene exposing (LayeredSceneLevelInit)
import Messenger.Scene.Scene exposing (SceneStorage)
import SceneProtos.Game.Init exposing (InitData)
import SceneProtos.Game.Model exposing (genScene)


init : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg)
init env msg =
    Nothing


{-| Scene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genScene init
