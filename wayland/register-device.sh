#!/usr/bin/env bash
# Register (or refresh) the global Flutter custom device for this app.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

if ! command -v flutter >/dev/null 2>&1; then
    echo "flutter is not on PATH" >&2
    exit 1
fi

flutter config --enable-custom-devices >/dev/null

# `custom-devices add` appends; remove an older entry with the same id first.
flutter custom-devices delete -d filo_wayland >/dev/null 2>&1 || true
flutter custom-devices add --json "$(cat wayland/custom-device.json)" --check
