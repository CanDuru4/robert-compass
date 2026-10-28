#!/bin/sh
# Backend gate: install, syntax check and domain unit tests. Never builds Xcode.
# Example: /absolute/checkout/scripts/check.sh [--full] (--full is identical).
set -eu

case "${1:-}" in
    "" | --full) ;;
    *)
        echo "usage: scripts/check.sh [--full]" >&2
        exit 2
        ;;
esac

ROOT=$(cd "$(dirname "$0")/.." && pwd)
npm --prefix "$ROOT/backend" ci --ignore-scripts
npm --prefix "$ROOT/backend" run check
npm --prefix "$ROOT/backend" test
echo "ALL CHECKS PASSED at $(git -C "$ROOT" rev-parse HEAD)"
