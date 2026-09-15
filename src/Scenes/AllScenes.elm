module Scenes.AllScenes exposing (allScenes)

{-|


# AllScenes

Record all the scenes here

@docs allScenes

-}

import Dict
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Scene.Scene exposing (AllScenes)
import Scenes.Demo.Model as Demo
import Scenes.Home.Model as Home
import Scenes.Level1.Model as Level1
import Scenes.Level2.Model as Level2
import Scenes.Level3.Model as Level3
import Scenes.Level4.Model as Level4
import Scenes.Settings.Model as Settings
import Scenes.Transition1.Model as Transition1
import Scenes.Transition2.Model as Transition2
import Scenes.Transition3.Model as Transition3
import Scenes.Transition4.Model as Transition4
import Scenes.Transition5.Model as Transition5


{-| All Scenes

Store all the scenes with their name here.

-}
allScenes : AllScenes UserData SceneMsg
allScenes =
    Dict.fromList
        [ ( "Demo", Demo.scene )
        , ( "Home", Home.scene )
        , ( "Level1", Level1.scene )
        , ( "Level2", Level2.scene )
        , ( "Level3", Level3.scene )
        , ( "Level4", Level4.scene )
        , ( "Settings", Settings.scene )
        , ( "Transition1", Transition1.scene )
        , ( "Transition2", Transition2.scene )
        , ( "Transition3", Transition3.scene )
        , ( "Transition4", Transition4.scene )
        , ( "Transition5", Transition5.scene )
        ]
