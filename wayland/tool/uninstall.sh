#!/usr/bin/env bash
# Flutter custom-device `uninstall` hook.
#
# The app lives in the build tree, so only remove the recorded install state.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
rm -rf "$root/wayland/.filo"
