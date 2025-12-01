#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused
# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT

set -euo pipefail

PACKAGE_PATH="${1-"$(dirname "$(readlink -f "$0")")/package.nix"}"

VERSION="$(
  curl -s -L 'https://whisparr.servarr.com/v1/update/eros/changes' --fail |
    jq -r '.[0].version'
)"

sed -i 's/version = "[0-9\.]*"/version = "'"$VERSION"'"/' "$PACKAGE_PATH"
