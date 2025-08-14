# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  callPackage,
}:

lib.recurseIntoAttrs {
  shokoApi = callPackage ./shokoapi { };
  py-common = callPackage ./py-common.nix { };
  aniDb = callPackage ./yml.nix { name = "AniDB"; };
  hanime = callPackage ./yml.nix { name = "hanime"; };
}
