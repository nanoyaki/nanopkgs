# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
final: _: {
  fabricMods = final.callPackage ./mods.nix { modset = final._modSources.fabric; };
  neoforgeMods = final.callPackage ./mods.nix { modset = final._modSources.neoforge; };
  datapacks = final.callPackage ./mods.nix { modset = final._modSources.datapack; };
}
