#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/.."
lake build
lake build Examples
lake env lean Tests/Audit.lean
lake env lean Tests/Strong.lean
lake env leanchecker Abstractification Examples
python3 scripts/check_negative.py
lake exe abstractificationDemo
