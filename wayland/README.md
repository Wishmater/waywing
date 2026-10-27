# Wayland host template

Copy this directory into a Flutter app as `wayland/`. It is the app's Wayland
platform runner, like `linux/` is the GTK one. It builds a small Zig executable
that fetches the `filo` package and runs the Flutter engine directly on Wayland.
The Flutter framework and Dart code are unchanged; `filo` exports the
`filo_window_*` symbols that the `filo_windowing` Dart package binds to.

The folder belongs to the app, so app-specific native code and future plugins
can live here. Add modules in `build.zig` and import them from `src/main.zig`.

## Setup

1. Fetch filo into the copied Zig project:

   ```sh
   dart wayland/tool/wayland.dart setup-filo <filo-package-url>
   ```

   This runs `zig fetch --save=filo`, so the dependency is pinned by hash. The
   package URL must point at the directory containing filo's `build.zig.zon`
   (a Git URL to filo's repository, or a tarball).

2. Provide a standalone Flutter engine:

   ```sh
   cp wayland/.env.local.example wayland/.env.local
   # edit FILO_ENGINE_LIB
   ```

   The engine must match the Flutter SDK/engine revision used to build the app.

3. Register the global Flutter custom device once:

   ```sh
   dart wayland/tool/wayland.dart register-device
   ```

4. Run from the app root:

   ```sh
   flutter run -d filo_wayland
   ```

   If your Flutter branch still gates windowing behind a flag, add
   `--enable-windowing`.

   Flutter custom devices do not forward `--dart-entrypoint-args`. To pass
   arguments to Dart's `main(List<String> args)`, set
   `FILO_DART_ENTRYPOINT_ARGS` with one argument per line when running Flutter
   (or put it in `wayland/.env.local`):

   ```sh
   FILO_DART_ENTRYPOINT_ARGS=$'--dart-flag1\npositional' flutter run -d filo_wayland
   ```

The custom device is project-aware: its `ping` only succeeds where
`wayland/build.zig` exists, so the same device entry works for every app that
has this folder. On arm64 hosts, change `platform` in `custom-device.json` to
`linux-arm64`.

The tooling is a single Dart script, `wayland/tool/wayland.dart`, and only uses
the Dart SDK. Make sure `dart` is on `PATH` (it ships with Flutter, alongside
`flutter`).

## How the hooks fit together

- `postBuild` runs `zig build` after Flutter writes `build/flutter_assets`. It
  resolves the engine, ICU data, assets, Dart entrypoint arguments and filo
  switches, then writes `wayland/.filo-build/launch.json`.
- `install` writes `wayland/.filo/launch.json` with the exact asset directory
  Flutter built; `uninstall` removes that per-run state.
- `runDebug` runs `wayland/zig-out/bin/<appName>` directly, so the app starts
  with the app root as its working directory and Flutter stops the actual app
  process. The host reads the launch manifest; `FILO_*` environment variables
  override it. Flutter's `${engineOptions}` are currently ignored.
- Flutter discovers the VM service URL from the host's stdout, so hot reload
  and hot restart work through the normal Flutter tooling.

For a manual run, `dart wayland/tool/wayland.dart run` refreshes the launch
manifest and starts the host with the app root as the working directory.
`zig build run` from `wayland/` still works when `FILO_ENGINE_LIB`,
`FILO_ICU_DATA` and `FILO_ASSETS` are set.

`.env.local` is parsed by the Dart tool, not sourced by a shell. It supports
`KEY=VALUE`, comments, single/double quoted values and `$'...'` escapes, but no
variable expansion or command substitution. Relative paths resolve against
`wayland/`.

Custom devices only support debug builds. For release, build the AOT bundle
separately (for example with `flutter build linux --release` while a `linux/`
runner is still present) and launch the host with `FILO_AOT_LIB` and the
release `FILO_ASSETS`. `filo` itself supports AOT; only the custom-device
debug hook is limited to debug mode.

## Files

- `build.zig`, `build.zig.zon` — the host executable and its filo dependency.
- `src/main.zig` — reads the launch manifest (or `FILO_*`), forwards argv to
  Dart, calls `filo.run`.
- `tool/wayland.dart` — the custom-device hooks, launch manifest, setup helper
  and device registration.
- `custom-device.json` — the device entry; the `register-device` subcommand
  installs it.
- `.env.local` — machine-specific paths, parsed by the Dart tool; gitignored.
- `.filo-build/`, `.filo/` — generated launch state; gitignored.
