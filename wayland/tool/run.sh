#!/usr/bin/env bash
# Flutter custom-device `runDebug` hook.
#
#   $1 appName        $2 engineOptions  $3 buildMode
#   $4 icuDataPath     $5 engineRevision
#
# Flutter watches this process's stdout/stderr for the VM service URL. Keep
# stdout inherited and `exec` the host so the PID Flutter stops is the app.
set -euo pipefail

app_name="${1:-app}"
engine_options="${2:-}"
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

# Flutter gives all switches as one space-separated string. They are simple
# --key=value flags; split them back into argv for the host.
engine_args=()
if [[ -n "$engine_options" ]]; then
    read -r -a engine_args <<<"$engine_options"
fi

bin="./zig-out/bin/$app_name"
if [[ ! -x "$bin" ]]; then
    bin="./zig-out/bin/app"
fi
if [[ ! -x "$bin" ]]; then
    echo "filo-wayland: host executable not found; run 'zig build' in wayland/" >&2
    exit 1
fi

if [[ ${#engine_args[@]} -gt 0 ]]; then
    exec "$bin" "${engine_args[@]}"
else
    exec "$bin"
fi
