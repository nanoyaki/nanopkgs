# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{
  lib,
  modset,
  fetchurl,
}:

lib.recurseIntoAttrs (lib.mapAttrs (_: mods: lib.mapAttrs (_: fetchurl) mods) modset)
