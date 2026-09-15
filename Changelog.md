# Changelog

All notable changes to this project will be documented in this file.

Mainly focus on the branch ***dev*** and ***master***.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

Currently, nothing unreleased.

## [1.0.0] - 2025/8/2 - 2025/8/5

### Added

- elm doc

## [0.5.0] - 2025/7/25 - 2025/8/1

### Added

- add updateblock msg

- enter to skip dialogue

- transition page

- backgound image

### Changed

- button to esc instead of key

- polish buttons

- modify laser sound effect

- bullet sound effect

- change block's type in dw

- change changing logic

- number of backgrounds

- adjust hp bar position

- option display

- enter to skip

- pause visual

- adjust volume

- move some functions in drop view to view helper

- key to apply drop

- init count of drop

- modify particle type

- limit the player camera's y max

- limit the dw camera's y max

- change to drop's size and position

- View the drop on fixed position on screen

- limit the dw camera's x max and min

- limit the player camera's x max and min

- color of life particle

- color of energy particle

- color of scatter particle

- change glitch to dw

- dw's circle's radius

- player's sprite sheet

- shield's sprite sheet

- the visual effect for apply life

- the visual effect for apply energy and scatter

- the yellowcolor set for particle

- the special color for droptype particle

- Change to background of transition

- change the arrangement of enemy

- rearrange the surcamera

- change the position of energy

### Fixed

- blood update bug

- fire particle when dw is on

- fire laser when dw is on

- the level transition bug

### Deleted

- remove player glitch

## [0.4.0] - 2025/7/18 - 2025/7/24

### Added

- upload button image

- add flicker function

- implement flicker

- add jitter effect of title

- add info in quick help

- add key block

- add key block lobic

- add damage block logic

- add damage block help functions

- add win render

- add stayclose feature

- make the max distance with player visible

- add laser.png

- add laser sprite to texture

- visualize the laser texture

- add help_update in dw help

- add fire particle position function in particlegen

- player send statemsg to particle

- weapon send statemsg to particel

- add mousepressed variable in model

- add fire particle generator

- visualize the fire partciel effect

- add color for particle view

- yellow color set 2 for laser

- add laser variable in model and in initdata

- add idle sprite sheet

- add playerview helper file

- add run sprite sheet

- add jump sprite sheet

- add stay funtion for player view

- add player jump animation

- upload idle2.png

- upload jump2.png

- upload run2.png

- jump facing left side

- stay facing left side

- run facing left side

- initialize scene Demo

- layer FrontLayer under scene Demo

- add demo button

- initialize data in demo

- switch function

- level buttons(need change)

- upload symbols

- add documentation

- set currentlevel to level

- guidance in lv2

- load new tileset

- upload button image

- update skills image

- add dw player render

- add random helper function

- add background speed logic

- upload cyberpunk beat

- add battle music

- add shield sprite

- add moving speed function

- add initHandTime field

- ready to add visual effect in dw

- add ground state shield render

- change weapon direction

- add direction in ceo

- add hurt calculation

- add defend move function

- clear the future direction

- add normal skill refresh

- add advance skill refresh

- add player bullet judge logic

- add laser decrease blood function

- add msg system

- add one of the enemy run sprite

- add enemy1 walk1 sprite

- add sprite split

- add hand to enemy1

- load enemy resources

- add sprite sheets for enemy 2

- add sprite sheet for enemy 3

- initialize level Level3 from sceneproto Game

- add new msg dealing logic

- add bullet msg sent to ceo

- add lsg sent to ceo

- add knives for enemy

- add enemy guns sprites

- load weapons for enemy

- add level3 map

- add ceo image

- configure level4

- win&pause

- add flipped shield render

- add bullet sound effect

- add laser sound effect

- add init for drop and dropgen file

- add drop random generator

- functions for gen and add drops

- drop receive enemydiemsg

- add dropview file to visualize drop

- add viewdrops function

- initialize layer Front under sceneproto Game

- view in drop model

- add playerpos in drop data and receive msg

- add delete_drops function

