# SPDX-FileCopyrightText: 2025 Hana Kretzer <hanakretzer@gmail.com>
#
# SPDX-License-Identifier: MIT
{ inputs, ... }:

let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs.lib)
    composeManyExtensions
    foldr
    splitString
    elemAt
    drop
    recursiveUpdate
    setAttrByPath
    attrNames
    importJSON
    ;
  inherit (builtins) readDir;

  # Converts the nvchecker format into the keys defined in nvchecker.toml
  versionData = (importJSON ../_versions/new_versions.json).data;
  _versions = foldr (
    name: attrs:
    let
      sets = splitString "." name;
      set = elemAt sets 0;
      subsetPath = drop 1 sets;
    in
    recursiveUpdate attrs {
      ${set} = setAttrByPath subsetPath versionData.${name}.version;
    }
  ) { } (attrNames versionData);

  overrides = map (override: import (./overrides + "/${override}")) (attrNames (readDir ./overrides));
in

{
  flake.overlays.default = composeManyExtensions (
    [
      (final: _: {
        _sources = final.callPackage ../_sources/generated.nix { };
        inherit _versions;
      })

      (import "${nixpkgs}/pkgs/top-level/by-name-overlay.nix" ./by-name)
    ]
    ++ overrides
  );
}
