#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT

set -euo pipefail

PACKAGE_PATH="${1-"$(dirname "$(readlink -f "$0")")/package.nix"}"

VERSION="$(
  curl -s "https://api.github.com/repos/ppy/osu/releases" |
    jq -r '.[0].tag_name'
)"

sed -i 's/version = ".*"/version = "'"$VERSION"'"/' "$PACKAGE_PATH"
