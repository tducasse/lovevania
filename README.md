# mvania
A metroidvania template in Love2d.

## Setup
## Prerequisites
- [Love2d 11.3](https://github.com/love2d/love/releases/download/11.3/love-11.3-win64.exe) (11.4 is not compatible with [love.js](https://github.com/Davidobot/love.js) yet)
- a recent enough `make` (can be installed with [chocolatey](https://community.chocolatey.org/) on windows for example; more info [here](https://community.chocolatey.org/packages/make))
- if you plan on deploying to itch.io, [butler](https://itch.io/docs/butler/) - run `butler login` before you use the Makefile
- if you plan on bundling for web, a compatible version of Node.js, since we use [love.js](https://github.com/Davidobot/love.js).

## Folder structure
This project is set up to use [love-deploy](https://github.com/tducasse/love-deploy). Follow the README there to set everything up the way it should!
```sh
# project folder for Love projects
- myLoveProjects
  - love_deploy_makefile_here
  - your_project_here/
    - project_Makefile_here
```

## Third party software we use
- [LDtk](https://ldtk.io/) to design levels
- [Aseprite](https://www.aseprite.org/) to create pixel art animations
- Anything that can produce audio files [compatible with Love2d](https://love2d.org/wiki/Audio_Formats). Good options include [Bosca Ceoil](https://terrycavanagh.itch.io/bosca-ceoil) and [LMMS](https://lmms.io/) for example.
- [VS Code](https://code.visualstudio.com/)

# What's included
- easy input mapping with [baton](https://github.com/tesselode/baton)
- responsive resizable pixel perfect screen with [push](https://github.com/Ulydev/push/)
- gamestates with [ScreenManager](https://github.com/rm-code/screenmanager)
- signals and message passing with [hump.signal](https://github.com/vrld/hump)
- light OOP with [classic](https://github.com/rxi/classic)
- a better way to debug tables with [inspect](https://github.com/kikito/inspect.lua)
- automated Aseprite animation import with [peachy](https://github.com/josh-perry/peachy)
- fancy camera effects with [STALKER-X](https://github.com/a327ex/STALKER-X)
- [LDtk](https://ldtk.io/) tilemap parsing and collisions with [tilemapper](https://github.com/tducasse/tilemapper), [json.lua](https://github.com/rxi/json.lua), and [bump.lua](https://github.com/kikito/bump.lua)
  
Not included, but easy to add:
- a complete dialog system, with [erogodic](https://github.com/oniietzschan/erogodic) and [talkies](https://github.com/tanema/talkies). See an example of usage [here](https://github.com/tducasse/love-boilerplate/blob/main/src/screens/Intro.lua).

# Quick breakdown of the codebase
## Misc files
### `.vscode/` folder
- `extensions.json` lists recommended extensions
- `settings.json` sets a few things like autoformatting, Lua Autocompletion, etc

### `lua-format.yaml`
This is a list of rules used to enforce a standard coding style.

## `lib/` folder
This is where you find all the libraries we have installed. While it is possible to fetch them from GitHub using submodules or a package manager, it's often safer to just download them and include them in this folder. You'll notice that some libraries depend on other libraries, like `peachy` does on `tween` for example, which explains why we have `tween.lua` in this folder.

## `assets/` folder
Put anything related to art (sounds, music, pngs, aseprite json, etc) in this folder.

## `src/` folder
### `globals.lua`
You can think of this as a way to define both global variables as _constants_, where tables would be less ambiguous and risky than strings for example (signal names are a good example), but also _config_ values, like screen and game sizes.

### `entities/` folder
This is where we put all the actors in the game: enemies, player, items, projectiles, etc. We also use `classic`, a lightweight OOP library for Lua, which allows us to define classes and extend them as we want.

### `screens/` folder
This project uses `ScreenManager` (more info [here](https://github.com/rm-code/screenmanager) to manage scenes/states/screens/whatever you want to call them. Each one of the files inside this folder is an instance of `Screen`, which redefines the Love2d callbacks such as `update` and `draw`.

## `main.lua`
This is where it all starts! Also have a look at `conf.lua`, which holds the config for the Love engine; more info [here](https://love2d.org/wiki/Config_Files).