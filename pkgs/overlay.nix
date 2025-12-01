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
    recursiveUpdate
    attrNames
    importJSON
    mapAttrs'
    nameValuePair
    replaceStrings
    ;
  inherit (builtins) readDir;

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
      (_: _: { inherit _modSources; })
      (import "${nixpkgs}/pkgs/top-level/by-name-overlay.nix" ./by-name)
    ]
    ++ overrides
  );
}
