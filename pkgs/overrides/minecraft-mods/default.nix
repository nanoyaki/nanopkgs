# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: _:
let
  inherit (final.lib) mapAttrs;

  mkGameVersionSet = mapAttrs (_: mods: mapAttrs (_: fetchable: final.fetchurl fetchable) mods);
in
{
  fabricMods = mkGameVersionSet final._modSources.fabric;
  neoforgeMods = mkGameVersionSet final._modSources.neoforge;
  datapacks = mkGameVersionSet final._modSources.datapack;
}
