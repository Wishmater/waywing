#!/usr/bin/env bash
# Flutter custom-device `runDebug` hook.
#
#   $1 appName        $2 engineOptions (ignored for now)  $3 buildMode
#   $4 icuDataPath     $5 engineRevision
#
# Flutter watches this process's stdout/stderr for the VM service URL. Keep
# stdout inherited and `exec` the host so the PID Flutter stops is the app.
set -euo pipefail

app_name="${1:-app}"
_build_mode="${3:-debug}"
icu_data="${4:-}"
_engine_revision="${5:-}"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root/wayland"

# Per-app engine location. A shared/installed engine can also be set with
# FILO_ENGINE_LIB in the environment.
if [[ -f .env.local ]]; then
    # shellcheck disable=SC1091
    . ./.env.local
fi
if [[ -z "${FILO_ENGINE_LIB:-}" && -f "$root/wayland/engine/libflutter_engine.so" ]]; then
    FILO_ENGINE_LIB="$root/wayland/engine/libflutter_engine.so"
fi
if [[ -z "${FILO_ENGINE_LIB:-}" ]]; then
    echo "filo-wayland: FILO_ENGINE_LIB is not set; put it in wayland/.env.local" >&2
    exit 1
fi

assets="${FILO_ASSETS:-}"
if [[ -z "$assets" && -f .filo/assets ]]; then
    assets="$(cat .filo/assets)"
fi
if [[ -z "$assets" ]]; then
    assets="$root/build/flutter_assets"
fi

export FILO_ENGINE_LIB
export FILO_ICU_DATA="${FILO_ICU_DATA:-$icu_data}"
export FILO_ASSETS="$assets"
if [[ -z "$FILO_ICU_DATA" ]]; then
    echo "filo-wayland: FILO_ICU_DATA is not set" >&2
    exit 1
fi

# Engine switches from Flutter's ${engineOptions} are currently ignored; argv
# is reserved for Dart entrypoint arguments.

# Flutter custom devices do not forward --dart-entrypoint-args. Pass the Dart
# entrypoint arguments here instead, one per line:
#
#   FILO_DART_ENTRYPOINT_ARGS=$'--dart-flag\nvalue' flutter run -d filo_wayland
#
# The host receives them as argv and forwards them to main(List<String> args).
dart_args=()
if [[ -n "${FILO_DART_ENTRYPOINT_ARGS:-}" ]]; then
    # `printf` avoids the extra empty element a here-string adds when the
    # variable already ends with a newline.
    mapfile -t dart_args < <(printf '%s' "$FILO_DART_ENTRYPOINT_ARGS")
fi
# Also forward arguments after the five hook parameters, so a future Flutter
# tool or a manual invocation can pass argv through unchanged.
if [[ $# -gt 5 ]]; then
    dart_args+=("${@:6}")
fi

bin="./zig-out/bin/$app_name"
if [[ ! -x "$bin" ]]; then
    bin="./zig-out/bin/app"
fi
if [[ ! -x "$bin" ]]; then
    echo "filo-wayland: host executable not found; run 'zig build' in wayland/" >&2
    exit 1
fi

if [[ ${#dart_args[@]} -gt 0 ]]; then
    exec "$bin" "${dart_args[@]}"
else
    exec "$bin"
fi
