module SceneProtos.Game.Model exposing (genScene)

{-| Scene configuration module

@docs genScene

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, addCommonData)
import Messenger.Scene.LayeredScene exposing (LayeredSceneEffectFunc, LayeredSceneLevelInit, LayeredSceneProtoInit, genLayeredScene, initCompose)
import Messenger.Scene.Scene exposing (SceneStorage)
import SceneProtos.Game.Init exposing (InitData)
import SceneProtos.Game.Main.Model as Main exposing (..)
import SceneProtos.Game.SceneBase exposing (..)


commonDataInit : Env () UserData -> Maybe (InitData SceneMsg) -> SceneCommonData
commonDataInit _ _ =
    {}


init : LayeredSceneProtoInit SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg (InitData SceneMsg)
init env data =
    let
        cd =
            commonDataInit env data

        envcd =
            addCommonData cd env
    in
    { renderSettings = []
    , commonData = cd
    , layers =
        [ Main.layer NullLayerMsg envcd ]
    }


settings : LayeredSceneEffectFunc SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg
settings _ _ _ =
    []


{-| Scene generator
-}
genScene : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg) -> SceneStorage UserData SceneMsg
genScene initd =
    genLayeredScene (initCompose init initd) settings
