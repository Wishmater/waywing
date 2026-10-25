#!/usr/bin/env bash
# Flutter custom-device `install` hook.
#
# There is nothing to copy for a local device, but `runDebug` does not receive
# `${localPath}`, so remember the exact asset directory the Flutter tool built.
set -euo pipefail

app_name="${1:-app}"
assets="${2:-build/flutter_assets}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

case "$assets" in
    /*) assets_abs="$assets" ;;
    *) assets_abs="$root/$assets" ;;
esac

mkdir -p "$root/wayland/.filo"
printf '%s\n' "$assets_abs" >"$root/wayland/.filo/assets"
printf '%s\n' "$app_name" >"$root/wayland/.filo/app-name"
