#!/usr/bin/env bash
# Fetch filo into this host's Zig package and pin it by hash.
#
# Usage: ./tool/setup-filo.sh <filo-package-url>
# The URL must point at the directory containing filo's build.zig.zon.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root/wayland"

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <filo-package-url>" >&2
    exit 1
fi

zig fetch --save=filo "$1"
