# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: _: {
  nix-update-script = final.callPackage ./package.nix { };
}
