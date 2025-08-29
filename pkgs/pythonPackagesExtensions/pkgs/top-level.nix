# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: _: {
  beet = final.callPackage ./beet.nix { };
  bolt = final.callPackage ./bolt.nix { };
  drop2beets = final.callPackage ./drop2beets { };
  jmc = final.callPackage ./jmc.nix { };
  mecha = final.callPackage ./mecha.nix { };
  python-modernize = final.callPackage ./python-modernize.nix { };
  tokenstream = final.callPackage ./tokenstream.nix { };
}
