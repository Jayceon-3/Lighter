# Lighter

Lighter is a browser game built with [Elm](https://elm-lang.org/) and the
[Messenger](https://elm-messenger.netlify.app/) game framework. The current
version includes a home screen, settings screen, one playable level, player
movement, double jump, mouse aiming, weapons, bullets, and enemies.

This repository was originally developed as a course project and is now being
maintained as an open source project.

## Features

- Elm 0.19.1 application using Messenger and REGL.
- Platformer-style player movement with double jump.
- Mouse-controlled weapon direction and shooting.
- Scene-based structure for home, settings, and gameplay.
- Local browser build with static assets under `public/`.

## Requirements

- [Elm 0.19.1](https://guide.elm-lang.org/install/elm.html)
- [elm-format](https://github.com/avh4/elm-format)
- `make`
- Python 3, only needed for the local static file server
- Node.js with `uglify-js`, only needed for optimized release builds

Elm dependencies are declared in `elm.json` and will be downloaded by Elm during
the first build.

## Getting Started

Clone the repository and enter the project directory:

```sh
git clone <repository-url>
cd Lighter
```

Build the development version:

```sh
make
```

This generates `build/main.js` and copies the required static assets. After the
build finishes, open `index.html` in your browser.

You can also start a local static server:

```sh
make host
```

Then open [http://localhost:8123]().

## Release Build

For an optimized build, install `uglify-js` first:

```sh
npm install --global uglify-js
```

Then run:

```sh
make release
```

## Controls

- `A` / `D`: Move left or right
- `W`: Jump and double jump
- Left mouse button: Shoot

## Project Structure

- `src/Main.elm`: Elm application entry point
- `src/MainConfig.elm`: global game configuration
- `src/Scenes/`: home, settings, and level scenes
- `src/SceneProtos/Game/`: gameplay components and scene prototype
- `public/`: HTML, CSS, and JavaScript runtime assets
- `build/`: generated build output

## Contributing

Contributions are welcome. For larger changes, please open an issue first to
discuss the proposed direction. When submitting a pull request, include a short
summary of the change and any manual testing you performed.

## Acknowledgements

Lighter was first created as a course project. Thanks to the original project
team, the SilverFOCS Incubator, UM-SJTU JI, and the Elm/Messenger communities.

## License

This project is licensed under the [MIT License](https://choosealicense.com/licenses/mit/).
