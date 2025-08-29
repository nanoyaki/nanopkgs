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
    mapAttrs'
    nameValuePair
    replaceStrings
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

  _modSources = foldr (
    filename: attrs:
    let
      sources = importJSON (../_modSources + "/${filename}");
      project = elemAt (splitString "." filename) 0;
    in
    recursiveUpdate attrs (
      mapAttrs' (
        loader: gameVersions:
        nameValuePair loader (
          mapAttrs' (
            gameVersion: fetchable:
            nameValuePair ("v" + replaceStrings [ "." ] [ "_" ] gameVersion) { ${project} = fetchable; }
          ) gameVersions
        )
      ) sources
    )
  ) { } (attrNames (removeAttrs (readDir ../_modSources) [ "_projects.json" ]));

  overrides = map (override: import (./overrides + "/${override}")) (attrNames (readDir ./overrides));
in

{
  flake.overlays.default = composeManyExtensions (
    [
      (final: _: {
        _sources = final.callPackage ../_sources/generated.nix { };
        inherit _versions _modSources;
      })

      (import "${nixpkgs}/pkgs/top-level/by-name-overlay.nix" ./by-name)
      (import ./pythonPackagesExtensions)
    ]
    ++ overrides
  );
}
