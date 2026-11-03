# Perception

2D and 3D perception system plugin for Godot 4.7.

## Getting started

There are two ways to set up the development environment: with [devenv](https://devenv.sh/) (recommended) or manually.

### With devenv

[devenv](https://devenv.sh/) provides all required packages in a self-contained reproducible shell.

1. [Install devenv](https://devenv.sh/getting-started/).
2. From the project directory, enter the development shell:

   ```shell
   devenv shell
   ```

### Manually

Install the following requirements:

- [Godot 4.7](https://godotengine.org/)
- [gdscript-formatter 0.27](https://github.com/GDQuest/GDScript-formatter) (make sure it is available on your `PATH`)

### Git hooks

The repository ships a pre-commit hook in `.githooks/pre-commit` that lints staged GDScript files with gdscript-formatter and blocks the commit if there are any warnings. Only when linting passes does it format the files and re-stage them.

- With devenv: the hook is enabled automatically when entering the shell.
- Manual setup: enable it with:

  ```shell
  git config core.hooksPath .githooks
  ```

### Opening the project

Open the project using the **Godot Project Manager** or run the following command from the project directory:

```shell
godot --path . --editor
```

## Running tests

The project uses [GUT](https://github.com/bitwes/Gut). Run the test suite from the project directory:

```shell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

## Installation

1. Copy `addons/perception` into your project's `addons` directory.
2. Enable **perception** in **Project > Project Settings > Plugins**.

Enabling the plugin registers the `NoiseBus3D` autoload automatically. Disabling it removes the autoload.

## Documentation

- [Contributing](CONTRIBUTING.md)

## License

Released under the [MIT License](LICENSE).
