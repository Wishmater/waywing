#!/usr/bin/env bash
# Flutter custom-device `postBuild` hook.
#
# Flutter has just written build/flutter_assets. Build the Zig host that will
# load it. The remaining arguments are accepted for future packaging steps:
#   $1 appName  $2 localPath  $3 buildMode  $4 icuDataPath  $5 engineRevision
set -euo pipefail

app_name="${1:-app}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

cd "$root/wayland"
zig build -Doptimize=Debug -Dapp-name="$app_name"
test -x "zig-out/bin/$app_name"