- add dropmsg to send to player

- make drop move up and down

- add functions to gen dropmsg

- add test drop

- player receive drop msg from drop

- add scatterbullet function to generate more bullet

- add receiving dropmsg in weapon

- add scatter type

- allow weapon to scatter bullets when get the certain drop

- mirror player

- add life texture

- add scatter texture

- add energy texture

- add choose texture function

- add view single drop with texture

- add view drops with texture

- add enemydead file to make msg for drops

- make msglist when enemy die

### Changed

- separate functions in home

- modify bug report

- fix player going through wall bug

- make speed of bullet same in different frame

- modify the life of particle of bullet

- modify player view funtion

- the positon of double jump particle

- change background texture

- move the view of sprite sheet of player to player view

- modify readme

- modify double jump color

- adjust pause and time

- update key

- new tileset

- change bg in dw to black

- upload new shield sprite sheet

- adjust ceo near attack logic

- change the initdata

- slightly change the data structure

- reupload mechanical arm

- update name of assets

- gun color change

- rename image

- adjust predict line and bullet damage

- modify the front layer in game

- adjust render order

- modify update of drop to send msg and move drops

- move some part of updaterec to new file

- move part of updaterec to  receive file

- modify drop gen

- adapt all file to scatter type

- move part of weapon update to weapon help

- change idel image

- modify scatter time

### Fixed

- fix format in home

- fix dw hp bugs

- avoid camera from moving upward when enter dw

- the init of particle

- make laser particle to appear only when energy is enough

- fix bullet logic

- fix damage calculation

- fix walk image

- fix ambiguous guidance

### Deleted

- delete useless images

- remove useless resources

## [0.3.0] - 2025/7/11 - 2025/7/17

### Added

- move the particle gen

- add particle init msg in componentmsg

- init of component particle

- bullet send msg to particle

- receive the bullet msg in updaterec in particle model

- add view helper function for particle

- add view for particle model

- add function for gen color of particle

- add color set for view of particle

- add player postion in particle data and initdata

- add doublejump msg and make a new file for double jump

- add ddoublejump particle generator

- add function adddoublejumpparticle

- add particletype to distinguish different particle

- view the particle for double jump

- add type laser in particletype

- add more precise laser judgement

- add particle update function in bulletmove

- add types for particle

- install elm random

- add predict line wall detect

- add predit line detct tile

- add fake block

- add recover block render

- add damage block effect

- add block kind detect

- add damage block

- add laser judgement to cameras

- complete bullet judgement to cameras

- add bullet attack to cameras

- add decrease blood function to player

- add render of survcamera

- survcameraupdate with player msg

- release bullet logic

- new bullet generate

- part of change mode logic

- part of state change judgement

- refresh camera bounds with player

- camera attack mode logic

- add rotate function

- add direction judge

- new movement function for camera

- add map information functions for scamera

- functions for default mode move

- logic on camera tiles filter

- camera right move logic

- definition of survcamera

- part of camera logic

- component Survcamera  in sceneProto Game

- hint of quick help

- load background

- add cover/title image

- add quick help in map

- add dash feature

- add laser gun predict line

- add laser recoil

- add death judgement

- add simple in-map guidance

- component Guidance  in sceneProto Game

- survaliance camera that can attack player

- move back and forth

- View the attack scope

- Particle for double jump

- Image for home

- add function for gen color of particle

- break bullet into particles list

- random

- types for particle

- generate particle function

- update and view for particle

- add spring movement

- add swingMode file

- add spring mode

- add spring pedulum

- add spring direction

- draw map

- complete map(seems too small)

- Component: Background  in sceneProto Game

- add background

- move to the front of bg

- Layer: GuideLayer under scene Level1

- complete the enemy wall judgement

- add spring pendulum motion

- bricks only visible in DW

- pause in player

- pause in DW

- pause in bullet

- write help function for dw

- add recoil feature

- add recoil limit

- add streching update position

- add smooth mechanical arm motion

- add smooth mechanical arm control

- add predict line helper functions

- add isPaused

