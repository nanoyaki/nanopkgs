#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT

set -euo pipefail

REV="$1"
PACKAGE_PATH="${2-"$(dirname "$(readlink -f "$0")")/package.nix"}"

REVISION="$(
  curl -I -s 'https://api.github.com/repos/Suwayomi/Suwayomi-Server/commits?per_page=1&sha='"$REV" |
    sed -n 's/.*"next".*page=\([0-9]*\)>.*"last".*/\1/p'
)"

sed -i 's/revision = "[0-9]*"/revision = "'"$REVISION"'"/' "$PACKAGE_PATH"
