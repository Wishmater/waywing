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
   ./wayland/tool/setup-filo.sh <filo-package-url>
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
   ./wayland/register-device.sh
   ```

4. Run from the app root:

   ```sh
   flutter run -d filo_wayland
   ```

   If your Flutter branch still gates windowing behind a flag, add
   `--enable-windowing`.

The custom device is project-aware: its `ping` only succeeds where
`wayland/build.zig` exists, so the same device entry works for every app that
has this folder. On arm64 hosts, change `platform` in `custom-device.json` to
`linux-arm64`.

## How the hooks fit together

- `postBuild` runs `zig build` after Flutter writes `build/flutter_assets`.
- `install` records the exact asset directory in `wayland/.filo/assets`.
- `runDebug` sets `FILO_ENGINE_LIB`, `FILO_ICU_DATA` and `FILO_ASSETS`, splits
  Flutter's `${engineOptions}` back into argv, and `exec`s the host.
- Flutter discovers the VM service URL from the host's stdout, so hot reload
  and hot restart work through the normal Flutter tooling.

Custom devices only support debug builds. For release, build the AOT bundle
separately (for example with `flutter build linux --release` while a `linux/`
runner is still present) and launch the host with `FILO_AOT_LIB` and the
release `FILO_ASSETS`. `filo` itself supports AOT; only the custom-device
debug hook is limited to debug mode.

## Files

- `build.zig`, `build.zig.zon` — the host executable and its filo dependency.
- `src/main.zig` — reads `FILO_*`, forwards engine options, calls `filo.run`.
- `tool/post-build.sh`, `tool/install.sh`, `tool/uninstall.sh`, `tool/run.sh`
  — the custom-device hooks.
- `tool/setup-filo.sh` — fetches/pins filo in `build.zig.zon`.
- `custom-device.json` — the device entry; `register-device.sh` installs it.
- `.env.local` — machine-specific paths; gitignored.