- isPaused msg

- simple pause symbol (no pause effect)

- add predict line render

### Changed

- update the particlemodel in update function

- bullet send msg to particle

- modify the bullet style

- modify the initdata and initmsg for partic

- modify the updaterec in particle model

- change color for different particle

- change bullet color and effect

- change version number

- modify the corresponding function in model

- renew weapon init function

- renew the init data for level1

- optimize the tiles judgement functions

- definition update for survcamera

- change judge range of camera

- modify death information

- adjust render order

- adjust map and in-map guidance

- modify the corresponding function in model

- adapt the model of bullet to new component

- larger map

- change vy of player

- adjust enemy move logic

- update camera in interface

- update guidance

- add view of dw projection

- map send msg to dw projection

- player send msg (state) to dw projection

- add function canvastoscreen in playerlogic

- coordtransform file for transform function

- add mechanical arm detect

### Fixed

- fix dash bug

- fix attack mode movement

- prevent the player from moveing in dw

- fix weapondir bug

- fix inconsistent map detect

- fix bg loading

- fix boss laser production issue

- fix pause in the middle

- fix gun energy bar render bug

- fix dw reset problem

### Deleted

- remove the updatebulletparticle function

- remove the function breakbulletintoparticles and adapt the initbullet to current

- delete all current camera msg used

- delete the current camera msg in dw

- delete current camera and msg in interface model

- remove useless import

- clear comment

- delete useless component

- delete useless layer

## [0.2.0] - 2025/7/5 - 2025/7/10

### Added

- shield protect player from bullet

- Partial mechanical arm

- some helper functions

- complete basic weapon

- add view of dw projection

- map send msg to dw projection

- player send msg (state) to dw projection

- add function canvastoscreen in playerlogic

- coordtransform file for transform function

- add mechanical arm detect

- add camera following in mechanical arm movement

- add canvas_mouse_pos in userdata

- add screentocanvas function to transform coord

- add a text following mouse for testing

- make weapon follow the mouse correctly

- player-map collision

- Bug report template

- shield can block the bullet at different angle

- try to let player move in the shortening process (can't dete
ct brick)

### Changed

- recompose the update of dw

- recompose the updaterec of dw

- recompose view of dw

- make weapon stay with player instead of following dw projection

- avoid weapon update when dw is on

- the position of hp and energy

- hp position of dw projection

- initial speed

- format userdata

- adjust the position of function

### Fixed

- bugs of enemy movement

- Collision check logic

- Collision judgement

- component msg

- fix bug of energy bar

- bug of mechanical arm

- fix collision bug (using mechanical arm)

- Make error

- Collision bug

- Readme release tags

### Deleted

- Unused import

- clear the bug information

- Useless import

- remove unnecessary comment and debug

## [0.1.0] - 2025/6/29 - 2025/7/4

### Added

- Camera following player

- press s to look down

- Movable laser

- basic map

- map view

- issolid logic in map

- map load

- Laser damage

- speed decrease when holding shield

- Component: Enemy

- Enemy with and without guns

- Different enemy attack methods

- Enemy direction

- Dead enemy follow function

- Enemy move

- Enemy state change

- Enemy bullet logic function

- Scene: logo

- Layer: frontlayer

- Fade in and out

- Laser gun (long press)

- Enegy feature

- Charging feature

- Basic shield

- Readme

- Changelog

- Sceneproto: Game

- Scene: Level1

- Layerproto: Main

- Component: Player

- Contemporary view of player

- Basic movement of player

- Smooth move of player

- Jump of player

- Double jump of player

- Component: Weapon

- Basic weapon movement

- Angle movement of weapon

- Player direction change

- Scene: Home

- Layer: Frontlayer under scene Home

- Raw home page

- Scene: Settings

- Layer: Frontlayer under scene Settings

- Guidance in Settings

- Transition bettween settings and homepage

- Component: Bullet

- Shoot feature

- Weapon direction

- Text size changing feature

### Changed

- change initial block position

- fix format

### Fixed

- Quick direction change bug
