# Ada Snake (Minimal)

This folder contains a classic Snake game implemented in Ada.

## Why Extra Files Appeared

When you build with `gprbuild`, it generates temporary and output files next to your sources:

- `*.o`: object files (compiled machine code per source file)
- `*.ali`: Ada metadata files used by GNAT tooling
- `*.bexch`: binder exchange files used during Ada linking
- `b__*`: generated binder source/object files for Ada runtime startup
- `*.stdout` / `*.stderr`: compiler output logs for each build unit
- `snake`, `snake_game_tests`: final executables

These are normal build artifacts. They are not source code and can be regenerated.

## Project Files

- `snake.gpr`: project/build configuration
- `src/snake_game.ads`: game logic API
- `src/snake_game.adb`: game logic implementation
- `src/main.adb`: terminal game loop and rendering
- `tests/snake_game_tests.adb`: core logic tests

## Controls

- Move: Arrow keys or `W`, `A`, `S`, `D`
- Pause/Resume: `P`
- Restart: `R`
- Quit: `Q` (also auto-cleans build artifacts before exit)

## Build And Run (macOS)

```bash
cd /Users/noah/Documents/Codex/SnakeByADA

export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
export LIBRARY_PATH="$SDKROOT/usr/lib"
export CPATH="$SDKROOT/usr/include"

~/.alire/bin/gprbuild -P snake.gpr -p -largs -Wl,-syslibroot,"$SDKROOT"

./snake_game_tests
./snake
```

## Clean Build Artifacts

Artifacts are cleaned automatically when you quit the game with `Q`.

If you want to clean manually:

```bash
cd /Users/noah/Documents/Codex/SnakeByADA
rm -f b__* *.ali *.o *.bexch *.stdout *.stderr snake snake_game_tests
```
